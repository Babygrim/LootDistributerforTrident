local LootDistr, LDData = ...
local f = LDData.main_frame
local LootWatcherActivated = false

f.mainEventFrame = CreateFrame("Frame")
f.mainEventFrame:RegisterEvent("ADDON_LOADED")
f.mainEventFrame:RegisterEvent("CHAT_MSG_ADDON")

f.mainEventFrame:SetScript("OnEvent", function(self, event, prefix, message, ...)
    if event == "ADDON_LOADED" and prefix == LootDistr then
        LDData.InitializeAddonCore()
    elseif event == "CHAT_MSG_ADDON" and prefix == LootDistr then
        -- Extract sender from ... parameters (Type, Sender)
        local messageType, sender = ...
        
        -- Safeguard: Ignore messages from the session initiator
        if sender and sender ~= UnitName("player") then
            LDData.HandleBroadcastedRollData(message)
        end
    end
end)