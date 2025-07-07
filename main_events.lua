local LootDistr, LDData = ...
local f = LDData.main_frame
local LootWatcherActivated = false

f.eventFrame = CreateFrame("Frame")
f.eventFrame:RegisterEvent("CHAT_MSG_LOOT")
f.eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
f.eventFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")

f.eventFrame:SetScript("OnEvent", function(self, event, msg, ...)
    if event == "PARTY_LOOT_METHOD_CHANGED" then
        local lootMethod, masterLooter = GetLootMethod()

        if GetNumRaidMembers() > 0 and lootMethod == "master" then
            local masterLooterName = UnitName("party" .. masterLooter)
            if masterLooterName == nil then
                print("|cff00FF00[LootDistributer]|r Loot roll module enabled.")
            end
        end

        if (GetNumRaidMembers() > 0 or GetNumRaidMembers() == 0) and lootMethod ~= "master" then
            print("|cffFF4500[LootDistributer]|r Loot roll module disabled.")
        end
        return
    end

    if event == "RAID_ROSTER_UPDATE" then
        if GetNumRaidMembers() > 0 and not LootWatcherActivated then
            print("|cff00FF00[LootDistributer]|r You have joined the raid group. Loot Watcher activated.")
            LootWatcherActivated = true
        end

        if GetNumRaidMembers() == 0 and LootWatcherActivated then
            print("|cffFF4500[LootDistributer]|r You have left the raid group. Loot Watcher deactivated.")
            LootWatcherActivated = false
        end
        return
    end

    if event == "CHAT_MSG_LOOT" then
        if not msg then return end

        -- Your loot parsing logic here:
        local sPlayerName, itemLink = msg:match("^(.+) receives loot: (.+)%.$")
        if not sPlayerName then
            itemLink = msg:match("^You receive loot: (.+)%.$")
            sPlayerName = playerName
        end

        if itemLink and sPlayerName == playerName then
            local itemID = tonumber(itemLink:match("item:(%d+)"))
            if itemID then
                local itemName = GetItemInfo(itemID)
                if itemName and SoftResSaved[itemName] then
                    SoftResLootedTimestamps[itemID] = time()
                    print("|cff00FF00[LootDistributer]|r Looted " .. itemLink .. " at " .. date("%H:%M:%S"))
                end
            end
        end
        
        if GetNumRaidMembers() > 0 then
            -- Try match the "You receive loot:" or "You share the loot of" patterns
            local lootStr = msg:match("^You receive loot: (.+)%.$") or msg:match("^You share the loot of (.+)%.$")
        
            if not lootStr then
                -- Try match "Your share of the loot is ..."
                lootStr = msg:match("^Your share of the loot is (.+)%.$")
            end
        
            if lootStr then
                local copper = 0
                local g = lootStr:match("(%d+) Gold")
                local s = lootStr:match("(%d+) Silver")
                local c = lootStr:match("(%d+) Copper")
                if g then copper = copper + tonumber(g) * 10000 end
                if s then copper = copper + tonumber(s) * 100 end
                if c then copper = copper + tonumber(c) end
                if copper > 0 then
                    LootWatcherGoldGained = LootWatcherGoldGained + copper
                    return
                end
            end

            local lwPlayer, lwItemLink
            lwPlayer, lwItemLink = msg:match("^(.+) receives loot: (.+)%.$")
            if not lwPlayer then
                lwItemLink = msg:match("^You receive loot: (.+)%.$")
                lwPlayer = LDData.playerName  -- your player's name variable
            end

            if lwPlayer and lwItemLink then
                local count = 1
                local qty = lwItemLink:match("x(%d+)")
                if qty then count = tonumber(qty) end

                table.insert(LootWatcherData, {
                    item = lwItemLink,
                    player = lwPlayer,
                    count = count,
                    time = date("%H:%M:%S"),
                })

                LDData.TrimLootWatcherData() -- trim old loot records if needed
                LDData.UpdateLootWatcherTable(f.lootSearchBox:GetText())

                print("|cff00FF00[LootDistributer]|r Tracked loot: |Hplayer:" .. lwPlayer .. "|h|cffFFD100[" .. lwPlayer .. "]|r|h looted " .. lwItemLink)
            end
        end
        return
    end
end)

-- Ticker
f.tickerFrame = CreateFrame("Frame")
local elapsed = 0

f.tickerFrame:SetScript("OnUpdate", function(self, delta)
    elapsed = elapsed + delta
    if elapsed >= 1 then
        elapsed = 0
        if f.reservesTab:IsShown() then
            LDData.UpdateReservesTable(f.searchBox:GetText())
        elseif f.lootWatcherTab:IsShown() then
            LDData.UpdateLootWatcherTable(f.lootSearchBox:GetText())
        end
    end
end)

f.tickerFrame:Hide() -- initially hidden