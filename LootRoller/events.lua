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
            -- Parse roll message like "Player rolls 42 (1-100)"
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
                -- Call our loot roller handler
                -- print(LDData.currentLootRollItemId, playerName, rollValue, "WE ROLLIN BABE, FROM "..lowEnd.." TO "..highEnd)
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

-- GLOBALS
LDData.InitializeLootRollerEvents = InitializeLootRollerEvents