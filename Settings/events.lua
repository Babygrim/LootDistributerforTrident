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
            if maxPlayers > 10 and LootRollerAddonSettings.disableLootSwitchFor10Man then
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

function OnLooting(self, event)
    if not LootRollerAddonSettings or not LootRollerAddonSettings.autoLootSwitch then 
        return 
    end

    local lootMethod, masterLooter, masterLooterRaidID = GetLootMethod()
    local isMasterLooter = (lootMethod == "master") and (masterLooter == UnitName("player"))

    if isMasterLooter then
        local numItems = GetNumLootItems()
        for slot = 1, numItems do
            if LootSlotIsItem(slot) then
                LootSlot(slot)
            elseif LootSlotIsCoin(slot) then
                LootSlot(slot)
            end
        end
        -- Close loot window after looting
        CloseLoot()
    end
end

LDData.OnTargetChangedLootMaster = OnTargetChanged
LDData.OnLootingMasterLooter = OnLooting
