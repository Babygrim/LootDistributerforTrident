local LootDistr, LDData = ...

function InitializeLootRollerUI()
    local f = LDData.main_frame

    -- Loot Roller Tab
    f.lootRollerTab = CreateFrame("Frame", LootDistr .. "LootRollerTab", f)
    f.lootRollerTab:SetPoint("TOPLEFT", 10, -70)
    f.lootRollerTab:SetPoint("BOTTOMRIGHT", -10, 60)
    f.lootRollerTab:Hide()

    -- Item Icon
    f.lootRollerItemIcon = f.lootRollerTab:CreateTexture(nil, "ARTWORK")
    f.lootRollerItemIcon:SetSize(60,60)
    f.lootRollerItemIcon:SetPoint("TOPLEFT", 10, -10)
    f.lootRollerItemIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

    -- Create a clickable item name button frame (with tooltip)
    f.lootRollerItemNameFrame = CreateFrame("Button", nil, f.lootRollerTab)
    f.lootRollerItemNameFrame:SetPoint("TOPLEFT", f.lootRollerItemIcon, "TOPRIGHT", 5, 0)
    f.lootRollerItemNameFrame:SetSize(250, 15)
    f.lootRollerItemNameFrame:EnableMouse(true)
    f.lootRollerItemNameFrame:SetFrameLevel(f.lootRollerItemNameFrame:GetFrameLevel() + 1)
    f.lootRollerItemNameFrame:SetFrameStrata("HIGH")

    -- FontString: Item Name (linked)
    f.lootRollerItemNameText = f.lootRollerItemNameFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.lootRollerItemNameText:SetPoint("TOPLEFT", f.lootRollerItemNameFrame, "TOPLEFT", 0, 0)
    f.lootRollerItemNameText:SetJustifyH("LEFT")
    f.lootRollerItemNameText:SetWidth(250)

    -- FontString: ID
    f.lootRollerItemIDText = f.lootRollerTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.lootRollerItemIDText:SetPoint("TOPLEFT", f.lootRollerItemNameText, "BOTTOMLEFT", 0, -2)
    f.lootRollerItemIDText:SetJustifyH("LEFT")
    f.lootRollerItemIDText:SetWidth(300)

    -- FontString: Source
    f.lootRollerItemSourceText = f.lootRollerTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.lootRollerItemSourceText:SetPoint("TOPLEFT", f.lootRollerItemIDText, "BOTTOMLEFT", 0, -2)
    f.lootRollerItemSourceText:SetJustifyH("LEFT")
    f.lootRollerItemSourceText:SetWidth(300)

    -- FontString: iLvl
    f.lootRollerItemIlvlText = f.lootRollerTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.lootRollerItemIlvlText:SetPoint("TOPLEFT", f.lootRollerItemSourceText, "BOTTOMLEFT", 0, -2)
    f.lootRollerItemIlvlText:SetJustifyH("LEFT")
    f.lootRollerItemIlvlText:SetWidth(300)

    f.localeLabelRoller = f.lootRollerTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.localeLabelRoller:SetPoint("LEFT", f.lootRollerItemNameText, "RIGHT", -60, 0)
    f.localeLabelRoller:SetJustifyH("RIGHT")
    f.localeLabelRoller:SetText("Announcements locale")
    f.localeLabelRoller:SetWidth(300)

    f.lootRollerDropdown = CreateFrame("Frame", "LootDistributerlootRollerDropdown", f.lootRollerTab, "UIDropDownMenuTemplate")
    f.lootRollerDropdown:SetPoint("LEFT", f.lootRollerItemIDText, "RIGHT", 45, -10)
    f.lootRollerDropdown:SetWidth(140)

    -- Function to update dropdown display text based on checked option
    local function UpdateDropdownText()
        for _, option in ipairs(LDData.localeOptions) do
            if LootRollerLocaleSettings == option.value then
                UIDropDownMenu_SetText(f.lootRollerDropdown, option.text)
                break
            end
        end
    end

    -- Dropdown initialize function
    local function lootRollerDropdown(self, level)
        local info = UIDropDownMenu_CreateInfo()
        
        for _, option in ipairs(LDData.localeOptions) do
            info.text = option.text
            info.value = option.value
            info.func = function(self)
                if LootRollerLocaleSettings ~= self.value then
                    LootRollerLocaleSettings = self.value
                    print("|cff00FF00[LootDistributer]|r Loot Roll announcements locale changed to: " .. self:GetText())
                    UpdateLootWatcherTable(f.lootSearchBox:GetText())
                    UpdateDropdownText() -- Update display text when selection changes
                end
                CloseDropDownMenus()
            end
            if LootRollerLocaleSettings == option.value then
                info.checked = (LootRollerLocaleSettings == option.value)
                UIDropDownMenu_SetText(f.lootRollerDropdown, option.text)
            else
                info.checked = (LootRollerLocaleSettings == option.value)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(f.lootRollerDropdown, lootRollerDropdown)

    -- Set initial display text
    UpdateDropdownText()

    -- Scroll Frame for rolls table
    f.scrollFrame = CreateFrame("ScrollFrame", LootDistr .. "LootRollerScrollFrame", f.lootRollerTab, "UIPanelScrollFrameTemplate")
    f.scrollFrame:SetPoint("TOPLEFT", 0, -110)
    f.scrollFrame:SetPoint("BOTTOMRIGHT", -25, 40)

    -- Scroll content (table container)
    f.scrollContent = CreateFrame("Frame", LootDistr .. "LootRollerScrollContent", f.scrollFrame)
    f.scrollContent:SetSize(f.scrollFrame:GetWidth(), 300)
    f.scrollFrame:SetScrollChild(f.scrollContent)

    -- Column Headers
    f.lootRollHeader = CreateFrame("Frame", LootDistr .. "LootRollHeader", f.lootRollerTab)
    f.lootRollHeader:SetSize(570, 20)
    f.lootRollHeader:SetPoint("TOPLEFT", f.lootRollerTab, "TOPLEFT", 10, -85)
    f.lootRollHeader:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        tile = true,
        tileSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })

    local lootRollHeaderButtons = {}
    local xOff = 0
    for i, header in ipairs(LDData.lootRollHeaders) do
        local btn = CreateFrame("Button", nil, f.lootRollHeader)
        btn:SetSize(header.width, 20)
        btn:SetPoint("LEFT", f.lootRollHeader, "LEFT", xOff, 0)
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

        btn:SetScript("OnEnter", LDData.OnLootHeaderEnter)
        btn:SetScript("OnLeave", LDData.OnLootHeaderLeave)

        lootRollHeaderButtons[i] = btn
        xOff = xOff + header.width
    end

    f.lootRollEndBtn = CreateFrame("Button", LootDistr .. "LootRollEndBtn", f.lootRollerTab, "GameMenuButtonTemplate")
    f.lootRollEndBtn:SetSize(120, 30)
    f.lootRollEndBtn:SetPoint("BOTTOMLEFT", 9, 0)
    f.lootRollEndBtn:SetText("End Roll")

    f.lootReRollBtn = CreateFrame("Button", LootDistr .. "LootReRollBtn", f.lootRollerTab, "GameMenuButtonTemplate")
    f.lootReRollBtn:SetSize(120, 30)
    f.lootReRollBtn:SetPoint("BOTTOMLEFT", 140, 0)
    f.lootReRollBtn:SetText("Re-Roll")
    f.lootReRollBtn:Disable()
end

-- GLOBALS
LDData.InitializeLootRollerUI = InitializeLootRollerUI