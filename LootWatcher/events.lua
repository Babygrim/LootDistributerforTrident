local LootDistr, LDData = ...
local f = LDData.main_frame

-- Confirmation popup for deleting all soft reserve data
StaticPopupDialogs[LootDistr .. "ConfirmDeleteLootWatcher"] = {
    text = LDData.messages.dialogs.confirmDeleteWatcher,
    button1 = LDData.messages.dialogs.yes,
    button2 = LDData.messages.dialogs.no,
    OnAccept = function()
        LootWatcherData = {}
        LootWatcherGoldGained = 0
        UpdateLootWatcherTable(f.searchBox:GetText())
        print("|cff00FF00[LootDistributer]|r "..LDData.messages.system.lootWatcherDataDeleted)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

f.lootSearchBox:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == LDData.lootPlaceholder then
        self:SetText("")
        self:SetTextColor(1, 1, 1, 1)
    end
    f.lootScroll:SetVerticalScroll(0)
end)
f.lootSearchBox:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then
        self:SetTextColor(0.8, 0.8, 0.8, 1)
        self:SetText(LDData.lootPlaceholder)
        UpdateLootWatcherTable("")
    end
end)
f.lootSearchBox:SetScript("OnTextChanged", function(self)
    local txt = self:GetText()
    if txt == LDData.lootPlaceholder then txt = "" end
    UpdateLootWatcherTable(txt)
end)


-- f.eventFrame_watcher = CreateFrame("Frame")
-- f.eventFrame_watcher:RegisterEvent("CHAT_MSG_MONEY")

-- f.eventFrame_watcher:SetScript("OnEvent", function(self, event, msg)
--     if event == "CHAT_MSG_MONEY" then
--         print(msg:find("Your share of the loot is"))
--         if msg:find("Your share of the loot is") then
--             local gold, silver, copper = msg:match("Your share of the loot is%s*(%d*)%s*Gold?,?%s*(%d*)%s*Silver?,?%s*(%d*)%s*Copper")
--             gold = tonumber(g) or 0
--             silver = tonumber(s) or 0
--             copper = tonumber(c) or 0
--             print("PARSED: ", gold, silver, copper)

--             local total = gold * 10000 + silver * 100 + copper
--             if total > 0 then
--                 LootWatcherGoldGained = (LootWatcherGoldGained or 0) + total
    
--                 print(string.format("You received %dg %ds %dc. Total: %dg %ds %dc",
--                     gold, silver, copper,
--                     math.floor(LootWatcherGoldGained / 10000),
--                     math.floor((LootWatcherGoldGained % 10000) / 100),
--                     LootWatcherGoldGained % 100
--                 ))
--             end
--             UpdateLootWatcherTable(f.lootSearchBox:GetText())
--         end
--     end
-- end)