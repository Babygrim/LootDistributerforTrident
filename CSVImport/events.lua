local LootDistr, LDData = ...
local f = LDData.main_frame

-- Confirmation popup for overwriting existing data
StaticPopupDialogs[LootDistr .. "ConfirmOverwrite"] = {
    text = LDData.messages.dialogs.confirmOverwrite,
    button1 = LDData.messages.dialogs.yes,
    button2 = LDData.messages.dialogs.no,
    OnAccept = function()
        local text = f.csvEditBox:GetText()
        local ok, result = pcall(parseCSV, text)
        if not ok then
            print("|cffFF4500[LootDistributer]|r "..LDData.messages.system.csvParseError.." "..result)
            return
        end
        SoftResSaved = result
        SoftResCSV = text
        print("|cff00FF00[LootDistributer]|r "..LDData.messages.system.softResImported)
        if f.reservesTab:IsShown() then
            LDData.UpdateReservesTable(f.searchBox:GetText())
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

f.csvTab:SetScript("OnShow", function(self) 
    f.csvEditBox:SetText(SoftResCSV or "")
end)