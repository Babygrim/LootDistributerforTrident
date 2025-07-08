local LootDistr, LDData = ...
local f = LDData.main_frame

-- Confirmation popup for ending rolling
StaticPopupDialogs[LootDistr .. "ConfirmEndLootRoller"] = {
    text = "Are you sure you want to end rolling?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
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
            msg = "Rolling ended. Winner: " .. winnerName .. " with roll - " .. highestRoll
        else
            msg = "Rolling ended. No rolls recorded."
        end

        CurrentRollItemID = nil
        LootRolls = {}
        SRPlayersRollers = nil
        f.lootRollerItemNameFrame.link = nil

        LDData.currentLootRollItemId = CurrentRollItemID
        LDData.currentLootRollItemName = "Unknown"
        LDData.currentLootRollItemSource = "Unknown"
        LDData.currentLootRollItemIlvl = "Unknown"

        UpdateLootRollerItemInfo()
        RefreshLootRollerTable()
        print("|cff00FF00[LootDistributer]|r Loot Rolling ended.")
        SendChatMessage(msg, "RAID_WARNING")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs[LootDistr .. "ConfirmReLootRoller"] = {
    text = "Are you sure you want to re-roll this item?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        if LootRolls then
            LootRolls = {}
            RefreshLootRollerTable()
            print("|cff00FF00[LootDistributer]|r Re-roll confirmed.")
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
        local playerName, rollValue, lowEnd, highEnd = string.match(msg, "^(%S+) rolls (%d+) %((%d+)%-(%d+)%)$")
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
    StaticPopup_Show(LootDistr .. "ConfirmEndLootRoller")
end)

-- Confirm and Announce re-roll session start
f.lootReRollBtn:SetScript("OnClick", function()
    StaticPopup_Show(LootDistr .. "ConfirmReLootRoller")
end)