local addonName, addonTable = ...
local f = addonTable.main_frame

-- Confirmation popup for deleting all soft reserve data
StaticPopupDialogs[addonName .. "ConfirmDeleteLootWatcher"] = {
    text = "Are you sure you want to delete ALL loot watcher data? This cannot be undone.",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        LootWatcherData = {}
        LootWatcherGoldGained = 0
        addonTable.UpdateLootWatcherTable(f.searchBox:GetText())
        print("|cff00FF00[LootDistributer]|r All loot watcher data has been deleted.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs[addonName .. "ConfirmDelete"] = {
    text = "Are you sure you want to delete ALL soft reserves data? This cannot be undone.",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        SoftResSaved = {}
        addonTable.UpdateReservesTable(f.searchBox:GetText())
        print("|cff00FF00[LootDistributer]|r All soft reserves have been deleted.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}


-- Confirmation popup for overwriting existing data
StaticPopupDialogs[addonName .. "ConfirmOverwrite"] = {
    text = "Soft reserve data already exists. Importing new data will overwrite it. Continue?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        local text = f.csvEditBox:GetText()
        local ok, result = pcall(parseCSV, text)
        if not ok then
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF4500[LootDistributer]|r CSV parse error: " .. result)
            return
        end
        SoftResSaved = result
        DEFAULT_CHAT_FRAME:AddMessage("|cff00FF00[LootDistributer]|r Imported soft reserves!")
        if f.reservesTab:IsShown() then
            addonTable.UpdateReservesTable(f.searchBox:GetText())
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}