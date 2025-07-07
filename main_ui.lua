local LootDistr, LDData = ...

-- Main frame
local f = CreateFrame("Frame", LootDistr .. "MainFrame", UIParent)
f:SetSize(620, 460)  -- made a bit taller to fit delete button
f:SetPoint("CENTER")
f:Hide()

f:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 5, right = 5, top = 5, bottom = 5 },
})
f:SetBackdropColor(0, 0, 0, 1)

-- Close button top-right
local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)
closeBtn:SetScript("OnClick", function() f:Hide() end)

-- Title
f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
f.title:SetPoint("TOP", 0, -10)
f.title:SetText("Loot Distributer for Trident")

-- GLOBALS
LDData.main_frame = f