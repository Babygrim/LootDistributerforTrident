local LootDistr, LDData = ...
local f = LDData.main_frame

function OnTargetChanged(self, event)
    if not LootRollerAddonSettings or not LootRollerAddonSettings.autoLootSwitch then 
        return 
    end

    if UnitExists("target") and UnitIsEnemy("player", "target") then
        local targetlevel = UnitLevel("target")
        local lootMethod, masterLooter, masterLooterRaidID = GetLootMethod()
        local playerIsLeader = IsRaidLeader()
        local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize = GetInstanceInfo()
        local enabled = true

        -- If inside a raid instance, maxPlayers tells you (10 or 25)
        if instanceType == "raid" and maxPlayers then
            if maxPlayers == 10 and LootRollerAddonSettings.disableLootSwitchFor10Man then
                enabled = false
            end
        end

        -- Boss mob
        if enabled and lootMethod ~= "master" and playerIsLeader and targetlevel == -1 then
            SetLootMethod("master", LDData.playerName or UnitName("player"))
        end
        
        -- Normal mob
        if enabled and lootMethod ~= "group" and playerIsLeader and targetlevel ~= -1 then
            SetLootMethod("group")
        end
    end
end

function LootUpdate(self, elapsed)
    if not looting or #lootQueue == 0 then
        CloseLoot()
        looting = false
        f:SetScript("OnUpdate", nil)
        return
    end

    local slot = table.remove(lootQueue, 1)
    if LootSlotIsCoin(slot) or LootSlotIsItem(slot) then
        LootSlot(slot)
        ConfirmLootSlot(slot)
    end
end

-- Fires when loot window opens
function OnLooting(self, event, autoLoot)
    if not LootRollerAddonSettings or not LootRollerAddonSettings.autoLootItems then 
        return 
    end

    local lootMethod, masterLooter = GetLootMethod()
    local isMasterLooter = (lootMethod == "master") and (masterLooter == 0)
    if not isMasterLooter then return end

    local playerName = UnitName("player")
    local numItems = GetNumLootItems()
    if LootSlotIsCoin(1) then LootSlot(1) end


    for ci = 1, GetNumRaidMembers() do
        if (GetMasterLootCandidate(ci) == UnitName("player")) then
            for li = 1, GetNumLootItems() do
                local lootIcon, lootName, lootQuantity, rarity, locked, isQuestItem, questId, isActive = GetLootSlotInfo(li);
                if rarity <= 4 then
                    GiveMasterLoot(li, ci);
                end
            end
        end
    end

end

LDData.OnTargetChangedLootMaster = OnTargetChanged
LDData.OnLootingMasterLooter = OnLooting
