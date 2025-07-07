local LootDistr, LDData = ...
local f = LDData.main_frame

local eventFrame_roller = CreateFrame("Frame")
eventFrame_roller:RegisterEvent("CHAT_MSG_SYSTEM")
eventFrame_roller:SetScript("OnEvent", function(self, event, msg)
    if event == "CHAT_MSG_SYSTEM" then
        -- Parse roll message like "Player rolls 42 (1-100)"
        local playerName, rollValue = string.match(msg, "(.+) rolls (%d+) %(%d+%-%d+%)")
        if playerName and rollValue then
            rollValue = tonumber(rollValue)
            -- Call our loot roller handler
            LDData.HandleNewRoll(currentLootRollItemId, playerName, rollValue)
        end
    end
end)
