local LootDistr, LDData = ...
local f = LDData.main_frame

-- Handle enabling/disabling dynamically
function UpdateAutoLootSwitch()
    if LootRollerAddonSettings.autoLootSwitch then
        f.SettingsEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    else
        f.SettingsEventFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
    end
end

function UpdateAutoLootItems()
    if LootRollerAddonSettings.autoLootItems then
        f.SettingsEventFrame:RegisterEvent("LOOT_OPENED")
    else
        f.SettingsEventFrame:UnregisterEvent("LOOT_OPENED")
    end
end


LDData.UpdateAutoLootMethodSwitch = UpdateAutoLootSwitch
LDData.UpdateAutoLootItems = UpdateAutoLootItems