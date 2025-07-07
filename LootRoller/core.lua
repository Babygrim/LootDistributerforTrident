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

-- Current rolls: playerName -> {roll=number, note=string}
local lootRolls = {}

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
    local sourceText = currentLootRollItemSource and ("Source: "..currentLootRollItemSource) or ""
    local ilvlText = currentLootRollItemIlvl and ("Item Level: "..currentLootRollItemIlvl) or ""
    f.lootRollerItemInfo:SetText(string.format("%s\nID: %d\n%s\n%s", currentLootRollItemName or "Unknown", currentLootRollItemId, sourceText, ilvlText))
end

-- Function to refresh rolls table
function RefreshLootRollerTable()
    -- Hide all rows initially
    for _, row in ipairs(rollRows) do
        row:Hide()
    end

    -- Prepare sorted rolls by roll descending
    local sortedRolls = {}
    for playerName, rollData in pairs(lootRolls) do
        table.insert(sortedRolls, {player=playerName, roll=rollData.roll, note=rollData.note or ""})
    end
    table.sort(sortedRolls, function(a,b) return a.roll > b.roll end)

    -- Create or reuse rows
    for i, entry in ipairs(sortedRolls) do
        local row = rollRows[i]
        if not row then
            row = CreateFrame("Frame", nil, scrollContent)
            row:SetSize(f.scrollContent:GetWidth(), ROW_HEIGHT)

            row.rollText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.rollText:SetPoint("LEFT", 10, 0)

            row.playerText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.playerText:SetPoint("LEFT", 80, 0)

            row.noteText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.noteText:SetPoint("LEFT", 250, 0)

            rollRows[i] = row
        end
        row:SetPoint("TOPLEFT", 0, -10 - (i-1)*ROW_HEIGHT)
        row.rollText:SetText(entry.roll)
        row.playerText:SetText(entry.player)
        row.noteText:SetText(entry.note)
        row:Show()
    end

    -- Adjust scroll content height
    f.scrollContent:SetHeight(math.max(#sortedRolls * ROW_HEIGHT + 20, f.scrollFrame:GetHeight()))
end

-- Function to get soft reserve players for an itemId
function GetSoftReservePlayers(itemId)
    local srPlayers = {}
    local hasSR = false
    -- softReserves is global in your logic.lua: softReserves[player][itemId] = true
    for playerName, items in pairs(softReserves or {}) do
        if items[itemId] then
            srPlayers[playerName] = true
            hasSR = true
        end
    end
    if hasSR then return srPlayers else return nil end
end

-- Dummy example data for testing when tab opened manually
function ShowDummyLootRollerData()
    currentLootRollItemId = 99999
    currentLootRollItemName = "Example Sword of Testing"
    currentLootRollItemSource = "Dummy Source"
    currentLootRollItemIlvl = 123

    -- Example soft reserves players (simulate 3 players)
    lootRollerSoftReservePlayers = {
        ["PlayerOne"] = true,
        ["PlayerTwo"] = true,
        ["PlayerThree"] = true,
    }

    -- Example rolls (simulate some rolls)
    lootRolls = {
        ["PlayerOne"] = {roll = 95, note = "Main tank"},
        ["PlayerTwo"] = {roll = 78, note = "DPS"},
        ["PlayerThree"] = {roll = 88, note = "Healer"},
    }

    UpdateLootRollerItemInfo()
    RefreshLootRollerTable()
end

-- Updated ShowLootRollerForItem: if itemId is nil, show dummy data instead
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
    if lootRollerSoftReservePlayers then
        -- If soft reserved, only accept rolls from those who soft reserved
        if not lootRollerSoftReservePlayers[playerName] then
            return
        end
    end

    local prev = lootRolls[playerName]
    if not prev or roll > prev.roll then
        lootRolls[playerName] = {roll=roll, note=""}
        RefreshLootRollerTable()
    end
end


-- GLOBALS
LDData.HandleNewRoll = HandleNewRoll