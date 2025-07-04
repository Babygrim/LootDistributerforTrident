local addonName, addonTable = ...

-- Main frame
local f = CreateFrame("Frame", addonName .. "MainFrame", UIParent)
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
















-- CSV Import Tab Frame
f.csvTab = CreateFrame("Frame", addonName .. "CsvTab", f)
f.csvTab:SetPoint("TOPLEFT", 10, -70)       -- was -40
f.csvTab:SetPoint("BOTTOMRIGHT", -10, 60)

-- Create scroll frame inside CSV tab
f.csvScroll = CreateFrame("ScrollFrame", addonName .. "CsvScrollFrame", f.csvTab, "UIPanelScrollFrameTemplate")
f.csvScroll:SetPoint("TOPLEFT", 10, -10)
f.csvScroll:SetPoint("BOTTOMRIGHT", -30, 40) -- reserve space for Import button

-- Create edit box inside scroll frame
f.csvEditBox = CreateFrame("EditBox", addonName .. "CsvEditBox", f.csvScroll)
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

-- Escape to hide
f.csvEditBox:SetScript("OnEscapePressed", function() f:Hide() end)

-- Import CSV Button
f.importBtn = CreateFrame("Button", addonName .. "ImportBtn", f.csvTab, "GameMenuButtonTemplate")
f.importBtn:SetSize(120, 30)
f.importBtn:SetPoint("BOTTOMLEFT", 9, 0)
f.importBtn:SetText("Import CSV")
















-- Reserves Tab Frame
f.reservesTab = CreateFrame("Frame", addonName .. "ReservesTab", f)
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
f.searchBox = CreateFrame("EditBox", addonName .. "SearchBox", f.reservesTab)
f.searchBox:SetSize(200, 20)
f.searchBox:SetPoint("LEFT", f.searchLabel, "RIGHT", 6, 0)
f.searchBox:SetAutoFocus(false)
f.searchBox:SetFontObject(ChatFontNormal)
f.searchBox:SetMaxLetters(100)
f.searchBox:SetText("")
f.searchBox:SetScript("OnEscapePressed", function(self)
    self:SetText("")
    self:ClearFocus()
    addonTable.UpdateReservesTable("")
end)
f.searchBox:SetScript("OnTextChanged", function(self)
    addonTable.UpdateReservesTable(self:GetText())
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
f.searchBox:SetText(addonTable.reservePlaceholder)

-- Create info label right of search box
f.statsLabel = f.reservesTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
f.statsLabel:SetPoint("LEFT", f.searchBox, "RIGHT", 10, 0)
f.statsLabel:SetText("")  -- initially empty

-- ScrollFrame for reserves table (pushed down to make space for search box and header)
f.reservesScroll = CreateFrame("ScrollFrame", addonName .. "ReservesScrollFrame", f.reservesTab, "UIPanelScrollFrameTemplate")
f.reservesScroll:SetPoint("TOPLEFT", 0, -65)  -- shifted down for search box + header (header is 20 px height + 10 px spacing)
f.reservesScroll:SetPoint("BOTTOMRIGHT", -25, 40) -- leave space for delete button at bottom

-- Container Frame inside scroll (for table rows)
f.reservesTableContainer = CreateFrame("Frame", addonName .. "ReservesTableContainer", f.reservesScroll)
f.reservesTableContainer:SetPoint("TOPLEFT", f.reservesScroll, "TOPLEFT", 0, 0)
f.reservesTableContainer:SetSize(570, 250)
f.reservesScroll:SetScrollChild(f.reservesTableContainer)

f.searchBox:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == addonTable.reservePlaceholder then
        self:SetText("")
        self:SetTextColor(1, 1, 1, 1)
    end
    f.reservesScroll:SetVerticalScroll(0)
end)

f.searchBox:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then
        self:SetTextColor(0.8, 0.8, 0.8, 1)
        self:SetText(addonTable.reservePlaceholder)
        addonTable.UpdateReservesTable("")
    end
end)


-- Container for header buttons
f.reservesHeader = CreateFrame("Frame", addonName .. "ReservesHeader", f.reservesTab)
f.reservesHeader:SetSize(570, addonTable.rowHeight)
f.reservesHeader:SetPoint("TOPLEFT", f.reservesTab, "TOPLEFT", 10, -40) -- aligns just above scrollframe

local headerButtons = {}

local function OnHeaderClick(self)
    local key = self.sortKey
    if addonTable.currentSort.column == key then
        addonTable.currentSort.ascending = not addonTable.currentSort.ascending
    else
        addonTable.currentSort.column = key
        addonTable.currentSort.ascending = true
    end
    addonTable.UpdateReservesTable(f.searchBox:GetText())
end


local function OnHeaderEnter(self)
    self.text:SetTextColor(1, 1, 0, 1) -- yellow highlight on hover
    self:SetBackdropColor(0.3, 0.3, 0.3, 0.5)
end

local function OnHeaderLeave(self)
    self.text:SetTextColor(1, 1, 1, 1) -- white normal color
    self:SetBackdropColor(0, 0, 0, 0)
end


local xOffset = 0
for i, header in ipairs(addonTable.headers) do
    local btn = CreateFrame("Button", nil, f.reservesHeader)
    btn:SetSize(header.width, addonTable.rowHeight)
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

    btn:SetScript("OnClick", OnHeaderClick)
    btn:SetScript("OnEnter", OnHeaderEnter)
    btn:SetScript("OnLeave", OnHeaderLeave)

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
f.deleteBtn = CreateFrame("Button", addonName .. "deleteBtn", f.reservesTab, "GameMenuButtonTemplate")
f.deleteBtn:SetSize(120, 30)
f.deleteBtn:SetPoint("BOTTOMLEFT", 9, 0)
f.deleteBtn:SetText("Clear All")
f.deleteBtn:SetScript("OnClick", function()
    StaticPopup_Show(addonName .. "ConfirmDelete")
end)






