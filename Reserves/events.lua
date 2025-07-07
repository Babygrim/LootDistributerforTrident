local LootDistr, LDData = ...
local f = LDData.main_frame

StaticPopupDialogs[LootDistr .. "ConfirmDelete"] = {
    text = "Are you sure you want to delete ALL soft reserves data? This cannot be undone.",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        SoftResSaved = {}
        LDData.UpdateReservesTable(f.searchBox:GetText())
        print("|cff00FF00[LootDistributer]|r All soft reserves have been deleted.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}


