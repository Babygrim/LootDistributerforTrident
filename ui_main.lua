-- Main UI frame setup
local addon = _G["LootDistributerforAnimia"]

local f = CreateFrame("Frame", addon.name .. "MainFrame", UIParent)
addon.frame = f

f:SetSize(620, 460)
f:SetPoint("CENTER")
f:Hide()
f:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 5, right = 5, top = 5, bottom = 5 },
})
f:SetBackdropColor(0, 0, 0, 1)

local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)
closeBtn:SetScript("OnClick", function() f:Hide() end)

f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
f.title:SetPoint("TOP", 0, -10)
f.title:SetText("Loot Distributer for Animia")

addon.tabButtons = {}

function addon.ShowTab(index)
    addon.HideAllTabs()
    if index == 1 then
        f.csvTab:Show()
        f.importBtn:Show()
        f.deleteBtn:Hide()
        f.searchBox:Hide()
        f.reservesScroll:Hide()
        f.reservesHeader:Hide()
        addon.tickerFrame:Hide()
    elseif index == 2 then
        f.reservesTab:Show()
        f.importBtn:Hide()
        f.deleteBtn:Show()
        f.searchBox:Show()
        f.reservesScroll:Show()
        f.reservesHeader:Show()
        UpdateReservesTable(f.searchBox:GetText())
        addon.tickerFrame:Show()
    end
end

function addon.HideAllTabs()
    f.csvTab:Hide()
    f.reservesTab:Hide()
end

local function CreateTabButton(name, index, xOffset)
    local btn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btn:SetSize(120, 30)
    btn:SetText(name)
    btn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", xOffset, 25)
    btn:SetScript("OnClick", function() addon.ShowTab(index) end)
    return btn
end

addon.tabButtons[1] = CreateTabButton("Import CSV", 1, 19)
addon.tabButtons[2] = CreateTabButton("View Reserves", 2, 145)

addon.ShowTab(1)