-- Loot Watcher Tab Frame
f.lootWatcherTab = CreateFrame("Frame", addonName .. "LootWatcherTab", f)
f.lootWatcherTab:SetPoint("TOPLEFT", 10, -70)
f.lootWatcherTab:SetPoint("BOTTOMRIGHT", -10, 60)
f.lootWatcherTab:Hide()

-- Search Label
f.lootSearchLabel = f.lootWatcherTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
f.lootSearchLabel:SetPoint("TOPLEFT", 10, -12)
f.lootSearchLabel:SetText("Search:")

-- Search Box
f.lootSearchBox = CreateFrame("EditBox", addonName .. "LootSearchBox", f.lootWatcherTab)
f.lootSearchBox:SetSize(200, 20)
f.lootSearchBox:SetPoint("LEFT", f.lootSearchLabel, "RIGHT", 6, 0)
f.lootSearchBox:SetAutoFocus(false)
f.lootSearchBox:SetFontObject(ChatFontNormal)
f.lootSearchBox:SetMaxLetters(100)
f.lootSearchBox:SetScript("OnEscapePressed", function(self)
    self:SetText("")
    self:ClearFocus()
    addonTable.UpdateLootWatcherTable("")
end)

f.lootSearchBox:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
f.lootSearchBox:SetBackdropColor(0, 0, 0, 0.7)
f.lootSearchBox:SetBackdropBorderColor(1, 1, 1, 1)


f.lootSearchBox:SetTextColor(0.8, 0.8, 0.8, 1)
f.lootSearchBox:SetText(addonTable.lootPlaceholder)
f.lootSearchBox:SetTextInsets(4, 0, 0, 1)

f.lootSearchBox:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == addonTable.lootPlaceholder then
        self:SetText("")
        self:SetTextColor(1, 1, 1, 1)
    end
    f.lootScroll:SetVerticalScroll(0)
end)
f.lootSearchBox:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then
        self:SetTextColor(0.8, 0.8, 0.8, 1)
        self:SetText(addonTable.lootPlaceholder)
        addonTable.UpdateLootWatcherTable("")
    end
end)
f.lootSearchBox:SetScript("OnTextChanged", function(self)
    local txt = self:GetText()
    if txt == addonTable.lootPlaceholder then txt = "" end
    addonTable.UpdateLootWatcherTable(txt)
end)

-- Stats Label (Gold Tracker)
f.lootStatsLabel = f.lootWatcherTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
f.lootStatsLabel:SetPoint("LEFT", f.lootSearchBox, "RIGHT", 10, 0)
f.lootStatsLabel:SetText("")

-- ScrollFrame
f.lootScroll = CreateFrame("ScrollFrame", addonName .. "LootScrollFrame", f.lootWatcherTab, "UIPanelScrollFrameTemplate")
f.lootScroll:SetPoint("TOPLEFT", 0, -65)
f.lootScroll:SetPoint("BOTTOMRIGHT", -25, 40)

-- Table Container
f.lootTableContainer = CreateFrame("Frame", addonName .. "LootTableContainer", f.lootScroll)
f.lootTableContainer:SetSize(570, 250)
f.lootScroll:SetScrollChild(f.lootTableContainer)

-- Headers


f.lootHeader = CreateFrame("Frame", addonName .. "LootHeader", f.lootWatcherTab)
f.lootHeader:SetSize(570, 20)
f.lootHeader:SetPoint("TOPLEFT", f.lootWatcherTab, "TOPLEFT", 10, -40)
f.lootHeader:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
    tile = true,
    tileSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})

local lootHeaderButtons = {}

local function OnLootHeaderClick(self)
    local key = self.sortKey
    if addonTable.currentLootSort.column == key then
        addonTable.currentLootSort.ascending = not addonTable.currentLootSort.ascending
    else
        addonTable.currentLootSort.column = key
        addonTable.currentLootSort.ascending = true
    end
    addonTable.UpdateLootWatcherTable(f.lootSearchBox:GetText())
end

local function OnLootHeaderEnter(self)
    self.text:SetTextColor(1, 1, 0, 1)
    self:SetBackdropColor(0.3, 0.3, 0.3, 0.5)
end

local function OnLootHeaderLeave(self)
    self.text:SetTextColor(1, 1, 1, 1)
    self:SetBackdropColor(0, 0, 0, 0)
end

local xOff = 0
for i, header in ipairs(addonTable.lootHeaders) do
    local btn = CreateFrame("Button", nil, f.lootHeader)
    btn:SetSize(header.width, 20)
    btn:SetPoint("LEFT", f.lootHeader, "LEFT", xOff, 0)
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

    btn:SetScript("OnClick", OnLootHeaderClick)
    btn:SetScript("OnEnter", OnLootHeaderEnter)
    btn:SetScript("OnLeave", OnLootHeaderLeave)

    lootHeaderButtons[i] = btn
    xOff = xOff + header.width
end

f.lootDeleteBtn = CreateFrame("Button", addonName .. "LootDeleteBtn", f.lootWatcherTab, "GameMenuButtonTemplate")
f.lootDeleteBtn:SetSize(120, 30)
f.lootDeleteBtn:SetPoint("BOTTOMLEFT", 9, 0)
f.lootDeleteBtn:SetText("Clear All")
f.lootDeleteBtn:SetScript("OnClick", function()
    StaticPopup_Show(addonName .. "ConfirmDeleteLootWatcher")
end)









-- GLOBALS
addonTable.main_frame = f