local LootDistr, LDData = ...
local f = LDData.main_frame

-- Handle enabling/disabling dynamically
function UpdateAutoLootSwitch()
    if LootRollerAddonSettings.autoLootSwitch then
        f.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    else
        f.eventFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
    end
end

function UpdateAutoLootItems()
    if LootRollerAddonSettings.autoLootItems then
        f.eventFrame:RegisterEvent("LOOT_OPENED")
    else
        f.eventFrame:UnregisterEvent("LOOT_OPENED")
    end
end

LDData.UpdateAutoLootMethodSwitch = UpdateAutoLootSwitch
LDData.UpdateAutoLootItems = UpdateAutoLootItems