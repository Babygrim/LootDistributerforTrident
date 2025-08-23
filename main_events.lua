local LootDistr, LDData = ...
local f = LDData.main_frame
local LootWatcherActivated = false

f.eventFrame = CreateFrame("Frame")
f.eventFrame:RegisterEvent("ADDON_LOADED")
f.eventFrame:RegisterEvent("CHAT_MSG_LOOT")
f.eventFrame:RegisterEvent("CHAT_MSG_MONEY")
f.eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
f.eventFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")


f.eventFrame:SetScript("OnEvent", function(self, event, msg, ...)
    if event == "ADDON_LOADED" and msg == LootDistr then
        LDData.InitializeAddonCore()
    end

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
    
    if event == "RAID_ROSTER_UPDATE" then
        for _, option in ipairs(LDData.qualityThresholdOptions) do
            if option.value == LootWatcherThresholdNumber then
                threshold = option.text
            end
        end

        if GetNumRaidMembers() > 0 and not LootWatcherActivated then
            print("|cff00FF00[LootDistributer]|r "..LDData.messages.system.joinedRaid.." "..threshold)
            LootWatcherActivated = true
        end

        if GetNumRaidMembers() == 0 and LootWatcherActivated then
            print("|cffFF4500[LootDistributer]|r "..LDData.messages.system.leftRaid.."")
            LootWatcherActivated = false
        end
        return
    end

    if event == "CHAT_MSG_LOOT" then
        if not msg then return end

        -- Your loot parsing logic here:
        local sPlayerName, itemLink = msg:match(LDData.messages.regex.playerLoot)
        if not sPlayerName then
            itemLink = msg:match(LDData.messages.regex.selfLoot)
            sPlayerName = playerName
        end

        if itemLink then
            local itemID = tonumber(itemLink:match("item:(%d+)"))
            if itemID then
                local itemName = GetItemInfo(itemID)
                if itemName and SoftResSaved[itemID] then
                    SoftResLootedTimestamps[itemID] = time()
                    print("|cff00FF00[LootDistributer]|r Looted " .. itemLink .. " at " .. date("%H:%M:%S") .. ". Soft-reserved.")
                end
            end
        end
        
        if GetNumRaidMembers() > 0 and itemLink then
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

    if event == "LOOT_OPENED" then
        LDData.OnLootingMasterLooter()
        return
    end

    if event == "PLAYER_TARGET_CHANGED" then
        LDData.OnTargetChangedLootMaster()
        return
    end

    if event == "CONFIRM_LOOT_SLOT" then
        print("do we even need to confirm shit?")
        return
    end
    
end)