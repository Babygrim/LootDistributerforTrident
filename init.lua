local addonName, addonTable = ...

-- Shared Variables
addonTable.currentSort = { column = "item", ascending = true }
addonTable.currentLootSort = { column = "time", ascending = false }
addonTable.playerName = UnitName("player")
addonTable.reservePlaceholder = "Search reserves..."
addonTable.lootPlaceholder = "Search loot..."

-- UI shared Variables
addonTable.rowHeight = 20
addonTable.colWidths = {200, 120, 150, 100}
addonTable.spacing = 5
addonTable.leftPadding = 5
addonTable.headers = {
    { text = "Item", width = 200, key = "item" },
    { text = "Player", width = 120, key = "name" },
    { text = "Date", width = 150, key = "date" },
    { text = "Tradeable", width = 100, key = "tradeable" },
}
addonTable.lootHeaders = {
    { text = "Item", width = 250, key = "item" },
    { text = "Player", width = 120, key = "player" },
    { text = "Count", width = 100, key = "count" },
    { text = "Time", width = 100, key = "time" },
}

addonTable.BossToDungeon = {
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


print("|cff00FF00[LootDistributer]|r Addon Loaded (v1.0)")



