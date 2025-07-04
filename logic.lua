local addonName, addonTable = ...
local f = addonTable.main_frame

-- Import CSV related logic
function GuessMostFrequentDungeon(csvText)
    if not csvText or csvText == "" then return nil end

    -- Parse CSV lines
    local lines = {}
    for line in csvText:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    if #lines < 2 then return nil end

    -- Find header column index for "From"
    local headers = {}
    for col in lines[1]:gmatch("([^,]+)") do
        col = col:match("^%s*(.-)%s*$")
        table.insert(headers, col)
    end

    local fromIndex = nil
    for i, col in ipairs(headers) do
        if col == "From" then
            fromIndex = i
            break
        end
    end
    if not fromIndex then return nil end

    -- Count dungeons
    local dungeonCounts = {}
    for i = 2, #lines do
        local line = lines[i]
        local fields = {}
        local pos = 1
        while pos <= #line do
            local c = line:sub(pos, pos)
            if c == '"' then
                local closing = line:find('"', pos + 1)
                while closing and line:sub(closing + 1, closing + 1) == '"' do
                    closing = line:find('"', closing + 2)
                end
                if closing then
                    local field = line:sub(pos + 1, closing - 1):gsub('""', '"')
                    table.insert(fields, field)
                    pos = closing + 2
                    if line:sub(pos, pos) == ',' then pos = pos + 1 end
                else
                    table.insert(fields, line:sub(pos + 1))
                    break
                end
            else
                local comma = line:find(",", pos)
                if comma then
                    table.insert(fields, line:sub(pos, comma - 1))
                    pos = comma + 1
                else
                    table.insert(fields, line:sub(pos))
                    break
                end
            end
        end

        local bossName = fields[fromIndex] and fields[fromIndex]:match("^%s*(.-)%s*$")
        local dungeon = addonTable.BossToDungeon[bossName or ""] or nil
        if dungeon then
            dungeonCounts[dungeon] = (dungeonCounts[dungeon] or 0) + 1
        end
    end

    -- Find the dungeon with the most counts
    local maxCount = 0
    local mostFrequentDungeon = nil
    for dungeon, count in pairs(dungeonCounts) do
        if count > maxCount then
            maxCount = count
            mostFrequentDungeon = dungeon
        end
    end

    return mostFrequentDungeon or "Unknown"
end

function parseCSV(data)
    local reserves = {}

    local lines = {}
    for line in data:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    if #lines < 2 then
        return reserves
    end

    local header = lines[1]
    local headers = {}

    for col in header:gmatch("([^,]+)") do
        col = col:match("^%s*(.-)%s*$")
        table.insert(headers, col)
    end

    local colIndices = {}
    local requiredCols = {["Item"] = true, ["ItemId"] = true, ["Name"] = true, ["Date"] = true, ["Class"] = true}

    for i, colName in ipairs(headers) do
        if requiredCols[colName] then
            colIndices[colName] = i
        end
    end

    for colName, _ in pairs(requiredCols) do
        if not colIndices[colName] then
            error("Missing required column: " .. colName)
        end
    end

    for i = 2, #lines do
        local line = lines[i]

        -- Skip if this line is identical to the original header (case-insensitive, trimmed)
        if line:lower():gsub("%s+", "") ~= header:lower():gsub("%s+", "") then
            local cols = {}
            local pos = 1
            while pos <= #line do
                local c = line:sub(pos, pos)
                if c == '"' then
                    local closingQuote = line:find('"', pos+1)
                    while closingQuote and line:sub(closingQuote+1, closingQuote+1) == '"' do
                        closingQuote = line:find('"', closingQuote+2)
                    end
                    if closingQuote then
                        local field = line:sub(pos+1, closingQuote-1):gsub('""', '"')
                        table.insert(cols, field)
                        pos = closingQuote + 2
                        if line:sub(pos, pos) == ',' then pos = pos + 1 end
                    else
                        local field = line:sub(pos+1)
                        table.insert(cols, field)
                        break
                    end
                else
                    local comma = line:find(",", pos)
                    if comma then
                        local field = line:sub(pos, comma-1)
                        table.insert(cols, field)
                        pos = comma + 1
                    else
                        local field = line:sub(pos)
                        table.insert(cols, field)
                        break
                    end
                end
            end

            for i=1,#cols do
                cols[i] = cols[i]:match("^%s*(.-)%s*$")
            end

            local item = cols[colIndices["Item"]]
            local itemid = cols[colIndices["ItemId"]]
            local raider = cols[colIndices["Name"]]
            local date = cols[colIndices["Date"]]
            local class = cols[colIndices["Class"]]

            if item and item ~= "" then
                if not reserves[item] then reserves[item] = {} end
                table.insert(reserves[item], {
                    name = raider or "Unknown",
                    itemid = itemid,
                    date = date or "-",
                    class = class or "Unknown",
                })
            end
        end
    end

    return reserves
