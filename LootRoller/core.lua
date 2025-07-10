local LootDistr, LDData = ...
local f = LDData.main_frame

local ROW_HEIGHT = 20

-- Rows cache
local rollRows = {}

-- Function to update item info text and icon
function UpdateLootRollerItemInfo()
    local itemId = LDData.currentLootRollItemId or CurrentRollItem.ID
    local itemName = LDData.currentLootRollItemName or CurrentRollItem.Name
    local itemSource = LDData.currentLootRollItemSource or CurrentRollItem.Source
    local itemIlvl = LDData.currentLootRollItemIlvl or CurrentRollItem.Ilvl

    local icon = GetItemIcon(itemId)
    f.lootRollerItemIcon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")

    local link
    if itemId then
        link = select(2, GetItemInfo(itemId))
    end

    if link then
        f.lootRollerItemNameText:SetText("Item: "..link)
        f.lootRollerItemNameFrame.link = link
    else
        f.lootRollerItemNameText:SetText("Item: "..(itemName or "Unknown"))
        f.lootRollerItemNameFrame.link = nil
    end

    f.lootRollerItemIDText:SetText("Item ID: " .. (itemId or "Unknown"))
    f.lootRollerItemSourceText:SetText("Item Source: " .. (itemSource or "Unknown"))
    f.lootRollerItemIlvlText:SetText("Item Level: " .. (itemIlvl or "Unknown"))
end

function CheckReRollEligibility()
    if not f.lootReRollBtn then return end

    local rolls = LootRolls or {}
    local itemId = LDData.currentLootRollItemId
    local itemName = LDData.currentLootRollItemName
    if not itemId or not next(rolls) then
        f.lootReRollBtn:Disable()
        return
    end

    local isSR = SRPlayersRollers ~= nil
    local pool = {}
    local rollSpec = "TMOG"
    local specChangeable = true

    for player, rollData in pairs(rolls) do
        if not isSR or SRPlayersRollers[player] then
            table.insert(pool, { name = player, roll = rollData.roll, spec = rollData.spec})
            if rollData.spec == "Main" and specChangeable then
                rollSpec = rollData.spec
                specChangeable = false
            elseif rollData.spec == "Off" and specChangeable then
                rollSpec = rollData.spec
            elseif specChangeable then
                rollSpec = rollData.spec
            end
        end
    end

    local maxRoll = 0
    local tiedPlayers = {}

    for _, entry in ipairs(pool) do
        if entry.roll > maxRoll and entry.spec == rollSpec then
            maxRoll = entry.roll
            tiedPlayers = { entry.name }
        elseif entry.roll == maxRoll and entry.spec == rollSpec then
            table.insert(tiedPlayers, entry.name)
        end
    end

    if #tiedPlayers >= 2 then
        f.lootReRollBtn:Enable()
        f.lootReRollBtn.tiedPlayers = tiedPlayers
    else
        f.lootReRollBtn:Disable()
        f.lootReRollBtn.tiedPlayers = nil
    end
end


function CreateRollerRow(index)
    local row = CreateFrame("Frame", nil, f.scrollContent)
    row:SetSize(570, LDData.rowHeight)

    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    row:SetBackdropColor(0, 0, 0, 0)

    row:SetScript("OnEnter", LDData.OnLootHeaderEnter)
    row:SetScript("OnLeave", LDData.OnLootHeaderLeave)

    local xOffset = 10
    row.cells = {}

    for i, header in ipairs(LDData.lootRollHeaders) do
        local cell = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        cell:SetPoint("LEFT", row, "LEFT", xOffset, 0)
        cell:SetWidth(header.width)
        cell:SetJustifyH("CENTER")
        row[header.key .. "Text"] = cell
        row.cells[i] = cell

        xOffset = xOffset + header.width
    end

    -- For hover effect coloring
    row.text = row.playerText or row["playerText"]

    return row
end

-- Assumes `reserves` is globally available or passed in
function GetSoftReservePlayers(itemId)
    local srPlayers = {}
    local found = false

    local srList = SoftResSaved and SoftResSaved[itemId]
    if srList then
        for _, entry in ipairs(srList) do
            if entry.name then
                srPlayers[entry.name] = true
                found = true
            end
        end
    end

    return found and srPlayers or nil
