local LootDistr, LDData = ...
local f = LDData.main_frame

function OnTargetChanged(self, event)
    local inGroup = IsInGroup()
    local inRaid = IsInRaid()
    
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
        elseif instanceType == "party" and LootRollerAddonSettings.disableLootSwitchForNonRaidGroup then
            enabled = false
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

    local lootStartingIndex = 1
    local lootMethod, masterLooter = GetLootMethod()
    local isMasterLooter = (lootMethod == "master") and (masterLooter == 0)
    if not isMasterLooter then return end

    local playerName = UnitName("player")
    local numItems = GetNumLootItems()
    if LootSlotIsCoin(1) then 
        LootSlot(1) 
        lootStartingIndex = 2
    end

    local forLimitMaxPeople

    if not IsInRaid() then 
        forLimitMaxPeople = 40 
    else 
        forLimitMaxPeople = GetNumRaidMembers() 
    end

    for ci = 1, forLimitMaxPeople do
        if (GetMasterLootCandidate(ci) == UnitName("player")) then
            for li = lootStartingIndex, GetNumLootItems() do
                if not LootSlotIsCoin(li) then
                    local lootItemLink = GetLootSlotLink(li)
                    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(lootItemLink)
                    if itemRarity <= 4 and itemType ~= "Recipe" then
                        GiveMasterLoot(li, ci)
                    else
                        print("|cffFF4500[LootDistributer]|r Skipped loot: "..itemLink.." of type: "..itemType.." and rarity of: "..itemRarity)
                    end
                end
            end
        end
    end

end

LDData.OnTargetChangedLootMaster = OnTargetChanged
LDData.OnLootingMasterLooter = OnLooting
