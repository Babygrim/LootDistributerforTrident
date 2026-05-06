local LootDistr, LDData = ...

function InitializeLootRollerEvents()
    local f = LDData.main_frame
    
    -- Confirmation popup for ending roll session
    StaticPopupDialogs[LootDistr .. "ConfirmEndLootRoller"] = {
        text = LDData.messages.dialogs.confirmEndRoll,
        button1 = LDData.messages.dialogs.yes,
        button2 = LDData.messages.dialogs.no,
        OnAccept = function()
            LootRollerLocaleSettings = LootRollerLocaleSettings or GetLocale() or "enUS"
            if not LDData.countdownFrame then
                LDData.countdownFrame = CreateFrame("Frame")
            else
                LDData.countdownFrame:Show()
            end
            
            local countdown = 3
            local accumulated = 0
            
            SendChatMessage(string.format(LDData.localeMessages[LootRollerLocaleSettings].system.rollEndsSoon, tostring(countdown)), "RAID_WARNING")
            
            LDData.countdownFrame:SetScript("OnUpdate", function(self, delta)
                accumulated = accumulated + delta
                if accumulated < 1 then return end -- only run once per second
                
                accumulated = 0 -- reset counter
                
                countdown = countdown - 1
                if countdown > 0 then
                    SendChatMessage(tostring(countdown), "RAID_WARNING")
                else
                    self:SetScript("OnUpdate", nil)
            
                    -- Winner calculation happens AFTER countdown
                    local winnerName = nil
                    local highestRoll = -1
                    local spec = nil
                    
                    -- Highest Main Spec
                    for playerName, data in pairs(LootRolls) do
                        if data.roll > highestRoll and data.spec == "Main" then
                            highestRoll = data.roll
                            spec = data.spec
                            winnerName = playerName
                        end
                    end
                    
                    -- Highest Off Spec
                    if not winnerName then
                        for playerName, data in pairs(LootRolls) do
                            if data.roll > highestRoll and data.spec == "Off" then
                                highestRoll = data.roll
                                spec = data.spec
                                winnerName = playerName
                            end
                        end
                    end

                    local msg
                    if winnerName then
                        msg = string.format(LDData.localeMessages[LootRollerLocaleSettings].system.rollEndedWinner, winnerName, tonumber(highestRoll), spec)
                    else
                        msg = LDData.localeMessages[LootRollerLocaleSettings].system.rollEndedNoRolls
                    end
                    
                    -- Format roll data for LootWatcher with winner flag
                    local formattedRolls = {}
                    for playerName, rollData in pairs(LootRolls) do
                        table.insert(formattedRolls, {
                            name = playerName,
                            roll = rollData.roll,
                            spec = rollData.spec,
                            winner = (winnerName == playerName)
                        })
                    end
                    
                    -- Update LootWatcherData with roll information
                    UpdateLootWatcherDataWithRolls(CurrentRollItem.ID, formattedRolls)

                    -- Broadcast rolling results data for addon data sync
                    -- Format: ITEMID;PLAYERNAME,ROLL,SPEC,WINNER;PLAYERNAME,ROLL,SPEC,WINNER,...
                    -- Format (no rolls): ITEMID;NO_ROLLS
                    local broadcast_msg = tostring(CurrentRollItem.ID)..";"

                    if #formattedRolls > 0 then
                        for i, roll in ipairs(formattedRolls) do
                            broadcast_msg = broadcast_msg .. roll.name .. "," .. roll.roll .. "," .. roll.spec .. "," .. (roll.winner and "1" or "0") .. ';'
                        end
                    else
                        broadcast_msg = broadcast_msg .. "NO_ROLLS"
                    end
                    
                    SendAddonMessage(LootDistr, broadcast_msg, "RAID")
            
                    -- Reset loot roller state
                    CurrentRollItem = {}
                    LootRolls = {}
                    SRPlayersRollers = nil
                    f.lootRollerItemNameFrame.link = nil
            
                    LDData.currentLootRollItemId = nil
                    LDData.currentLootRollItemName = "Unknown"
                    LDData.currentLootRollItemSource = "Unknown"
                    LDData.currentLootRollItemIlvl = "Unknown"
            
                    UpdateLootRollerItemInfo()
                    RefreshLootRollerTable()
            
                    print("|cff00FF00[LootDistributer]|r " .. LDData.messages.system.lootRollingEnded)
                    SendChatMessage(msg, "RAID_WARNING")
                end
            end)            
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    StaticPopupDialogs[LootDistr .. "ConfirmCancelRoller"] = {
        text = LDData.messages.dialogs.confirmCancelRoll,
        button1 = LDData.messages.dialogs.yes,
        button2 = LDData.messages.dialogs.no,
        OnAccept = function()
            -- Reset loot roller state
            CurrentRollItem = {}
            LootRolls = {}
            SRPlayersRollers = nil
            f.lootRollerItemNameFrame.link = nil
    
            LDData.currentLootRollItemId = nil
            LDData.currentLootRollItemSource = "Unknown"
            LDData.currentLootRollItemIlvl = "Unknown"
            
            UpdateLootRollerItemInfo()
            RefreshLootRollerTable()
            
            print("|cff00FF00[LootDistributer]|r " .. string.format(LDData.messages.system.rollingCancelled, LDData.currentLootRollItemName))
            SendChatMessage(string.format(LDData.localeMessages[LootRollerLocaleSettings].system.rollingCancelled, LDData.currentLootRollItemName), "RAID_WARNING")
            LDData.currentLootRollItemName = "Unknown"
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    StaticPopupDialogs[LootDistr .. "ConfirmReLootRoller"] = {
        text = LDData.messages.dialogs.confirmReRoll,
        button1 = LDData.messages.dialogs.yes,
        button2 = LDData.messages.dialogs.no,
        OnAccept = function()
            if LootRolls then
                LootRolls = {}
                RefreshLootRollerTable()
                local tied = f.lootReRollBtn.tiedPlayers

                if tied and #tied >= 2 then
                    local message = "Re-Roll: " .. table.concat(tied, ", ")
                    SendChatMessage(message, "RAID_WARNING")
                    print("|cff00FF00[LootDistributer]|r "..LDData.messages.system.reRollConfirmed)
                else
                    print("|cff00FF00[LootDistributer]|r "..LDData.messages.system.noEligibleReRolls)
                end
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    -- Roll handler
    f.eventFrame_roller = CreateFrame("Frame")
    f.eventFrame_roller:RegisterEvent("CHAT_MSG_SYSTEM")

    f.eventFrame_roller:SetScript("OnEvent", function(self, event, msg)
        if event == "CHAT_MSG_SYSTEM" then
            local playerName, rollValue, lowEnd, highEnd = string.match(msg, LDData.messages.regex.systemRoll)
            if playerName and rollValue and CurrentRollItem.ID then
                rollValue = tonumber(rollValue)
                lowEnd, highEnd = tonumber(lowEnd), tonumber(highEnd)
                local spec = nil
                if lowEnd == 1 and highEnd == 100 then
                    spec = "Main"
                elseif lowEnd == 1 and highEnd == 99 then
                    spec = "Off"
                else
                    spec = "TMOG"
                end
                LDData.HandleNewRoll(CurrentRollItem.ID, playerName, rollValue, spec)
            end
        end
    end)

    -- Set tooltip behavior
    f.lootRollerItemNameFrame:SetScript("OnClick", function(self)
        if self.link then
            HandleModifiedItemClick(self.link)
        end
    end)

    f.lootRollerItemNameFrame:SetScript("OnEnter", function(self)
        if self.link then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(self.link)
            GameTooltip:Show()
        end
    end)

    f.lootRollerItemNameFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Confirm and Announce roll session end
    f.lootRollEndBtn:SetScript("OnClick", function()
        if CurrentRollItem.ID then
            StaticPopup_Show(LootDistr .. "ConfirmEndLootRoller")
        else
            print("|cff00FF00[LootDistributer]|r "..LDData.messages.system.noItemRolling)
        end
    end)

    -- Confirm and Announce re-roll session start
    f.lootReRollBtn:SetScript("OnClick", function()
        StaticPopup_Show(LootDistr .. "ConfirmReLootRoller")
    end)

    f.lootCancelBtn:SetScript("OnClick", function()
        if CurrentRollItem.ID then
            StaticPopup_Show(LootDistr .. "ConfirmCancelRoller")
        else
            print("|cff00FF00[LootDistributer]|r "..LDData.messages.system.noItemRolling)
        end
    end)
end


-- Loot Roller rolling info broadcasting handlers

function HandleBroadcastedRollData(message)
    -- Parse broadcast message format: ITEMID;PLAYERNAME,ROLL,SPEC,WINNER;PLAYERNAME,ROLL,SPEC,WINNER;...
    -- Parse broadcast message (no rolls): ITEMID;NO_ROLLS
    if not message or message == "" then return end
    
    local parts = {}
    for part in message:gmatch("[^;]+") do
        table.insert(parts, part)
    end
    
    if #parts < 2 then return end
    
    local itemID = tonumber(parts[1])
    
    if not itemID or itemID == 0 then return end
    
    -- Check if this is a "no rolls" message
    if parts[2] == "NO_ROLLS" then
        UpdateLootWatcherDataWithMessage(itemID, "No rolls registered")
        return
    end
    
    -- Parse roll data from parts 2 onwards: PLAYERNAME,ROLL,SPEC,WINNER
    local rolls = {}
    for i = 2, #parts do
        local rollParts = {}
        for part in parts[i]:gmatch("[^,]+") do
            table.insert(rollParts, part)
        end
        
        if #rollParts >= 4 then
            table.insert(rolls, {
                name = rollParts[1],
                roll = tonumber(rollParts[2]) or 0,
                spec = rollParts[3],
                winner = rollParts[4] == "1"
            })
        end
    end
    
    -- Update LootWatcherData with the roll information
    UpdateLootWatcherDataWithBroadcastedRolls(itemID, rolls)
end

function UpdateLootWatcherDataWithBroadcastedRolls(itemID, rolls)
    if not LootWatcherData then 
        print("|cffFF4500[DEBUG]|r LootWatcherData is nil")
        return 
    end
    
    
    -- Find the most recent entry that matches itemID and has no roll data yet (iterate backwards)
    for i = #LootWatcherData, 1, -1 do
        local lootEntry = LootWatcherData[i]
        if lootEntry then
            local entryItemID = tonumber((lootEntry.item or ""):match("item:(%d+)"))
            if entryItemID == itemID and (not lootEntry.rolls or #lootEntry.rolls == 0) then
                lootEntry.rolls = rolls or {}
                if f.lootSearchBox then
                    UpdateLootWatcherTable(f.lootSearchBox:GetText())
                end
                return
            end
        end
    end
end

function UpdateLootWatcherDataWithMessage(itemID, message)
    if not LootWatcherData then return end
    
    -- Find the most recent entry that matches itemID and has no roll data yet (iterate backwards)
    for i = #LootWatcherData, 1, -1 do
        local lootEntry = LootWatcherData[i]
        if lootEntry then
            local entryItemID = tonumber((lootEntry.item or ""):match("item:(%d+)"))
            if entryItemID == itemID and (not lootEntry.rolls or #lootEntry.rolls == 0) then
                lootEntry.rollMessage = message
                if f.lootSearchBox then
                    UpdateLootWatcherTable(f.lootSearchBox:GetText())
                end
                return
            end
        end
    end
end

-- GLOBALS
LDData.InitializeLootRollerEvents = InitializeLootRollerEvents
LDData.HandleBroadcastedRollData = HandleBroadcastedRollData