end













-- Reserves related logic

local rows = {}

function CreateRow(index)
    local row = CreateFrame("Frame", nil, f.reservesTableContainer)
    row:SetSize(570, addonTable.rowHeight)

    row.itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.itemText:SetPoint("LEFT", 10, 0)
    row.itemText:SetWidth(addonTable.colWidths[1])
    row.itemText:SetJustifyH("CENTER")

    row.itemFrame = CreateFrame("Button", nil, row)
    row.itemFrame:SetSize(addonTable.colWidths[1], addonTable.rowHeight)
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
    row.playerText:SetWidth(addonTable.colWidths[2])

    row.dateText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.dateText:SetPoint("LEFT", row.playerText, "RIGHT", 0, 0)
    row.dateText:SetWidth(addonTable.colWidths[3])

    row.tradeableText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.tradeableText:SetPoint("LEFT", row.dateText, "RIGHT", 0, 0)
    row.tradeableText:SetWidth(addonTable.colWidths[4])

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

    -- Treat placeholder as empty filter:
    if filterText == addonTable.reservePlaceholder:lower() then
        filterText = ""
    end

    for _, row in ipairs(rows) do row:Hide() end

    -- Flatten all rows
    local flatRows = {}
    for item, raiders in pairs(SoftResSaved) do
        for _, info in ipairs(raiders) do
            local match = filterText == "" or
                (item:lower():find(filterText) or (info.name and info.name:lower():find(filterText)))
            if match then
                local itemID = tonumber(info.itemid)
                local itemName, itemLink = GetItemInfo(itemID)
    
                -- If itemLink is nil, try to build a fake item link to allow clicks
                if not itemLink and itemID then
                    -- Fake item link format (works for clicks, tooltip may not show)
                    itemLink = ("|cffffffff|Hitem:%d::::::::70:::::::::|h[%s]|h|r"):format(itemID, item or "Unknown")
                elseif not itemLink then
                    -- Last fallback: just item name with white color, no link
                    itemLink = item or "Unknown"
                end
    
                table.insert(flatRows, {
                    item = item,
                    link = itemLink,
                    name = info.name or "Unknown",
                    date = info.date or "-",
                    tradeable = getTradeableTimeLeft(tonumber(info.itemid)),
                })
            end
        end
    end    

    -- Sort if requested
    if addonTable.currentSort.column then
        table.sort(flatRows, function(a, b)
            if addonTable.currentSort.ascending then
                return tostring(a[addonTable.currentSort.column]) < tostring(b[addonTable.currentSort.column])
            else
                return tostring(a[addonTable.currentSort.column]) > tostring(b[addonTable.currentSort.column])
            end
        end)
    end
    

    -- Display rows
    for i, data in ipairs(flatRows) do
        local row = rows[i] or CreateRow(i)
        rows[i] = row
        row:SetPoint("TOPLEFT", f.reservesTableContainer, "TOPLEFT", 0, -(i-1) * addonTable.rowHeight)
        row:Show()
    
        row.itemText:SetText(data.link or data.item)
        row.itemFrame.link = data.link  -- <---- THIS IS CRUCIAL
    
        row.playerText:SetText(data.name)
        row.dateText:SetText(data.date)
        row.tradeableText:SetText(data.tradeable)
    end

    f.reservesTableContainer:SetHeight(math.max(#flatRows * addonTable.rowHeight, 250))

    -- Count unique players and total soft reserves shown
    local uniquePlayers = {}
    local totalReserves = 0
    for item, raiders in pairs(SoftResSaved) do
        for _, info in ipairs(raiders) do
            -- Count only rows matching the current filter
            local match = filterText == "" or
                (item:lower():find(filterText) or (info.name and info.name:lower():find(filterText)))
            if match then
                uniquePlayers[info.name] = true
                totalReserves = totalReserves + 1
            end
        end
    end

    local numPlayers = 0
    for _ in pairs(uniquePlayers) do numPlayers = numPlayers + 1 end

    f.statsLabel:SetText(string.format("Raid: %s  |  Players: %d  |  Reserves: %d", GuessMostFrequentDungeon(SoftResCSV) or "Unknown", numPlayers, totalReserves))

end






















-- Loot Watcher related logic

local lootRows = {}

function CreateLootRow(index)
    local row = CreateFrame("Frame", nil, f.lootTableContainer)
    row:SetSize(570, addonTable.rowHeight)

    -- Clickable item frame + text
    row.itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.itemText:SetPoint("LEFT", 0, 0)
    row.itemText:SetWidth(addonTable.lootHeaders[1].width)
    row.itemText:SetJustifyH("CENTER")

    row.itemFrame = CreateFrame("Button", nil, row)
    row.itemFrame:SetSize(addonTable.lootHeaders[1].width, addonTable.rowHeight)
    row.itemFrame:SetPoint("LEFT", row, "LEFT", 0, 0)

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

    -- Player column
    row.playerText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.playerText:SetPoint("LEFT", row.itemText, "RIGHT", 0, 0)
    row.playerText:SetWidth(addonTable.lootHeaders[2].width)

    -- Count column
    row.countText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.countText:SetPoint("LEFT", row.playerText, "RIGHT", 0, 0)
    row.countText:SetWidth(addonTable.lootHeaders[3].width)

    -- Time column
    row.timeText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.timeText:SetPoint("LEFT", row.countText, "RIGHT", 0, 0)
    row.timeText:SetWidth(addonTable.lootHeaders[4].width)

    return row
end


function SortLootData()
    table.sort(LootWatcherData, function(a, b)
        local col = addonTable.currentLootSort.column
        if addonTable.currentLootSort.ascending then
            return tostring(a[col] or "") < tostring(b[col] or "")
        else
            return tostring(a[col] or "") > tostring(b[col] or "")
        end
    end)
end

function addonTable.TrimLootWatcherData()
    local totalCount = 0
    for _, entry in ipairs(LootWatcherData) do
        totalCount = totalCount + (entry.count or 1)
    end

    while totalCount > 1000 and #LootWatcherData > 0 do
        local oldest = table.remove(LootWatcherData, 1) -- remove oldest entry
        totalCount = totalCount - (oldest.count or 1)
    end
end

function UpdateLootWatcherTable(filterText)
    if not f.lootTableContainer then return end

    -- Clear old rows
    for _, child in ipairs({f.lootTableContainer:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    -- Normalize filter text
    if filterText == addonTable.lootPlaceholder then
        filterText = ""
    end

    local rowY = -2
    local filteredData = {}

    -- Filter data
    for _, entry in ipairs(LootWatcherData) do
        if filterText == "" or
           strfind(strlower(entry.item or ""), strlower(filterText)) or
           strfind(strlower(entry.player or ""), strlower(filterText)) then
            table.insert(filteredData, entry)
        end
    end

    -- Sort if requested
    if addonTable.currentLootSort.column then
        table.sort(filteredData, function(a, b)
            if addonTable.currentLootSort.ascending then
                return tostring(a[addonTable.currentLootSort.column]) < tostring(b[addonTable.currentLootSort.column])
            else
                return tostring(a[addonTable.currentLootSort.column]) > tostring(b[addonTable.currentLootSort.column])
            end
        end)
    end

    -- Create filtered rows
    for i, data in ipairs(filteredData) do
        local row = CreateLootRow(i)
        row:SetPoint("TOPLEFT", f.lootTableContainer, "TOPLEFT", 10, rowY)
        rowY = rowY - addonTable.rowHeight

        local _, link = GetItemInfo(data.item or "")
        link = link or data.item or ""

        -- Set item text and tooltip
        row.itemText:SetText(link)
        row.itemFrame.link = link

        -- Other columns
        row.playerText:SetText(data.player or "")
        row.countText:SetText(tostring(data.count or ""))
        row.timeText:SetText(data.time or "")
    end

    -- Update gold tracker label
    if LootWatcherGoldGained then
        local g = math.floor(LootWatcherGoldGained / 10000)
        local s = math.floor((LootWatcherGoldGained % 10000) / 100)
        local c = LootWatcherGoldGained % 100

        f.lootStatsLabel:SetText(
            string.format("Raid: %s  |  Gold: |cffffff00%d|r g  |cffc7c7cf%d|r s  |cffeda55f%d|r c", GuessMostFrequentDungeon(SoftResCSV) or "Unknown", g, s, c)
        )
    else
        f.lootStatsLabel:SetText("Raid: %s  |  Gold: 0", GuessMostFrequentDungeon(SoftResCSV) or "Unknown")
    end
end

















--- Tickers
local tickerFrame = CreateFrame("Frame")
local elapsed = 0

tickerFrame:SetScript("OnUpdate", function(self, delta)
    elapsed = elapsed + delta
    if elapsed >= 1 then
        elapsed = 0
        if f.reservesTab:IsShown() then
            UpdateReservesTable(f.searchBox:GetText())
        elseif f.lootWatcherTab:IsShown() then
            UpdateLootWatcherTable(f.lootSearchBox:GetText())
        end
    end
end)

tickerFrame:Hide() -- initially hidden


function HideAllTabs()
    f.csvTab:Hide()
    f.reservesTab:Hide()
    f.lootWatcherTab:Hide()    -- added
end

-- Show/Hide Tabs
function ShowTab(index)
    HideAllTabs()
    if index == 1 then
        f.csvTab:Show()
        f.importBtn:Show()
        f.deleteBtn:Hide()
        f.searchBox:Hide()
        f.reservesScroll:Hide()
        f.reservesHeader:Hide()
        tickerFrame:Hide()
        f.csvEditBox:SetText(SoftResCSV or "")
    elseif index == 2 then
        f.reservesTab:Show()
        f.importBtn:Hide()
        f.deleteBtn:Show()
        f.searchBox:Show()
        f.reservesScroll:Show()
        f.reservesHeader:Show()
        UpdateReservesTable(f.searchBox:GetText())
        tickerFrame:Show()
    elseif index == 3 then
        f.lootWatcherTab:Show()
        f.importBtn:Hide()
        f.deleteBtn:Hide()
        f.searchBox:Hide()
        f.reservesScroll:Hide()
        f.reservesHeader:Hide()
        UpdateLootWatcherTable(f.lootSearchBox:GetText())
        tickerFrame:Show()
    end
end


function OnTabClick(self)
    local index = self.index
    ShowTab(index)
    for i, tab in ipairs(tabs) do
        if i == index then
            tab:LockHighlight()
        else
            tab:UnlockHighlight()
        end
    end
end


function CreateTab(name, index)
    local tab = CreateFrame("Button", addonName .. "Tab" .. index, f)
    tab:SetHeight(24)
    tab:SetWidth(100)
    tab:SetNormalFontObject(GameFontNormalSmall)
    tab:SetHighlightFontObject(GameFontHighlightSmall)

    -- Background texture (left cap)
    tab.left = tab:CreateTexture(nil, "BACKGROUND")
    tab.left:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Left")
    tab.left:SetSize(20, 32)
    tab.left:SetPoint("TOPLEFT")

    -- Background texture (middle stretch)
    tab.middle = tab:CreateTexture(nil, "BACKGROUND")
    tab.middle:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Mid")
    tab.middle:SetHeight(32)
    tab.middle:SetPoint("LEFT", tab.left, "RIGHT")
    tab.middle:SetPoint("RIGHT", tab, "RIGHT", -20, 0)

    -- Background texture (right cap)
    tab.right = tab:CreateTexture(nil, "BACKGROUND")
    tab.right:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Right")
    tab.right:SetSize(20, 32)
    tab.right:SetPoint("TOPRIGHT")

    -- Button label
    tab.text = tab:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    tab.text:SetPoint("CENTER")
    tab.text:SetText(name)

    tab.index = index

    tab:SetScript("OnClick", function()
        ShowTab(index)
        for i, t in ipairs(tabs) do
            if i == index then
                t.text:SetTextColor(1, 0.82, 0)
                t.left:SetVertexColor(1, 0.82, 0)
                t.middle:SetVertexColor(1, 0.82, 0)
                t.right:SetVertexColor(1, 0.82, 0)
            else
                t.text:SetTextColor(0.8, 0.8, 0.8)
                t.left:SetVertexColor(1, 1, 1)
                t.middle:SetVertexColor(1, 1, 1)
                t.right:SetVertexColor(1, 1, 1)
            end
        end
    end)

    return tab
end

local tabNames = { "Import CSV", "View Reserves", "Loot Watcher" }
local tabOffsetX = 10
local tabSpacing = 5

tabs = {}

for i, name in ipairs(tabNames) do
    local tab = CreateTab(name, i)
    tab:SetPoint("TOPLEFT", f, "TOPLEFT", tabOffsetX + (i-1)*(100 + tabSpacing), -35)
    tabs[i] = tab
end

-- Highlight the first tab by default
tabs[1]:Click()



addonTable.UpdateLootWatcherTable = UpdateLootWatcherTable
addonTable.UpdateReservesTable = UpdateReservesTable