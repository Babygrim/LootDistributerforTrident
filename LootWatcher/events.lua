local LootDistr, LDData = ...
local f = LDData.main_frame

-- Confirmation popup for deleting all soft reserve data
StaticPopupDialogs[LootDistr .. "ConfirmDeleteLootWatcher"] = {
    text = "Are you sure you want to delete ALL loot watcher data? This cannot be undone.",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        LootWatcherData = {}
        LootWatcherGoldGained = 0
        LDData.UpdateLootWatcherTable(f.searchBox:GetText())
        print("|cff00FF00[LootDistributer]|r All loot watcher data has been deleted.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}