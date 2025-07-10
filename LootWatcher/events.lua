local LootDistr, LDData = ...


function InitializeLootWatcherEvents()
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
    
    f.lootSearchBox:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        UpdateLootWatcherTable(text)
        self:ClearFocus()
    end)


    f.eventFrame_watcher = CreateFrame("Frame")
    f.eventFrame_watcher:RegisterEvent("CHAT_MSG_MONEY")

    f.eventFrame_watcher:SetScript("OnEvent", function(self, event, msg)
                
    end)
end

-- GLOBALS
LDData.InitializeLootWatcherEvents = InitializeLootWatcherEvents