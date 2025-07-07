local LootDistr, LDData = ...
local f = LDData.main_frame

-- Reserves related logic
local rows = {}

function CreateRow(index)
    local row = CreateFrame("Frame", nil, f.reservesTableContainer)
    row:SetSize(570, LDData.rowHeight)

    row.itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.itemText:SetPoint("LEFT", 10, 0)
    row.itemText:SetWidth(LDData.colWidths[1])
    row.itemText:SetJustifyH("CENTER")

    row.itemFrame = CreateFrame("Button", nil, row)
    row.itemFrame:SetSize(LDData.colWidths[1], LDData.rowHeight)
    row.itemFrame:SetPoint("LEFT", row, "LEFT", 10, 0)

    row.itemFrame:EnableMouse(true)
    row.itemFrame:SetFrameLevel(row:GetFrameLevel() + 1)
    row.itemFrame:SetFrameStrata("HIGH")

    row.itemFrame:SetScript("OnClick", function(self)
        if self.link then
            HandleModifiedItemClick(self.link)
        end
    end)

    row.itemFrame:SetScript("OnEnter", function(self)
        if self.link then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(self.link)
            GameTooltip:Show()
        end
    end)
    row.itemFrame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    row.playerText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.playerText:SetPoint("LEFT", row.itemText, "RIGHT", 0, 0)
    row.playerText:SetWidth(LDData.colWidths[2])

    row.dateText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.dateText:SetPoint("LEFT", row.playerText, "RIGHT", 0, 0)
    row.dateText:SetWidth(LDData.colWidths[3])

    row.tradeableText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.tradeableText:SetPoint("LEFT", row.dateText, "RIGHT", 0, 0)
    row.tradeableText:SetWidth(LDData.colWidths[4])

    return row
end

-- Get time left on looted items until non-tradeable
function getTradeableTimeLeft(itemID)
    if SoftResLootedTimestamps and SoftResLootedTimestamps[itemID] then
        local secondsLeft = 7200 - (time() - SoftResLootedTimestamps[itemID]) -- 2 hours = 7200 sec
        if secondsLeft > 0 then
            local h = math.floor(secondsLeft / 3600)
            local m = math.floor((secondsLeft % 3600) / 60)
            local s = secondsLeft % 60

            local ratio = secondsLeft / 7200
            local r = 1 - ratio
            local g = ratio
            local b = 0

            -- Convert to 2-digit hex (00 to FF)
            local function toHex(n)
                local hex = string.format("%02x", math.floor(n * 255))
                return hex
            end

            local colorCode = toHex(r) .. toHex(g) .. toHex(b)

            local timeStr = string.format("%dh %dm %02ds", h, m, s)
            return "|cff" .. colorCode .. timeStr .. "|r"
        else
            return "|cffff0000Expired|r"  -- red
        end
    end
    return "|cffffffffUnknown|r" -- white
end

-- Update reserves table display with filtering support
function UpdateReservesTable(filterText)
    filterText = filterText and filterText:lower() or ""

    if filterText == LDData.reservePlaceholder:lower() then
        filterText = ""
    end

    for _, row in ipairs(rows) do row:Hide() end

    local flatRows = {}
    for itemID, raiders in pairs(SoftResSaved) do
        itemID = tonumber(itemID)
        local itemName, itemLink = GetItemInfo(itemID)

        -- Fallbacks
        if not itemLink and itemName then
            itemLink = ("|cffffffff|Hitem:%d::::::::70:::::::::|h[%s]|h|r"):format(itemID, itemName)
        elseif not itemLink then
            itemName = "Unknown"
            itemLink = ("|cffffffff|Hitem:%d::::::::70:::::::::|h[%s]|h|r"):format(itemID, "Unknown")
        end

        for _, info in ipairs(raiders) do
            local name = info.name or "Unknown"
            local match = filterText == ""
                or (itemName and itemName:lower():find(filterText))
                or (name and name:lower():find(filterText))

            if match then
                table.insert(flatRows, {
                    item = itemName,
                    itemID = itemID,
                    link = itemLink,
                    name = name,
                    date = info.date or "-",
                    tradeable = getTradeableTimeLeft(itemID),
                })
            end
        end
    end

    -- Sort
    if LDData.currentSort.column then
        table.sort(flatRows, function(a, b)
            if LDData.currentSort.ascending then
                return tostring(a[LDData.currentSort.column]) < tostring(b[LDData.currentSort.column])
            else
                return tostring(a[LDData.currentSort.column]) > tostring(b[LDData.currentSort.column])
            end
        end)
    end

    -- Display
    for i, data in ipairs(flatRows) do
        local row = rows[i] or CreateRow(i)
        rows[i] = row
        row:SetPoint("TOPLEFT", f.reservesTableContainer, "TOPLEFT", 0, -(i-1) * LDData.rowHeight)
        row:Show()

        row.itemText:SetText(data.link or data.item)
        row.itemFrame.link = data.link

        row.playerText:SetText(data.name)
        row.dateText:SetText(data.date)
        row.tradeableText:SetText(data.tradeable)
    end

    f.reservesTableContainer:SetHeight(math.max(#flatRows * LDData.rowHeight, 250))

    -- Unique player + reserve count
    local uniquePlayers = {}
    local totalReserves = 0
    for _, row in ipairs(flatRows) do
        uniquePlayers[row.name] = true
        totalReserves = totalReserves + 1
    end

    local numPlayers = 0
    for _ in pairs(uniquePlayers) do numPlayers = numPlayers + 1 end

    f.statsLabel:SetText(string.format("Raid: %s  |  Players: %d  |  Reserves: %d",
        GuessMostFrequentDungeon(SoftResCSV) or "Unknown",
        numPlayers,
        totalReserves
    ))
end

-- GLOBALS
LDData.UpdateReservesTable = UpdateReservesTable