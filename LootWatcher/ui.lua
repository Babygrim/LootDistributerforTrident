local LootDistr, LDData = ...

function InitializeLootWatcherUI()
    local f = LDData.main_frame
    -- Loot Watcher Tab Frame
    f.lootWatcherTab = CreateFrame("Frame", LootDistr .. "LootWatcherTab", f)
    f.lootWatcherTab:SetPoint("TOPLEFT", 10, -70)
    f.lootWatcherTab:SetPoint("BOTTOMRIGHT", -10, 60)
    f.lootWatcherTab:Hide()

    -- Search Box
    f.lootSearchBox = CreateFrame("EditBox", LootDistr .. "LootSearchBox", f.lootWatcherTab)
    f.lootSearchBox:SetSize(200, 20)
    -- f.lootSearchBox:SetPoint("LEFT", f.lootSearchLabel, "RIGHT", 6, 0)
    f.lootSearchBox:SetPoint("TOPLEFT", 10, -12)
    f.lootSearchBox:SetAutoFocus(false)
    f.lootSearchBox:SetFontObject(ChatFontNormal)
    f.lootSearchBox:SetMaxLetters(100)

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

    f.lootWatcherDropdown = CreateFrame("Frame", "LootDistributerLootWatcherDropdown", f.lootWatcherTab, "UIDropDownMenuTemplate")
    f.lootWatcherDropdown:SetPoint("LEFT", f.lootSearchBox, "RIGHT", -10, -2)
    f.lootWatcherDropdown:SetWidth(140)

    -- Function to update dropdown display text based on checked option
    local function UpdateDropdownText()
        for _, option in ipairs(LDData.qualityThresholdOptions) do
            if LootWatcherThresholdNumber == option.value then
                UIDropDownMenu_SetText(f.lootWatcherDropdown, option.text)
                break
            end
        end
    end

    -- Dropdown initialize function
    local function LootWatcherDropdown(self, level)
        local info = UIDropDownMenu_CreateInfo()
        
        for _, option in ipairs(LDData.qualityThresholdOptions) do
            info.text = option.text
            info.value = option.value
            info.func = function(self)
                if LootWatcherThresholdNumber ~= self.value then
                    LootWatcherThresholdNumber = self.value
                    print("|cff00FF00[LootDistributer]|r Loot parsing threshold changed to: " .. self:GetText())
                    UpdateLootWatcherTable(f.lootSearchBox:GetText())
                    UpdateDropdownText() -- Update display text when selection changes
                end
                CloseDropDownMenus()
            end
            if LootWatcherThresholdNumber == option.value then
                info.checked = (LootWatcherThresholdNumber == option.value)
                UIDropDownMenu_SetText(f.lootWatcherDropdown, option.text)
            else
                info.checked = (LootWatcherThresholdNumber == option.value)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(f.lootWatcherDropdown, LootWatcherDropdown)

    -- Set initial display text
    UpdateDropdownText()

    -- Stats Label (Gold Tracker)
    f.lootStatsLabel = f.lootWatcherTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.lootStatsLabel:SetPoint("LEFT", f.lootWatcherDropdown, "RIGHT", 15, 2)
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

        btn:SetScript("OnClick", LDData.OnLootHeaderClickWatcher)
        btn:SetScript("OnEnter", LDData.OnLootHeaderEnter)
        btn:SetScript("OnLeave", LDData.OnLootHeaderLeave)

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
end

-- GLOBALS
LDData.InitializeLootWatcherUI = InitializeLootWatcherUI