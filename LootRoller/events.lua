local LootDistr, LDData = ...

function InitializeLootRollerEvents()
    local f = LDData.main_frame
    -- Confirmation popup for ending roll session
    StaticPopupDialogs[LootDistr .. "ConfirmEndLootRoller"] = {
        text = LDData.messages.dialogs.confirmEndRoll,
        button1 = LDData.messages.dialogs.yes,
        button2 = LDData.messages.dialogs.no,
        OnAccept = function()
            if not LDData.countdownFrame then
                LDData.countdownFrame = CreateFrame("Frame")
            else
                LDData.countdownFrame:Show()
            end
            
            local countdown = 5
            local accumulated = 0
            
            SendChatMessage(tostring(countdown), "RAID_WARNING")
            
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
            
                    for playerName, data in pairs(LootRolls) do
                        if data.roll > highestRoll then
                            highestRoll = data.roll
                            winnerName = playerName
                        end
                    end
            
                    local msg
                    if winnerName then
                        msg = string.format(LDData.messages.system.rollEndedWinner, winnerName, tonumber(highestRoll))
                    else
                        msg = LDData.messages.system.rollEndedNoRolls
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
            if playerName and rollValue and LDData.currentLootRollItemId then
                rollValue = tonumber(rollValue)
                -- Call our loot roller handler
                -- print(LDData.currentLootRollItemId, playerName, rollValue, "WE ROLLIN BABE, FROM "..lowEnd.." TO "..highEnd)
                LDData.HandleNewRoll(LDData.currentLootRollItemId, playerName, rollValue)
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
end

-- GLOBALS
LDData.InitializeLootRollerEvents = InitializeLootRollerEvents