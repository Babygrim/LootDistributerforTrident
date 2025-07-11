local LootDistr, LDData = ...

function InitializeReservesEvents()
    local f = LDData.main_frame
    StaticPopupDialogs[LootDistr .. "ConfirmDelete"] = {
        text = LDData.messages.dialogs.confirmDeleteSoftRes,
        button1 = LDData.messages.dialogs.yes,
        button2 = LDData.messages.dialogs.no,
        OnAccept = function()
            SoftResSaved = {}
            UpdateReservesTable(f.searchBox:GetText())
            print("|cff00FF00[LootDistributer]|r "..LDData.messages.system.softResDeleted)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    f.searchBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == LDData.reservePlaceholder then
            self:SetText("")
            self:SetTextColor(1, 1, 1, 1)
        end
        f.reservesScroll:SetVerticalScroll(0)
    end)

    f.searchBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetTextColor(0.8, 0.8, 0.8, 1)
            self:SetText(LDData.reservePlaceholder)
            UpdateReservesTable("")
        end
    end)

    f.searchBox:SetScript("OnTextChanged", function(self)
        local txt = self:GetText()
        if txt == LDData.lootPlaceholder then txt = "" end
        UpdateReservesTable(txt)
    end)
    
    f.searchBox:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        UpdateReservesTable(text)
        self:ClearFocus()
    end)

    f.searchBox:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
        UpdateLootWatcherTable("")
    end)

    f.reservesTab:SetScript("OnShow", function(self)
        UpdateReservesTable()
    end)
end

-- GLOBALS
LDData.InitializeReservesEvents = InitializeReservesEvents