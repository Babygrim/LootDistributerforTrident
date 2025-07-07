local LootDistr, LDData = ...
local f = LDData.main_frame

-- Reserves Tab Frame
f.reservesTab = CreateFrame("Frame", LootDistr .. "ReservesTab", f)
f.reservesTab:SetPoint("TOPLEFT", 10, -70)  -- was -40
f.reservesTab:SetPoint("BOTTOMRIGHT", -10, 60)
f.reservesTab:Hide()

-- Remove old searchBox if exists (if you want to reset, optional)
if f.searchBox then f.searchBox:Hide() f.searchBox = nil end
if f.searchLabel then f.searchLabel:Hide() f.searchLabel = nil end

-- Search label
f.searchLabel = f.reservesTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
f.searchLabel:SetPoint("TOPLEFT", 10, -12)
f.searchLabel:SetText("Search:")

-- Search Box (without InputBoxTemplate to avoid double background)
f.searchBox = CreateFrame("EditBox", LootDistr .. "SearchBox", f.reservesTab)
f.searchBox:SetSize(200, 20)
f.searchBox:SetPoint("LEFT", f.searchLabel, "RIGHT", 6, 0)
f.searchBox:SetAutoFocus(false)
f.searchBox:SetFontObject(ChatFontNormal)
f.searchBox:SetMaxLetters(100)
f.searchBox:SetText("")
f.searchBox:SetScript("OnEscapePressed", function(self)
    self:SetText("")
    self:ClearFocus()
    UpdateReservesTable("")
end)
f.searchBox:SetScript("OnTextChanged", function(self)
    UpdateReservesTable(self:GetText())
end)

-- Clean single backdrop - no InputBoxTemplate
f.searchBox:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
f.searchBox:SetBackdropColor(0, 0, 0, 0.7)
f.searchBox:SetBackdropBorderColor(1, 1, 1, 1)

-- Placeholder text (works in 3.3.5 by setting .SetText with grey color on empty? We'll simulate)
f.searchBox:SetTextInsets(4, 0, 0, 1) -- 8 pixels padding on left, no right/top/bottom padding
f.searchBox:SetTextColor(0.8, 0.8, 0.8, 1) -- more transparent white for placeholder
f.searchBox:SetText(LDData.reservePlaceholder)

-- Create info label right of search box
f.statsLabel = f.reservesTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
f.statsLabel:SetPoint("LEFT", f.searchBox, "RIGHT", 10, 0)
f.statsLabel:SetText("")  -- initially empty

-- ScrollFrame for reserves table (pushed down to make space for search box and header)
f.reservesScroll = CreateFrame("ScrollFrame", LootDistr .. "ReservesScrollFrame", f.reservesTab, "UIPanelScrollFrameTemplate")
f.reservesScroll:SetPoint("TOPLEFT", 0, -65)  -- shifted down for search box + header (header is 20 px height + 10 px spacing)
f.reservesScroll:SetPoint("BOTTOMRIGHT", -25, 40) -- leave space for delete button at bottom

-- Container Frame inside scroll (for table rows)
f.reservesTableContainer = CreateFrame("Frame", LootDistr .. "ReservesTableContainer", f.reservesScroll)
f.reservesTableContainer:SetPoint("TOPLEFT", f.reservesScroll, "TOPLEFT", 0, 0)
f.reservesTableContainer:SetSize(570, 250)
f.reservesScroll:SetScrollChild(f.reservesTableContainer)


-- Container for header buttons
f.reservesHeader = CreateFrame("Frame", LootDistr .. "ReservesHeader", f.reservesTab)
f.reservesHeader:SetSize(570, LDData.rowHeight)
f.reservesHeader:SetPoint("TOPLEFT", f.reservesTab, "TOPLEFT", 10, -40) -- aligns just above scrollframe

local headerButtons = {}
local xOffset = 0
for i, header in ipairs(LDData.headers) do
    local btn = CreateFrame("Button", nil, f.reservesHeader)
    btn:SetSize(header.width, LDData.rowHeight)
    btn:SetPoint("LEFT", f.reservesHeader, "LEFT", xOffset, 0)
    btn.index = i
    btn.sortKey = header.key
    btn:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
    })
    btn:SetBackdropColor(0, 0, 0, 0)

    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.text:SetPoint("CENTER", 0, 0)
    btn.text:SetText(header.text)
    btn.text:SetTextColor(1, 1, 1, 1)

    btn:SetScript("OnClick", LDData.OnLootHeaderClickReserves)
    btn:SetScript("OnEnter", LDData.OnLootHeaderEnter)
    btn:SetScript("OnLeave", LDData.OnLootHeaderLeave)

    headerButtons[i] = btn
    xOffset = xOffset + header.width
end

f.reservesHeader:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
    tile = true,
    tileSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})

-- Delete All Button (new)
f.deleteBtn = CreateFrame("Button", LootDistr .. "deleteBtn", f.reservesTab, "GameMenuButtonTemplate")
f.deleteBtn:SetSize(120, 30)
f.deleteBtn:SetPoint("BOTTOMLEFT", 9, 0)
f.deleteBtn:SetText("Clear All")
f.deleteBtn:SetScript("OnClick", function()
    StaticPopup_Show(LootDistr .. "ConfirmDelete")
end)