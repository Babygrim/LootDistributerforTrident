local LootDistr, LDData = ...
local f = LDData.main_frame

-- Confirmation popup for deleting all soft reserve data
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
