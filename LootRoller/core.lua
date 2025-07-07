local LootDistr, LDData = ...
local f = LDData.main_frame

local ROW_HEIGHT = 20

-- Rows cache
local rollRows = {}

-- Current displayed item data
local currentLootRollItemId = nil
local currentLootRollItemName = nil
local currentLootRollItemSource = nil
local currentLootRollItemIlvl = nil

-- Table to store roll data
local lootRolls = {}  -- Format: [playerName] = {roll=98, class="Mage", date="2025-07-07"}

-- Current soft reserve players for this item: playerName -> true
local lootRollerSoftReservePlayers = nil

-- Function to update item info text and icon
function UpdateLootRollerItemInfo()
    if not currentLootRollItemId then
        f.lootRollerItemIcon:SetTexture(nil)
        f.lootRollerItemInfo:SetText("")
        return
    end
    local icon = GetItemIcon(currentLootRollItemId)
    f.lootRollerItemIcon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    local sourceText = currentLootRollItemSource and ("Source: " .. currentLootRollItemSource) or ""
    local ilvlText = currentLootRollItemIlvl and ("Item Level: " .. currentLootRollItemIlvl) or ""
    f.lootRollerItemInfo:SetText(string.format("%s\nID: %d\n%s\n%s", currentLootRollItemName or "Unknown", currentLootRollItemId, sourceText, ilvlText))
end

-- Function to refresh rolls table
function RefreshLootRollerTable()
    for _, row in ipairs(rollRows) do
        row:Hide()
    end

    local sortedRolls = {}
    for playerName, rollData in pairs(lootRolls) do
        table.insert(sortedRolls, {
            player = playerName,
            roll = rollData.roll,
            class = rollData.class or "",
            date = rollData.date or ""
        })
    end
    table.sort(sortedRolls, function(a, b) return a.roll > b.roll end)

    for i, entry in ipairs(sortedRolls) do
        local row = rollRows[i]
        if not row then
            row = CreateFrame("Frame", nil, f.scrollContent)
            row:SetSize(f.scrollContent:GetWidth(), ROW_HEIGHT)

            row.playerText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.playerText:SetPoint("LEFT", 10, 0)
            row.playerText:SetWidth(120)

            row.classText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.classText:SetPoint("LEFT", 140, 0)
            row.classText:SetWidth(100)

            row.rollText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.rollText:SetPoint("LEFT", 250, 0)
            row.rollText:SetWidth(60)

            row.dateText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.dateText:SetPoint("LEFT", 320, 0)
            row.dateText:SetWidth(120)

            rollRows[i] = row
        end

        row:SetPoint("TOPLEFT", 0, -10 - (i - 1) * ROW_HEIGHT)
        row.playerText:SetText(entry.player)
        row.classText:SetText(entry.class)
        row.rollText:SetText(tostring(entry.roll))
        row.dateText:SetText(entry.date)
        row:Show()
    end

    f.scrollContent:SetHeight(math.max(#sortedRolls * ROW_HEIGHT + 20, f.scrollFrame:GetHeight()))
end

-- Function to get soft reserve players for an itemId
function GetSoftReservePlayers(itemId)
    local srPlayers = {}
    local hasSR = false
    for playerName, items in pairs(softReserves or {}) do
        if items[itemId] then
            srPlayers[playerName] = true
            hasSR = true
        end
    end
    return hasSR and srPlayers or nil
end

-- Dummy example data for testing when tab opened manually
function ShowDummyLootRollerData()
    currentLootRollItemId = 99999
    currentLootRollItemName = "Example Sword of Testing"
    currentLootRollItemSource = "Dummy Source"
    currentLootRollItemIlvl = 123

    lootRollerSoftReservePlayers = {
        ["PlayerOne"] = true,
        ["PlayerTwo"] = true,
        ["PlayerThree"] = true,
    }

    lootRolls = {
        ["Killum"] = { class = "Warrior", roll = 95, date = "2025-07-07" },
        ["Felina"] = { class = "Priest",  roll = 88, date = "2025-07-07" },
    }

    UpdateLootRollerItemInfo()
    RefreshLootRollerTable()
end

-- Show Loot Roller UI for real item or dummy
function ShowLootRollerForItem(itemId, itemName, itemSource, itemIlvl)
    if not itemId then
        ShowDummyLootRollerData()
        return
    end

    currentLootRollItemId = itemId
    currentLootRollItemName = itemName
    currentLootRollItemSource = itemSource
    currentLootRollItemIlvl = itemIlvl

    lootRolls = {}
    lootRollerSoftReservePlayers = GetSoftReservePlayers(itemId)

    ShowTab(4)
    UpdateLootRollerItemInfo()
    RefreshLootRollerTable()
end

-- Function to handle new roll
function HandleNewRoll(itemId, playerName, roll)
    if not currentLootRollItemId or itemId ~= currentLootRollItemId then return end

    if lootRollerSoftReservePlayers and next(lootRollerSoftReservePlayers) then
        if not lootRollerSoftReservePlayers[playerName] then return end
    end

    local prev = lootRolls[playerName]
    if not prev or roll > prev.roll then
        local _, class = UnitClass(playerName)
        lootRolls[playerName] = {
            roll = roll,
            class = class or "UNKNOWN",
            date = date("%Y-%m-%d")
        }
        RefreshLootRollerTable()
    end
end

-- Make available globally
LDData.HandleNewRoll = HandleNewRoll
