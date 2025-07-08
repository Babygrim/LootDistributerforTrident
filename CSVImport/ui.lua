local LootDistr, LDData = ...
local f = LDData.main_frame

-- CSV Import Tab Frame
f.csvTab = CreateFrame("Frame", LootDistr .. "CsvTab", f)
f.csvTab:SetPoint("TOPLEFT", 10, -70)       -- was -40
f.csvTab:SetPoint("BOTTOMRIGHT", -10, 60)

-- Create scroll frame inside CSV tab
f.csvScroll = CreateFrame("ScrollFrame", LootDistr .. "CsvScrollFrame", f.csvTab, "UIPanelScrollFrameTemplate")
f.csvScroll:SetPoint("TOPLEFT", 10, -10)
f.csvScroll:SetPoint("BOTTOMRIGHT", -30, 40) -- reserve space for Import button

-- Create edit box inside scroll frame
f.csvEditBox = CreateFrame("EditBox", LootDistr .. "CsvEditBox", f.csvScroll)
f.csvEditBox:SetMultiLine(true)
f.csvEditBox:SetFontObject(ChatFontNormal)
f.csvEditBox:SetAutoFocus(false)
f.csvEditBox:SetTextInsets(4, 4, 4, 4)
f.csvEditBox:SetWidth(555) -- must match scrollable area
f.csvEditBox:SetHeight(500) -- fixed height to prevent shrinking
f.csvEditBox:SetMaxLetters(0)
f.csvEditBox:SetText(SoftResCSV or "")

-- Add solid backdrop
f.csvEditBox:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
f.csvEditBox:SetBackdropColor(0, 0, 0, 0.8)
f.csvEditBox:SetBackdropBorderColor(1, 1, 1, 1)

-- Scroll behavior
f.csvScroll:SetScrollChild(f.csvEditBox)
f.csvScroll:EnableMouseWheel(true)

-- Import CSV Button
f.importBtn = CreateFrame("Button", LootDistr .. "ImportBtn", f.csvTab, "GameMenuButtonTemplate")
f.importBtn:SetSize(120, 30)
f.importBtn:SetPoint("BOTTOMLEFT", 9, 0)
f.importBtn:SetText("Import CSV")