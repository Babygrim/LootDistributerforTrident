local LootDistr, LDData = ...
local f = LDData.main_frame

StaticPopupDialogs[LootDistr .. "ConfirmDelete"] = {
    text = "Are you sure you want to delete ALL soft reserves data? This cannot be undone.",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        SoftResSaved = {}
        UpdateReservesTable(f.searchBox:GetText())
        print("|cff00FF00[LootDistributer]|r All soft reserves have been deleted.")
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