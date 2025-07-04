local addonName, addonTable = ...
local f = addonTable.main_frame
local LootWatcherActivated = false


-- Import CSV click event
f.importBtn:SetScript("OnClick", function()
    local text = f.csvEditBox:GetText()
    if not text or text == "" then
        print("|cffFF4500[LootDistributer]|r No CSV text to import!")
        return
    end

    -- Simple CSV check: first line should contain commas and required headers
    local firstLine = text:match("([^\r\n]+)")
    if not firstLine or not firstLine:find(",") then
        print("|cffFF4500[LootDistributer]|r Not a valid CSV format (missing commas or header row).")
        return
    end

    -- Check required columns exist in header
    local requiredCols = {["Item"] = true, ["ItemId"] = true, ["Name"] = true, ["Date"] = true}
    local found = {}
    for col in firstLine:gmatch("([^,]+)") do
        col = col:match("^%s*(.-)%s*$")
        if requiredCols[col] then
            found[col] = true
        end
    end
    for colName, _ in pairs(requiredCols) do
        if not found[colName] then
            print("|cffFF4500[LootDistributer]|r CSV is missing required column: |cffffff00" .. colName .. "|r")
            return
        end
    end

    -- If SoftResSaved already has data, confirm overwrite
    if next(SoftResSaved) ~= nil then
        StaticPopup_Show(addonName .. "ConfirmOverwrite")
    else
        -- No existing data, proceed directly
        local ok, result = pcall(parseCSV, text)
        if not ok then
            print("|cffFF4500[LootDistributer]|r CSV parse error: " .. result)
            return
        end
        SoftResSaved = result
        SoftResCSV = text
        print("|cff00FF00[LootDistributer]|r Imported soft reserves!")
        if f.reservesTab:IsShown() then
            addonTable.UpdateReservesTable(f.searchBox:GetText())
        end
    end
end)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("CHAT_MSG_LOOT")
eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
eventFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")

eventFrame:SetScript("OnEvent", function(self, event, msg, ...)
    if event == "PARTY_LOOT_METHOD_CHANGED" then
        local lootMethod, masterLooter = GetLootMethod()

        if GetNumRaidMembers() > 0 and lootMethod == "master" then
            local masterLooterName = UnitName("party" .. masterLooter)
            if masterLooterName == nil then
                print("|cff00FF00[LootDistributer]|r Loot roll module enabled.")
            end
        end

        if (GetNumRaidMembers() > 0 or GetNumRaidMembers() == 0) and lootMethod ~= "master" then
            if masterLooterName == nil then
                print("|cffFF4500[LootDistributer]|r Loot roll module disabled.")
            end
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
                lwPlayer = addonTable.playerName  -- your player's name variable
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

                addonTable.TrimLootWatcherData() -- trim old loot records if needed
                addonTable.UpdateLootWatcherTable(f.lootSearchBox:GetText())

                print("|cff00FF00[LootDistributer]|r Tracked loot: |Hplayer:" .. lwPlayer .. "|h|cffFFD100[" .. lwPlayer .. "]|r|h looted " .. lwItemLink)
            end
        end
        return
    end
end)