end


-- Function to refresh rolls table
function RefreshLootRollerTable()
    for _, row in ipairs(rollRows) do
        row:Hide()
    end

    local sortedRolls = {}
    for playerName, rollData in pairs(LootRolls) do
        table.insert(sortedRolls, {
            player = playerName,
            roll = rollData.roll,
            class = rollData.class or "",
            spec = rollData.spec or ""
        })
    end
    table.sort(sortedRolls, function(a, b) return a.roll > b.roll end)

    for i, entry in ipairs(sortedRolls) do
        local row = rollRows[i]
        if not row then
            row = CreateRollerRow(i)
            rollRows[i] = row
        end

        row:SetPoint("TOPLEFT", f.scrollContent, "TOPLEFT", 0, -(i - 1) * LDData.rowHeight)
        row.playerText:SetText(entry.player)
        if SRPlayersRollers and SRPlayersRollers[entry.player] then
            row.playerText:SetTextColor(0, 1, 0) -- green
        else
            row.playerText:SetTextColor(1, 1, 1) -- white
        end
        
        row.classText:SetText(entry.class)
        row.rollText:SetText(tostring(entry.roll))
        row.specText:SetText(entry.spec)
        row:Show()
    end

    for i = #sortedRolls + 1, #rollRows do
        rollRows[i]:Hide()
    end

    f.scrollContent:SetHeight(math.max(#sortedRolls * LDData.rowHeight + 20, f.scrollFrame:GetHeight()))
    CheckReRollEligibility()
end

-- Show Loot Roller UI for real item or dummy
function ShowLootRollerForItem(link, itemID, itemSource, itemIlvl)
    LDData.currentLootRollItemId = itemID
    LDData.currentLootRollItemName = link
    LDData.currentLootRollItemSource = itemSource
    LDData.currentLootRollItemIlvl = itemIlvl

    f.lootRollerItemNameFrame.link = link
    CurrentRollItem.ID = itemID
    CurrentRollItem.Name = link
    CurrentRollItem.Source = itemSource
    CurrentRollItem.Ilvl = itemIlvl
    LootRolls = {}

    ShowTab(4)
    UpdateLootRollerItemInfo()
    RefreshLootRollerTable()
end

function HandleNewRoll(itemID, playerName, roll, spec)
    if not CurrentRollItem.ID or itemID ~= CurrentRollItem.ID then return end

    -- Fetch SR players for current item (once per item)
    if SRPlayersRollers == nil then
        SRPlayersRollers = GetSoftReservePlayers(itemID)
    end

    -- Determine SR count for player
    local srCount = 0
    if SRPlayersRollers then
        for _, entry in ipairs(SoftResSaved[itemID] or {}) do
            if entry.name == playerName then
                srCount = srCount + 1
            end
        end
        -- If they didn't SR at all, reject
        if srCount == 0 then return end
    else
        -- No SR list at all → treat as non-SR item
        srCount = 0
    end

    local prev = LootRolls[playerName]

    -- No SR (srCount == 0): accept only first roll
    if srCount == 0 then
        if not prev then
            local _, class = UnitClass(playerName)
            LootRolls[playerName] = {
                roll = roll,
                class = class or "UNKNOWN",
                spec = spec,
            }
            RefreshLootRollerTable()
        end
        return
    end

    -- SR == 1: accept only first roll
    if srCount == 1 then
        if not prev then
            local _, class = UnitClass(playerName)
            LootRolls[playerName] = {
                roll = roll,
                class = class or "UNKNOWN",
                spec = spec,
            }
            RefreshLootRollerTable()
        end
        return
    end

    -- SR >= 2: accept highest of multiple rolls
    if srCount >= 2 then
        if not prev or roll > prev.roll then
            local _, class = UnitClass(playerName)
            LootRolls[playerName] = {
                roll = roll,
                class = class or "UNKNOWN",
                spec = spec,
            }
            RefreshLootRollerTable()
        end
        return
    end
end

-- GLOBALS
LDData.HandleNewRoll = HandleNewRoll
