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
    -- row.itemFrame:SetBackdrop({
    --     bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    --     edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    --     tile = true, tileSize = 16, edgeSize = 16,
    --     insets = { left = 4, right = 4, top = 4, bottom = 4 }
    -- })
    -- row.itemFrame:SetBackdropColor(0, 1, 0, 0.15)

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

    row.playerFrame = CreateFrame("Button", nil, row)
    row.playerFrame:SetSize(LDData.lootHeaders[2].width, LDData.rowHeight)
    row.playerFrame:SetPoint("LEFT", row.itemFrame, "RIGHT", 0, 0)
    -- row.playerFrame:SetBackdrop({
    --     bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    --     edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    --     tile = true, tileSize = 16, edgeSize = 16,
    --     insets = { left = 4, right = 4, top = 4, bottom = 4 }
    -- })
    -- row.playerFrame:SetBackdropColor(0, 1, 1, 0.15)

    row.playerFrame:EnableMouse(true)
    row.playerFrame:SetFrameLevel(row:GetFrameLevel() + 1)
    row.playerFrame:SetFrameStrata("HIGH")

    row.playerFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()

        local entry = self.info

        if entry.lootMethod == "master" then
            GameTooltip:AddLine(
                string.format("|cffffd100Master Looter:|r %s", entry.looter or "Unknown"),
                1, 1, 1
            )
        elseif entry.lootMethod == "group" and entry.rolls then
            GameTooltip:AddLine("|cffffd100Group Loot Rolls:|r", 1, 1, 1)
            for _, roll in ipairs(entry.rolls) do
                local color = {1,1,1}
                if roll.rollType == "NEED" then color = {0,1,0}
                elseif roll.rollType == "GREED" then color = {0,0.7,1}
                elseif roll.rollType == "DISENCHANT" then color = {0.7,0.3,1}
                elseif roll.rollType == "PASS" then color = {0.7,0.7,0.7}
                end
                local text = string.format("%s: %s%s",
                    roll.name,
                    roll.rollType,
                    roll.roll and (" ("..roll.roll..")") or ""
                )
                GameTooltip:AddLine(text, unpack(color))
            end
        else
            GameTooltip:AddLine("Item wasn't rolled or given by master looter.", 1, 1, 1)
        end

        GameTooltip:Show()
    end)

    row.playerFrame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

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
        row.playerFrame.info = {filteredData.lootMethod, filteredData.looter, filteredData.rolls}

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