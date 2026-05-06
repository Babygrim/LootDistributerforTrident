# Loot Distributer for Trident

A comprehensive World of Warcraft 3.3.5a addon for managing soft reserves, tracking loot distribution, and conducting fair loot rolls with integrated trade timer display.

## Overview

**Loot Distributer for Trident** is a raid management addon designed to streamline the loot distribution process. It provides guild masters and raid leaders with powerful tools to manage soft reserves, track which items have been looted, automatically handle roll management, and monitor loot distribution statistics.

**Version:** 1.0  
**Author:** Wooah Blackbethy bam balam  
**For:** World of Warcraft 3.3.5a (Wrath of the Lich King)

---

## Features

### 📊 CSV Soft Reserves Import
- **Import soft reserves from CSV files** - Easily import item reserves from spreadsheets (currently works with https://softres.it/)
- **Automatic dungeon detection** - The addon guesses the most frequent dungeon from your import data
- **CSV text editor** - Edit CSV data directly within the addon interface
- **Saved state** - All imported reserves are saved between sessions

### 📋 Soft Reserves Management
- **View all reserves** - Browse all soft-reserved items in a searchable table
- **Search functionality** - Filter reserves by item name or player
- **Reserve tracking** - See which players have reserved which items
- **Trade timer monitoring** - Track when reserved items can be traded to other players
- **Delete reserves** - Remove individual or batch-delete reserves as needed
- **Sortable columns** - Sort by item, player, date, or tradeable status

### 🎲 Loot Roller System
- **Soft reserve-aware rolling** - Integrate soft reserves directly into the roll process
- **Alt+Click to roll** - Click items while holding Alt to start a roll in master loot
- **Automatic roll announcement** - Announces rolls and soft reserve holders to raid chat
- **Item information display** - Shows item name, ID, source, and item level
- **Roll management** - View all rolls with player information (name, class, roll value, spec)
- **Re-roll functionality** - Easily re-roll items if needed

### 👀 Loot Watcher
- **Track looted items** - Monitor all items distributed in your raids
- **Distribution statistics** - See how much loot each player has received
- **Gold tracking** - Track gold gained during raids
- **Configurable quality threshold** - Set a minimum item quality to track (Poor, Common, Uncommon, Rare, Epic, Legendary)
- **Time tracking** - See when each item was looted
- **Search and filter** - Find items by name, player, or other criteria
- **Multiple monitoring modes** - Track loot for raid groups, non-raid groups, or both

### ⚙️ Settings & Customization
- **Auto-loot switching** - Automatically enable/disable master loot based on raid size or group composition
- **Auto-loot items** - Automatically distribute items according to configured rules
- **Language support** - Multi-language interface (English, Russian, French, German, Spanish, Portuguese, Italian)
- **10-man exemptions** - Disable auto-loot for 10-man raids if desired
- **Non-raid group exemptions** - Apply different rules for non-raid group instances
- **Loot watcher modes** - Configure whether to track loot in raid groups, non-raid groups, or both

---

## Modules

### 1. CSV Import (`CSVImport/`)
Manage and import soft reserves from CSV files. This module handles:
- CSV text parsing and validation
- Dungeon detection from CSV data
- Storage and management of imported reserves
- Direct editing of CSV data in-game

**Features:**
- CSV editor with copy/paste support
- Automatic formatting detection
- Duplicate handling
- Batch import

### 2. Reserves (`Reserves/`)
View and manage soft-reserved items. This module provides:
- A searchable table of all reserves
- Reserve lookup by item or player
- Addition and deletion of reserves
- Trade timer calculation (when items become tradeable)

**Features:**
- Sortable columns (Item, Player, Date, Tradeable)
- Item tooltips on hover
- Direct item linking support
- Quick search/filter

### 3. Loot Watcher (`LootWatcher/`)
Track loot distribution across raids. This module monitors:
- All items looted and distributed
- Which players received which items
- Total gold gained
- Item count per player
- Raid session statistics

**Features:**
- Configurable quality thresholds
- Raid member tracking
- Loot history
- Distribution reports
- Separate tracking modes for raid/non-raid

### 4. Loot Roller (`LootRoller/`)
Conduct fair rolls for items with soft reserve integration. This module enables:
- Soft reserve announcement during rolls
- Item quality and level display
- Roll result tracking
- Player class and spec information
- Re-roll support

**Features:**
- Master loot integration
- Soft reserve priority display
- Item hyperlink support
- Locale-aware messaging

### 5. Settings (`Settings/`)
Configure addon behavior and preferences. This module handles:
- Auto-loot switching rules
- Item quality thresholds
- Loot watcher configuration
- Language selection
- Various toggles for addon features

**Features:**
- Persistent settings storage
- Multi-language interface
- Size and group-based rules
- Feature toggles

---

## How to Use

### Opening the Addon
Use the slash command:
```
/trident
```
Or click the addon button in your UI to toggle it open/closed.

### Tab Guide

**1. CSV Import Tab**
- Paste CSV data containing soft reserves
- The addon automatically detects the dungeon
- Click "Import" to save the reserves
- Edit CSV directly in the text box if needed

**2. Reserves Tab**
- Browse all imported soft reserves
- Use the search box to filter by item or player name
- Click on items to see tooltips
- Click the "Delete" button to remove selected reserves

**3. Loot Watcher Tab**
- View all looted items and who received them
- Monitor gold gains
- Search by item or player
- Set the quality threshold in Settings
- Separate tracking for raid and non-raid groups

**4. Loot Roller Tab**
- Shows current item being rolled for
- Displays all participants and their rolls
- Item information (ID, source, item level)
- Re-roll button for starting a new roll

**5. Settings Tab**
- Configure auto-loot behavior
- Set item quality threshold for tracking
- Select language
- Toggle various features on/off

### Starting a Roll

**To start a roll with soft reserves:**
1. Master loot an item to yourself
2. Alt+Click the item in your loot window or chat
3. If soft reserves exist for that item, they'll be announced to raid
4. Players in raid will see the roll interface and can roll
5. Winner is awarded based on the roll value

---

## Commands

| Command | Effect |
|---------|--------|
| `/trident` | Toggle the addon window open/closed |

## Alt+Click Integration

When you Alt+Click an item with **master loot active:**
- If soft reserves exist for that item, they are announced to raid
- A loot roll interface appears for raid members to roll on the item
- The item information is displayed (name, ID, source, item level)

---

## Data Storage

The addon saves the following data between sessions:
- **SoftResSaved** - All imported soft reserves
- **SoftResCSV** - Raw CSV import text
- **SoftResLootedTimestamps** - Timestamps for tradeable items
- **LootWatcherData** - Tracked loot distribution
- **LootWatcherGoldGained** - Total gold tracked
- **LootRolls** - Historical roll data
- **CurrentRollItem** - Currently rolling item
- **LootRollerLocaleSettings** - Language preference
- **LootRollerAddonSettings** - User preferences and toggles

---

## Supported Languages

- English (enUS)
- Русский - Russian (ruRU)
- Français - French (frFR)
- Deutsch - German (deDE)
- Español - Spanish (esES)
- Português (BR) - Portuguese Brazilian (ptBR)
- Italiano - Italian (itIT)

---

## Supported Dungeons/Raids

### Burning Crusade (TBC) Raids
- **Karazhan** (Attumen, Moroes, Maiden of Virtue, Opera, Curator, Illhoof, Shade of Aran, Netherspite, Prince Malchezaar, Chess, Nightbane)
- **Gruul's Lair** (High King Maulgar, Gruul the Dragonkiller)
- **Magtheridon's Lair** (Magtheridon)
- **Serpentshrine Cavern** (Hydross, Lurker Below, Leotheras, Fathom-Lord Karathress, Morogrim Tidewalker, Lady Vashj)
- **Tempest Keep** (Al'ar, Void Reaver, High Astromancer Solarian, Kael'thas Sunstrider)
- **Black Temple** (High Warlord Naj'entus, Supremus, Shade of Akama, Teron'gor, Gurtogg Bloodboil, Reliquary of Souls, Mother Shahraz, Illidan Stormrage)
- **Zul'Aman** (Nalorakk, Akil'zon, Jan'alai, Halazzi, Hex Lord Malacrass, Zul'jin)
- **Sunwell Plateau** (Kalecgos, Brutallus, Felmyst, Eredar Twins, M'uru, Kil'jaeden)
- **Hyjal Summit** (Rage Winterchill, Anetheron, Kaz'rogal, Azgalor, Archimonde)

### Wrath of the Lich King (WOTLK) Raids
- **Naxxramas** (Anub'Rekhan, Grand Widow Faerlina, Maexxna, Noth, Heigan, Loatheb, Patchwerk, Grobbulus, Gluth, Thaddius, Sapphiron, Kel'Thuzad)
- **The Eye of Eternity** (Malygos)
- **The Obsidian Sanctum** (Sartharion)
- **Vault of Archavon** (Archavon, Emaiss, Koralon, Toravon)
- **Ulduar** (Flame Leviathan, Ignis, Razorscale, XT-002, Assembly of Iron, Steelbreaker, Molgeim, Brundir, Kologarn, Auriaya, Mimiron, General Vezax, Yogg-Saron, Keepers of Ulduar)
- **Trial of the Crusader** (Beasts of Northrend, Lord Jaraxxus, Faction Champions, Twin Val'kyr, Anub'arak)
- **Icecrown Citadel** (Lord Marrowgar, Lady Deathwhisper, Gunship Battle, Deathbringer Saurfang, Festergut, Rotface, Professor Putricide, Blood Prince Council, Blood-Queen Lana'thel, Sindragosa, The Lich King)
- **The Ruby Sanctum** (Baltharus, Zarithrian, Sharthos, Halion)

---

## Tips & Best Practices

1. **Import reserves regularly** - Keep your reserves up-to-date by importing new CSVs as your guild manages loot
2. **Monitor the Loot Watcher** - Keep track of who's getting loot to ensure fair distribution
3. **Use the quality threshold** - Set it to Rare or higher to avoid tracking trash items
4. **Check tradeable dates** - The addon tracks when items can be traded; use this to know when players can exchange gear
5. **Archive roll data** - Periodically save your loot roll history for guild records

---

## UI Features

- **Searchable tables** - All item and player lists support real-time search filtering
- **Item tooltips** - Hover over items to see full details
- **Item linking** - Click items to link them in chat or right-click for additional options
- **Sortable columns** - Click headers to sort by different criteria
- **Color-coded quality** - Items are colored according to rarity (Poor, Common, Uncommon, Rare, Epic, Legendary)
- **Scrollable windows** - Easy navigation through large reserve or loot lists

---

## Support

For bug reports, feature requests, or questions about using Loot Distributer for Trident, contact:
**Author:** Wooah Blackbethy bam balam

---

## License & Distribution

This addon is part of the Loot Distributer for Trident project. Please respect copyright and author attributions.

---

**Last Updated:** Interface 30300 (WoW 3.3.5a)
