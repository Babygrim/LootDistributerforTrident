local LootDistr, LDData = ...
local f = LDData.main_frame


local lootRows = {}

function CreateLootRow(index)
    local row = CreateFrame("Frame", nil, f.lootTableContainer)
    row:SetSize(570, LDData.rowHeight)

    -- Clickable item frame + text
    row.itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.itemText:SetPoint("LEFT", 0, 0)
    row.itemText:SetWidth(LDData.lootHeaders[1].width)
    row.itemText:SetJustifyH("CENTER")

    row.itemFrame = CreateFrame("Button", nil, row)
    row.itemFrame:SetSize(LDData.lootHeaders[1].width, LDData.rowHeight)
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
    row.playerText:SetWidth(LDData.lootHeaders[2].width)

    -- Count column
    row.countText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.countText:SetPoint("LEFT", row.playerText, "RIGHT", 0, 0)
    row.countText:SetWidth(LDData.lootHeaders[3].width)

    -- Time column
    row.timeText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.timeText:SetPoint("LEFT", row.countText, "RIGHT", 0, 0)
    row.timeText:SetWidth(LDData.lootHeaders[4].width)

    return row
end


function SortLootData()
    table.sort(LootWatcherData, function(a, b)
        local col = LDData.currentLootSort.column
        if LDData.currentLootSort.ascending then
            return tostring(a[col] or "") < tostring(b[col] or "")
        else
            return tostring(a[col] or "") > tostring(b[col] or "")
        end
    end)
end

function TrimLootWatcherData()
    local totalCount = 0
    for _, entry in ipairs(LootWatcherData) do
        totalCount = totalCount + (entry.count or 1)
    end

    while totalCount > 100 and #LootWatcherData > 0 do
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
    if filterText == LDData.lootPlaceholder then
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
    if LDData.currentLootSort.column then
        table.sort(filteredData, function(a, b)
            if LDData.currentLootSort.ascending then
                return tostring(a[LDData.currentLootSort.column]) < tostring(b[LDData.currentLootSort.column])
            else
                return tostring(a[LDData.currentLootSort.column]) > tostring(b[LDData.currentLootSort.column])
            end
        end)
    end

    -- Create filtered rows
    for i, data in ipairs(filteredData) do
        local row = CreateLootRow(i)
        row:SetPoint("TOPLEFT", f.lootTableContainer, "TOPLEFT", 10, rowY)
        rowY = rowY - LDData.rowHeight

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
            string.format("Raid: %s  |  Gold: |cffffff00%d|rg  |cffc7c7cf%d|rs  |cffeda55f%d|rc",
                GuessMostFrequentDungeon(SoftResCSV) or "Unknown", g, s, c)
        )
    else
        f.lootStatsLabel:SetText(
            string.format("Raid: %s  |  Gold: 0",
                GuessMostFrequentDungeon(SoftResCSV) or "Unknown")
        )
    end
end