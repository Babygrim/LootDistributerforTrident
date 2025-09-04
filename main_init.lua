local LootDistr, LDData = ...

function InitializeAddonCore()
    local AddonVersion = "v1.2"
    -- Saved Variables
    -- Reserves + CSVImport
    SoftResSaved = SoftResSaved or {}
    SoftResCSV = SoftResCSV or ""
    SoftResLootedTimestamps = SoftResLootedTimestamps or {}

    -- Loot watcher
    LootWatcherData = LootWatcherData or {}
    LootWatcherGoldGained = LootWatcherGoldGained or 0
    LootWatcherThresholdNumber = LootWatcherThresholdNumber or 3

    -- Loot Roller
    CurrentRollItem = CurrentRollItem or {}
    LootRolls = LootRolls or {}
    SRPlayersRollers = SRPlayersRollers or nil
    LootRollerLocaleSettings = LootRollerLocaleSettings or GetLocale() or "enUS"

    -- Settings
    LootRollerAddonSettings = LootRollerAddonSettings or {}
    if LootRollerAddonSettings.autoLootSwitch == nil then
        LootRollerAddonSettings.autoLootSwitch = false
    end

    if LootRollerAddonSettings.autoLootItems == nil then
        LootRollerAddonSettings.autoLootItems = false
    end

    if LootRollerAddonSettings.disableLootSwitchFor10Man == nil then
        LootRollerAddonSettings.disableLootSwitchFor10Man = false
    end

    if LootRollerAddonSettings.disableLootSwitchForNonRaidGroup == nil then
        LootRollerAddonSettings.disableLootSwitchForNonRaidGroup = false
    end

    if LootRollerAddonSettings.lootWatcherGroupSwitch == nil then
        LootRollerAddonSettings.lootWatcherGroupSwitch = false
    end

    if LootRollerAddonSettings.lootWatcherNonGroupSwitch == nil then
        LootRollerAddonSettings.lootWatcherNonGroupSwitch = false
    end

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
        { text = "Spec", width = 100, key = "spec" },
    }
    LDData.qualityThresholdOptions = {
        { text = (ITEM_QUALITY_COLORS[0] and ITEM_QUALITY_COLORS[0].hex or "|cffffffff").."Poor|r", value = 0 },
        { text = (ITEM_QUALITY_COLORS[1] and ITEM_QUALITY_COLORS[1].hex or "|cffffffff").."Common|r", value = 1 },
        { text = (ITEM_QUALITY_COLORS[2] and ITEM_QUALITY_COLORS[2].hex or "|cffffffff").."Uncommon|r", value = 2 },
        { text = (ITEM_QUALITY_COLORS[3] and ITEM_QUALITY_COLORS[3].hex or "|cffffffff").."Rare|r", value = 3 },
        { text = (ITEM_QUALITY_COLORS[4] and ITEM_QUALITY_COLORS[4].hex or "|cffffffff").."Epic|r", value = 4 },
        { text = (ITEM_QUALITY_COLORS[5] and ITEM_QUALITY_COLORS[5].hex or "|cffffffff").."Legendary|r", value = 5 },
    }
    LDData.localeOptions = {
        { text = "English",      value = "enUS" },
        { text = "Русский",      value = "ruRU" },   -- Russian
        { text = "Français",     value = "frFR" },   -- French
        { text = "Deutsch",      value = "deDE" },   -- German
        { text = "Español",      value = "esES" },   -- Spanish
        { text = "Português (BR)", value = "ptBR" }, -- Portuguese (Brazil)
        { text = "Italiano",     value = "itIT" },   -- Italian
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

    -- CSV
    LDData.InitializeCSVImportUI()
    LDData.InitializeCSVImportCommands()
    LDData.InitializeCSVImportEvents()

    -- Reserves
    LDData.InitializeReservesUI()
    LDData.InitializeReservesEvents()

    -- LootWatcher
    LDData.InitializeLootWatcherUI()
    LDData.InitializeLootWatcherEvents()

    -- LootRoller
    LDData.InitializeLootRollerUI()
    LDData.InitializeLootRollerEvents()

    -- Settings
    LDData.InitializeSettingsUI()

    print("|cff00FF00[LootDistributer]|r "..LDData.messages.system.addonLoaded.." ("..AddonVersion..")")

end

-- GLOBALS
LDData.InitializeAddonCore = InitializeAddonCore

