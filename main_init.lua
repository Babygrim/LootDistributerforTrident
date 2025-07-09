local LootDistr, LDData = ...
local AddonVersion = "v1.1"
-- Saved Variables

-- Reserves + CSVImport
SoftResSaved = SoftResSaved or {}
SoftResCSV = SoftResCSV or ""
SoftResLootedTimestamps = SoftResLootedTimestamps or {}

-- Loot watcher
LootWatcherData = LootWatcherData or {}
LootWatcherGoldGained = LootWatcherGoldGained or 0
LootWatcherThreshold = LootWatcherThreshold or 3

-- Loot Roller
CurrentRollItemID = CurrentRollItemID or nil
LootRolls = LootRolls or {}
SRPlayersRollers = SRPlayersRollers or nil

-- Shared Variables
LDData.currentSort = { column = "item", ascending = true }
LDData.currentLootSort = { column = "time", ascending = false }
LDData.playerName = UnitName("player")
LDData.reservePlaceholder = LDData.messages.ui.searchReserves
LDData.lootPlaceholder = LDData.messages.ui.searchLoot

-- UI shared Variables
LDData.rowHeight = 20
LDData.colWidths = {200, 120, 150, 100}
LDData.spacing = 5
LDData.leftPadding = 5
LDData.headers = {
    { text = "Item", width = 200, key = "item" },
    { text = "Player", width = 120, key = "name" },
    { text = "Date", width = 150, key = "date" },
    { text = "Tradeable", width = 100, key = "tradeable" },
}
LDData.lootHeaders = {
    { text = "Item", width = 250, key = "item" },
    { text = "Player", width = 120, key = "player" },
    { text = "Count", width = 100, key = "count" },
    { text = "Time", width = 100, key = "time" },
}
LDData.lootRollHeaders = {
    { text = "Player", width = 250, key = "player" },
    { text = "Class", width = 120, key = "class" },
    { text = "Roll", width = 100, key = "roll" },
    { text = "Date", width = 100, key = "date" },
}
LDData.qualityThresholdOptions = {
    { text = "Poor", value = 0 },
    { text = "Common+", value = 1 },
    { text = "Uncommon+", value = 2 },
    { text = "Rare+", value = 3 },
    { text = "Epic+", value = 4 },
    { text = "Legendary+", value = 5 },
}
LDData.BossToDungeon = {
    -- Karazhan
    ["Attumen the Huntsman"] = "Karazhan",
    ["Moroes"] = "Karazhan",
    ["Maiden of Virtue"] = "Karazhan",
    ["Opera Event"] = "Karazhan",
    ["Curator"] = "Karazhan",
    ["Terestian Illhoof"] = "Karazhan",
    ["Shade of Aran"] = "Karazhan",
    ["Netherspite"] = "Karazhan",
    ["Prince Malchezaar"] = "Karazhan",
    ["Chess Event"] = "Karazhan",
    ["Nightbane"] = "Karazhan",

    -- Gruul's Lair
    ["High King Maulgar"] = "Gruul's Lair",
    ["Gruul the Dragonkiller"] = "Gruul's Lair",

    -- Magtheridon's Lair
    ["Magtheridon"] = "Magtheridon's Lair",

    -- Serpentshrine Cavern
    ["Hydross the Unstable"] = "Serpentshrine Cavern",
    ["The Lurker Below"] = "Serpentshrine Cavern",
    ["Leotheras the Blind"] = "Serpentshrine Cavern",
    ["Fathom-Lord Karathress"] = "Serpentshrine Cavern",
    ["Morogrim Tidewalker"] = "Serpentshrine Cavern",
    ["Lady Vashj"] = "Serpentshrine Cavern",

    -- Tempest Keep
    ["Al'ar"] = "Tempest Keep",
    ["Void Reaver"] = "Tempest Keep",
    ["High Astromancer Solarian"] = "Tempest Keep",
    ["Kael'thas Sunstrider"] = "Tempest Keep",

    -- Black Temple
    ["High Warlord Naj'entus"] = "Black Temple",
    ["Supremus"] = "Black Temple",
    ["Shade of Akama"] = "Black Temple",
    ["Teron'gor"] = "Black Temple",
    ["Gurtogg Bloodboil"] = "Black Temple",
    ["Reliquary of Souls"] = "Black Temple",
    ["Mother Shahraz"] = "Black Temple",
    ["Illidan Stormrage"] = "Black Temple",

    -- Zul'Aman
    ["Nalorakk"] = "Zul'Aman",
    ["Akil'zon"] = "Zul'Aman",
    ["Jan'alai"] = "Zul'Aman",
    ["Halazzi"] = "Zul'Aman",
    ["Hex Lord Malacrass"] = "Zul'Aman",
    ["Zul'jin"] = "Zul'Aman",

    -- Sunwell Plateau
    ["Kalecgos"] = "Sunwell Plateau",
    ["Brutallus"] = "Sunwell Plateau",
    ["Felmyst"] = "Sunwell Plateau",
    ["Eredar Twins"] = "Sunwell Plateau",
    ["M'uru"] = "Sunwell Plateau",
    ["Kil'jaeden"] = "Sunwell Plateau",

    -- Hyjal Summit
    ["Rage Winterchill"] = "Hyjal Summit",
    ["Anetheron"] = "Hyjal Summit",
    ["Kaz'rogal"] = "Hyjal Summit",
    ["Azgalor"] = "Hyjal Summit",
    ["Archimonde"] = "Hyjal Summit",
}

print("|cff00FF00[LootDistributer]|r "..LDData.messages.system.addonLoaded.." ("..AddonVersion..")")



