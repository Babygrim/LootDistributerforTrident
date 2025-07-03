-- Entry point
print("|cff00FF00[LootDistributer]|r Addon Loaded")

local addonName = ...
_G[addonName] = {}
local addon = _G[addonName]

addon.name = addonName
addon.currentSort = { column = "item", ascending = true }
addon.rows = {}

local loaded = {
    "ui_main",
    "ui_import",
    "ui_reserves",
    "logic_csv",
    "logic_table",
    "events",
    "commands",
}

for _, file in ipairs(loaded) do
    local loadedChunk = loadfile("Interface\\AddOns\\" .. addonName .. "\\" .. file .. ".lua")
    if loadedChunk then loadedChunk() end
end
