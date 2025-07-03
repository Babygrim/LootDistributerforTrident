-- CSV import UI
local addon = _G["LootDistributerforAnimia"]
local f = addon.frame

f.csvTab = CreateFrame("Frame", addon.name .. "CsvTab", f)
f.csvTab:SetPoint("TOPLEFT", 10, -40)
f.csvTab:SetPoint("BOTTOMRIGHT", -10, 60)

f.csvScroll = CreateFrame("ScrollFrame", addon.name .. "CsvScrollFrame", f.csvTab, "UIPanelScrollFrameTemplate")
f.csvScroll:SetPoint("TOPLEFT", 10, -10)
f.csvScroll:SetPoint("BOTTOMRIGHT", -30, 40)

f.csvEditBox = CreateFrame("EditBox", addon.name .. "CsvEditBox", f.csvScroll)
f.csvEditBox:SetMultiLine(true)
f.csvEditBox:SetFontObject(ChatFontNormal)
f.csvEditBox:SetAutoFocus(false)
f.csvEditBox:SetTextInsets(4, 4, 4, 4)
f.csvEditBox:SetWidth(555)
f.csvEditBox:SetHeight(500)
f.csvEditBox:SetMaxLetters(0)
f.csvEditBox:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
f.csvEditBox:SetBackdropColor(0, 0, 0, 0.8)
f.csvEditBox:SetBackdropBorderColor(1, 1, 1, 1)
f.csvEditBox:SetScript("OnEscapePressed", function() f:Hide() end)

f.csvScroll:SetScrollChild(f.csvEditBox)

f.importBtn = CreateFrame("Button", addon.name .. "ImportBtn", f.csvTab, "GameMenuButtonTemplate")
f.importBtn:SetSize(120, 30)
f.importBtn:SetPoint("BOTTOMLEFT", 9, 0)
f.importBtn:SetText("Import CSV")
