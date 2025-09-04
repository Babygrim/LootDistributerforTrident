local LootDistr, LDData = ...
local f = LDData.main_frame
local LootWatcherActivated = false

f.mainEventFrame = CreateFrame("Frame")
f.mainEventFrame:RegisterEvent("ADDON_LOADED")

f.mainEventFrame:SetScript("OnEvent", function(self, event, msg, ...)
    if event == "ADDON_LOADED" and msg == LootDistr then
        LDData.InitializeAddonCore()
    end
end)