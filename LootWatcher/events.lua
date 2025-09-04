local LootDistr, LDData = ...
local f = LDData.main_frame

f.LootWatcherEventFrame = CreateFrame("Frame")
f.LootWatcherEventFrame:RegisterEvent("CHAT_MSG_LOOT")
f.LootWatcherEventFrame:RegisterEvent("CHAT_MSG_MONEY")
f.LootWatcherEventFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
f.LootWatcherEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
f.LootWatcherEventFrame:RegisterEvent("START_LOOT_ROLL")
f.LootWatcherEventFrame:RegisterEvent("LOOT_ROLL_CHANGED")
f.LootWatcherEventFrame:RegisterEvent("LOOT_ROLL_WON")

f.LootWatcherEventFrame:SetScript("OnEvent", function(self, event, msg, ...)
    if event == "PARTY_LOOT_METHOD_CHANGED" then
        local lootMethod, masterLooter = GetLootMethod()

        if GetNumRaidMembers() > 0 and lootMethod == "master" and masterLooter == 0 then
            local currentLocaleText = nil
            for _, locale in ipairs(LDData.localeOptions) do
                if locale.value == LootRollerLocaleSettings then
                    currentLocaleText = locale.text
                end
            end                
            print("|cff00FF00[LootDistributer]|r "..LDData.messages.system.moduleEnabled.." "..string.format(LDData.messages.system.rollAnnounceLocalization, currentLocaleText))
            return
        end

        if GetNumRaidMembers() == 0 or lootMethod ~= "master" or masterLooter ~= 0 then
            print("|cffFF4500[LootDistributer]|r "..LDData.messages.system.moduleDisabled)
        end
        return
    end
    
    if event == "GROUP_ROSTER_UPDATE" then
        for _, option in ipairs(LDData.qualityThresholdOptions) do
            if option.value == LootWatcherThresholdNumber then
                threshold = option.text
            end
        end

        if not LootWatcherActivated and (IsInRaid() or (IsInGroup() and LootRollerAddonSettings.lootWatcherGroupSwitch) or LootRollerAddonSettings.lootWatcherNonGroupSwitch) then
            print("|cff00FF00[LootDistributer]|r "..LDData.messages.system.joinedRaid.." "..threshold)
            LootWatcherActivated = true
        end

        if LootWatcherActivated and not IsInRaid() and not (IsInGroup() and LootRollerAddonSettings.lootWatcherGroupSwitch) and not LootRollerAddonSettings.lootWatcherNonGroupSwitch then
            print("|cffFF4500[LootDistributer]|r "..LDData.messages.system.leftRaid.."")
            LootWatcherActivated = false
        end
        return
    end

    if event == "CHAT_MSG_LOOT" then
        if not msg then return end
        
        local trackLootCheck = false
        if (IsInGroup() and LootRollerAddonSettings.lootWatcherGroupSwitch) or IsInRaid() or LootRollerAddonSettings.lootWatcherNonGroupSwitch then
            trackLootCheck = true
        end

        local sPlayerName, itemLink = msg:match(LDData.messages.regex.playerLoot)
        if not sPlayerName then
            itemLink = msg:match(LDData.messages.regex.selfLoot)
            sPlayerName = playerName
        end

        if trackLootCheck and itemLink then
            local itemID = tonumber(itemLink:match("item:(%d+)"))
            if itemID then
                local itemName = GetItemInfo(itemID)
                if itemName and SoftResSaved[itemID] then
                    SoftResLootedTimestamps[itemID] = time()
                    print("|cff00FF00[LootDistributer]|r Looted " .. itemLink .. " at " .. date("%H:%M:%S") .. ". Soft-reserved.")
                end
            end
        end
        
        if itemLink then
            local lwPlayer, lwItemLink
            lwPlayer, lwItemLink = msg:match(LDData.messages.regex.playerLoot)
            if not lwPlayer then
                lwItemLink = msg:match(LDData.messages.regex.selfLoot)
                lwPlayer = LDData.playerName  -- your player's name variable
            end

            local itemName, itemLink, itemRarity = GetItemInfo(lwItemLink)
            if itemRarity and itemRarity >= LootWatcherThresholdNumber then
                if lwPlayer and lwItemLink then
                    local count = 1
                    local qty = lwItemLink:match("x(%d+)")
                    if qty then count = tonumber(qty) end

                    table.insert(LootWatcherData, {
                        item = lwItemLink,
                        player = lwPlayer,
                        count = count,
                        time = date("%d/%m/%Y %H:%M:%S"),
                        lootMethod = GetLootMethod(),
                        looter = masterLooterName or "Unknown",
                        rolls = {},
                    })

                    TrimLootWatcherData() -- trim old loot records if needed
                    UpdateLootWatcherTable(f.lootSearchBox:GetText())

                    print("|cff00FF00[LootDistributer]|r "..LDData.messages.system.trackedLoot.." |Hplayer:" .. lwPlayer .. "|h|cffFFD100[" .. lwPlayer .. "]|r|h looted " .. lwItemLink)
                end
            end
        end
        return
    end

    if event == "CHAT_MSG_MONEY" then
        if msg:find(LDData.messages.regex.goldShare) then
            local gold = tonumber(msg:match(LDData.messages.regex.gold)) or 0
            local silver = tonumber(msg:match(LDData.messages.regex.silver)) or 0
            local copper = tonumber(msg:match(LDData.messages.regex.copper)) or 0
    
            local total = gold * 10000 + silver * 100 + copper
            if total > 0 then
                LootWatcherGoldGained = (LootWatcherGoldGained or 0) + total
            end
            UpdateLootWatcherTable(f.lootSearchBox:GetText())
        end
        return
    end
end)

function InitializeLootWatcherEvents()
    local f = LDData.main_frame

    -- Confirmation popup for deleting all soft reserve data
    StaticPopupDialogs[LootDistr .. "ConfirmDeleteLootWatcher"] = {
        text = LDData.messages.dialogs.confirmDeleteWatcher,
        button1 = LDData.messages.dialogs.yes,
        button2 = LDData.messages.dialogs.no,
        OnAccept = function()
            LootWatcherData = {}
            LootWatcherGoldGained = 0
            UpdateLootWatcherTable(f.searchBox:GetText())
            print("|cff00FF00[LootDistributer]|r "..LDData.messages.system.lootWatcherDataDeleted)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

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
            UpdateLootWatcherTable("")
        end
    end)

    f.lootSearchBox:SetScript("OnTextChanged", function(self)
        local txt = self:GetText()
        if txt == LDData.lootPlaceholder then txt = "" end
        UpdateLootWatcherTable(txt)
    end)
    
    f.lootSearchBox:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        UpdateLootWatcherTable(text)
        self:ClearFocus()
    end)

    f.lootSearchBox:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
        UpdateLootWatcherTable("")
    end)

end

-- GLOBALS
LDData.InitializeLootWatcherEvents = InitializeLootWatcherEvents