local LootDistr, LDData = ...
local f = LDData.main_frame

function InitializeSettingsUI()
    -- Tab Frame
    f.settingsTab = CreateFrame("Frame", LootDistr .. "SettingsTab", f)
    f.settingsTab:SetPoint("TOPLEFT", 10, -70)  
    f.settingsTab:SetPoint("BOTTOMRIGHT", -10, 60)
    f.settingsTab:Hide()

    -- Title
    f.settingsTab.globalTitle = f.settingsTab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.settingsTab.globalTitle:SetPoint("TOPLEFT", 10, -10)
    f.settingsTab.globalTitle:SetText("Global Settings")

    -- === MAIN CHECKBOX ===
    f.settingsTab.autoLootSwitch = CreateFrame("CheckButton", LootDistr .. "AutoLootSwitch", f.settingsTab, "ChatConfigCheckButtonTemplate")
    f.settingsTab.autoLootSwitch:SetPoint("TOPLEFT", f.settingsTab.globalTitle, "BOTTOMLEFT", 0, -10)
    f.settingsTab.autoLootSwitch:SetChecked(LootRollerAddonSettings.autoLootSwitch or false)
    f.settingsTab.autoLootSwitch.tooltip = "Automatically switch loot to 'Master Looter' whenever boss level mob is targeted and change it back when not."
    f.settingsTab.autoLootSwitch:SetScript("OnClick", function(self)
        LootRollerAddonSettings.autoLootSwitch = self:GetChecked()
        LDData.UpdateAutoLootMethodSwitch()

        -- Enable/disable the suboption when toggled
        if self:GetChecked() then
            f.settingsTab.disableLootSwitchFor10Man:Enable()
            f.settingsTab.disableLootSwitchForNonRaidGroup:Enable()
            f.settingsTab.disableLootSwitchFor10Man.text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
            f.settingsTab.disableLootSwitchForNonRaidGroup.text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
        else
            f.settingsTab.disableLootSwitchFor10Man:Disable()
            f.settingsTab.disableLootSwitchForNonRaidGroup:Disable()
            f.settingsTab.disableLootSwitchFor10Man.text:SetTextColor(0.5, 0.5, 0.5)
            f.settingsTab.disableLootSwitchForNonRaidGroup.text:SetTextColor(0.5, 0.5, 0.5)
        end
    end)

    f.settingsTab.autoLootSwitch.text = f.settingsTab.autoLootSwitch:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.settingsTab.autoLootSwitch.text:SetPoint("LEFT", f.settingsTab.autoLootSwitch, "RIGHT", 4, 0)
    f.settingsTab.autoLootSwitch.text:SetText("Auto-switch loot method")

    -- === SUBOPTION CHECKBOX 1 ===
    f.settingsTab.disableLootSwitchFor10Man = CreateFrame("CheckButton", LootDistr .. "disableLootSwitchFor10Man", f.settingsTab, "ChatConfigCheckButtonTemplate")
    f.settingsTab.disableLootSwitchFor10Man:SetPoint("TOPLEFT", f.settingsTab.autoLootSwitch, "BOTTOMLEFT", 20, 0) -- indented
    f.settingsTab.disableLootSwitchFor10Man:SetChecked(LootRollerAddonSettings.disableLootSwitchFor10Man or false)
    f.settingsTab.disableLootSwitchFor10Man.tooltip = "Disables this functionality when in 10-man raids."
    f.settingsTab.disableLootSwitchFor10Man:SetScale(0.9)
    f.settingsTab.disableLootSwitchFor10Man:SetScript("OnClick", function(self)
        LootRollerAddonSettings.disableLootSwitchFor10Man = self:GetChecked()
    end)

    f.settingsTab.disableLootSwitchFor10Man.text = f.settingsTab.disableLootSwitchFor10Man:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.settingsTab.disableLootSwitchFor10Man.text:SetPoint("LEFT", f.settingsTab.disableLootSwitchFor10Man, "RIGHT", 4, 0)
    f.settingsTab.disableLootSwitchFor10Man.text:SetText("Disable for 10-man")

    -- Disable suboption visually if parent is unchecked
    if not LootRollerAddonSettings.autoLootSwitch then
        f.settingsTab.disableLootSwitchFor10Man:Disable()
        f.settingsTab.disableLootSwitchFor10Man.text:SetTextColor(0.5, 0.5, 0.5)
    end

    -- === SUBOPTION CHECKBOX 2 ===
    f.settingsTab.disableLootSwitchForNonRaidGroup = CreateFrame("CheckButton", LootDistr .. "disableLootSwitchForNonRaidGroup", f.settingsTab, "ChatConfigCheckButtonTemplate")
    f.settingsTab.disableLootSwitchForNonRaidGroup:SetPoint("TOPLEFT", f.settingsTab.autoLootSwitch, "BOTTOMLEFT", 20, -20) -- indented
    f.settingsTab.disableLootSwitchForNonRaidGroup:SetChecked(LootRollerAddonSettings.disableLootSwitchForNonRaidGroup or false)
    f.settingsTab.disableLootSwitchForNonRaidGroup.tooltip = "Disables this functionality when not in raid group."
    f.settingsTab.disableLootSwitchForNonRaidGroup:SetScale(0.9)
    f.settingsTab.disableLootSwitchForNonRaidGroup:SetScript("OnClick", function(self)
        LootRollerAddonSettings.disableLootSwitchForNonRaidGroup = self:GetChecked()
    end)

    f.settingsTab.disableLootSwitchForNonRaidGroup.text = f.settingsTab.disableLootSwitchForNonRaidGroup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.settingsTab.disableLootSwitchForNonRaidGroup.text:SetPoint("LEFT", f.settingsTab.disableLootSwitchForNonRaidGroup, "RIGHT", 4, 0)
    f.settingsTab.disableLootSwitchForNonRaidGroup.text:SetText("Disable for non-raid groups")

    -- Disable suboption visually if parent is unchecked
    if not LootRollerAddonSettings.autoLootSwitch then
        f.settingsTab.disableLootSwitchForNonRaidGroup:Disable()
        f.settingsTab.disableLootSwitchForNonRaidGroup.text:SetTextColor(0.5, 0.5, 0.5)
    end

    -- Auto Loot Items (your existing checkbox)
    f.settingsTab.autoLootItems = CreateFrame("CheckButton", LootDistr .. "AutoLootItems", f.settingsTab, "ChatConfigCheckButtonTemplate")
    f.settingsTab.autoLootItems:SetPoint("TOPLEFT", f.settingsTab.globalTitle, "BOTTOMLEFT", 0, -75)
    f.settingsTab.autoLootItems:SetChecked(LootRollerAddonSettings.autoLootItems or false)
    f.settingsTab.autoLootItems.tooltip = "Automatically loot all items to yourself if you are assigned as Master Looter. Works both in raid and non-raid groups."
    f.settingsTab.autoLootItems:SetScript("OnClick", function(self)
        LootRollerAddonSettings.autoLootItems = self:GetChecked()
        LDData.UpdateAutoLootItems()
    end)

    f.settingsTab.autoLootItems.text = f.settingsTab.autoLootItems:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.settingsTab.autoLootItems.text:SetPoint("LEFT", f.settingsTab.autoLootItems, "RIGHT", 4, 0)
    f.settingsTab.autoLootItems.text:SetText("Auto Loot Items")

    LDData.UpdateAutoLootMethodSwitch()
    LDData.UpdateAutoLootItems()

    -- Loot Watcher Title
    f.settingsTab.lootWatcherSettingsTitle = f.settingsTab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.settingsTab.lootWatcherSettingsTitle:SetPoint("TOPLEFT", 10, -140)
    f.settingsTab.lootWatcherSettingsTitle:SetText("Loot Watcher Settings")


    f.settingsTab.lootWatcherGroupSwitch = CreateFrame("CheckButton", LootDistr .. "LootWatcherGroupSwitch", f.settingsTab, "ChatConfigCheckButtonTemplate")
    f.settingsTab.lootWatcherGroupSwitch:SetPoint("TOPLEFT", f.settingsTab.lootWatcherSettingsTitle, "BOTTOMLEFT", 0, -10)
    f.settingsTab.lootWatcherGroupSwitch:SetChecked(LootRollerAddonSettings.lootWatcherGroupSwitch or false)
    f.settingsTab.lootWatcherGroupSwitch.tooltip = "Checking this option will make Loot Watcher track loot while in non-raid groups."
    f.settingsTab.lootWatcherGroupSwitch:SetScript("OnClick", function(self)
        LootRollerAddonSettings.lootWatcherGroupSwitch = self:GetChecked()
    end)

    f.settingsTab.lootWatcherGroupSwitch.text = f.settingsTab.lootWatcherGroupSwitch:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.settingsTab.lootWatcherGroupSwitch.text:SetPoint("LEFT", f.settingsTab.lootWatcherGroupSwitch, "RIGHT", 4, 0)
    f.settingsTab.lootWatcherGroupSwitch.text:SetText("Non-raid tracking")


    f.settingsTab.lootWatcherNonGroupSwitch = CreateFrame("CheckButton", LootDistr .. "LootWatcherNonGroupSwitch", f.settingsTab, "ChatConfigCheckButtonTemplate")
    f.settingsTab.lootWatcherNonGroupSwitch:SetPoint("TOPLEFT", f.settingsTab.lootWatcherSettingsTitle, "BOTTOMLEFT", 0, -30)
    f.settingsTab.lootWatcherNonGroupSwitch:SetChecked(LootRollerAddonSettings.lootWatcherNonGroupSwitch or false)
    f.settingsTab.lootWatcherNonGroupSwitch.tooltip = "Checking this option will make Loot Watcher ALWAYS track loot."
    f.settingsTab.lootWatcherNonGroupSwitch:SetScript("OnClick", function(self)
        LootRollerAddonSettings.lootWatcherNonGroupSwitch = self:GetChecked()
    end)

    f.settingsTab.lootWatcherNonGroupSwitch.text = f.settingsTab.lootWatcherNonGroupSwitch:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.settingsTab.lootWatcherNonGroupSwitch.text:SetPoint("LEFT", f.settingsTab.lootWatcherNonGroupSwitch, "RIGHT", 4, 0)
    f.settingsTab.lootWatcherNonGroupSwitch.text:SetText("Non-group tracking")
end


-- GLOBALS
LDData.InitializeSettingsUI = InitializeSettingsUI
