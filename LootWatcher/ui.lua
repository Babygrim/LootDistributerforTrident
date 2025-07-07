local LootDistr, LDData = ...
local f = LDData.main_frame

-- Loot Watcher Tab Frame
f.lootWatcherTab = CreateFrame("Frame", LootDistr .. "LootWatcherTab", f)
f.lootWatcherTab:SetPoint("TOPLEFT", 10, -70)
f.lootWatcherTab:SetPoint("BOTTOMRIGHT", -10, 60)
f.lootWatcherTab:Hide()

-- Search Label
f.lootSearchLabel = f.lootWatcherTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
f.lootSearchLabel:SetPoint("TOPLEFT", 10, -12)
f.lootSearchLabel:SetText("Search:")

-- Search Box
f.lootSearchBox = CreateFrame("EditBox", LootDistr .. "LootSearchBox", f.lootWatcherTab)
f.lootSearchBox:SetSize(200, 20)
f.lootSearchBox:SetPoint("LEFT", f.lootSearchLabel, "RIGHT", 6, 0)
f.lootSearchBox:SetAutoFocus(false)
f.lootSearchBox:SetFontObject(ChatFontNormal)
f.lootSearchBox:SetMaxLetters(100)
f.lootSearchBox:SetScript("OnEscapePressed", function(self)
    self:SetText("")
    self:ClearFocus()
    LDData.UpdateLootWatcherTable("")
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
f.lootSearchBox:SetText(LDData.lootPlaceholder)
f.lootSearchBox:SetTextInsets(4, 0, 0, 1)

f.lootSearchBox:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == LDData.lootPlaceholder then
        self:SetText("")
        self:SetTextColor(1, 1, 1, 1)
    end
    f.lootScroll:SetVerticalScroll(0)
end)
f.lootSearchBox:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then
        self:SetTextColor(0.8, 0.8, 0.8, 1)
        self:SetText(LDData.lootPlaceholder)
        LDData.UpdateLootWatcherTable("")
    end
end)
f.lootSearchBox:SetScript("OnTextChanged", function(self)
    local txt = self:GetText()
    if txt == LDData.lootPlaceholder then txt = "" end
    LDData.UpdateLootWatcherTable(txt)
end)

-- Stats Label (Gold Tracker)
f.lootStatsLabel = f.lootWatcherTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
f.lootStatsLabel:SetPoint("LEFT", f.lootSearchBox, "RIGHT", 10, 0)
f.lootStatsLabel:SetText("")

-- ScrollFrame
f.lootScroll = CreateFrame("ScrollFrame", LootDistr .. "LootScrollFrame", f.lootWatcherTab, "UIPanelScrollFrameTemplate")
f.lootScroll:SetPoint("TOPLEFT", 0, -65)
f.lootScroll:SetPoint("BOTTOMRIGHT", -25, 40)

-- Table Container
f.lootTableContainer = CreateFrame("Frame", LootDistr .. "LootTableContainer", f.lootScroll)
f.lootTableContainer:SetSize(570, 250)
f.lootScroll:SetScrollChild(f.lootTableContainer)

-- Headers


f.lootHeader = CreateFrame("Frame", LootDistr .. "LootHeader", f.lootWatcherTab)
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
    if LDData.currentLootSort.column == key then
        LDData.currentLootSort.ascending = not LDData.currentLootSort.ascending
    else
        LDData.currentLootSort.column = key
        LDData.currentLootSort.ascending = true
    end
    LDData.UpdateLootWatcherTable(f.lootSearchBox:GetText())
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
for i, header in ipairs(LDData.lootHeaders) do
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

f.lootDeleteBtn = CreateFrame("Button", LootDistr .. "LootDeleteBtn", f.lootWatcherTab, "GameMenuButtonTemplate")
f.lootDeleteBtn:SetSize(120, 30)
f.lootDeleteBtn:SetPoint("BOTTOMLEFT", 9, 0)
f.lootDeleteBtn:SetText("Clear All")
f.lootDeleteBtn:SetScript("OnClick", function()
    StaticPopup_Show(LootDistr .. "ConfirmDeleteLootWatcher")
end)