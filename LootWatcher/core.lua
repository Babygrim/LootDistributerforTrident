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

    row.playerFrame = CreateFrame("Button", nil, row)
    row.playerFrame:SetSize(LDData.lootHeaders[2].width, LDData.rowHeight)
    row.playerFrame:SetPoint("LEFT", row.itemFrame, "RIGHT", 0, 0)

    row.playerFrame:EnableMouse(true)
    row.playerFrame:SetFrameLevel(row:GetFrameLevel() + 1)
    row.playerFrame:SetFrameStrata("HIGH")

    row.playerFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()

        local entry = self.info
        local hasInfo = false

        -- Show Loot Roller rolls if available (grouped by spec)
        if entry.rolls and #entry.rolls > 0 and entry.rolls[1].spec then
            GameTooltip:AddLine("|cffffd100Loot Roller Rolls:|r", 1, 1, 1)
            
            -- Group rolls by spec
            local rollsBySpec = { Main = {}, Off = {}, TMOG = {} }
            for _, roll in ipairs(entry.rolls) do
                table.insert(rollsBySpec[roll.spec] or {}, roll)
            end
            
            -- Sort each spec group by roll value descending
            for _, rolls in pairs(rollsBySpec) do
                table.sort(rolls, function(a, b) return a.roll > b.roll end)
            end
            
            -- Display Main spec rolls
            if #rollsBySpec.Main > 0 then
                GameTooltip:AddLine("|cff00FF00\nMain:|r")
                for _, roll in ipairs(rollsBySpec.Main) do
                    local color = roll.winner and {1, 0.8, 0} or {1, 1, 1}
                    local text = string.format("  %s: %d%s",
                        roll.name,
                        roll.roll,
                        roll.winner and " [WINNER]" or ""
                    )
                    GameTooltip:AddLine(text, unpack(color))
                end
            end
            
            -- Display Off spec rolls
            if #rollsBySpec.Off > 0 then
                GameTooltip:AddLine("|cff4488FF\nOff:|r")
                for _, roll in ipairs(rollsBySpec.Off) do
                    local color = roll.winner and {1, 0.8, 0} or {1, 1, 1}
                    local text = string.format("  %s: %d%s",
                        roll.name,
                        roll.roll,
                        roll.winner and " [WINNER]" or ""
                    )
                    GameTooltip:AddLine(text, unpack(color))
                end
            end
            
            -- Display TMOG spec rolls
            if #rollsBySpec.TMOG > 0 then
                GameTooltip:AddLine("|cffB366FF\nTmog:|r")
                for _, roll in ipairs(rollsBySpec.TMOG) do
                    local color = roll.winner and {1, 0.8, 0} or {1, 1, 1}
                    local text = string.format("  %s: %d%s",
                        roll.name,
                        roll.roll,
                        roll.winner and " [WINNER]" or ""
                    )
                    GameTooltip:AddLine(text, unpack(color))
                end
            end
            
            hasInfo = true
        end

        -- Show Master Looter if available
        if entry.lootMethod == "master" and entry.looter then
            GameTooltip:AddLine(
                string.format("|cffffd100\nMaster Looter:|r %s", entry.looter),
                1, 1, 1
            )
            hasInfo = true
        end

        -- Show Group loot rolls if available - only show highest priority
        if entry.rolls and #entry.rolls > 0 and (not entry.rolls[1].spec) then
            GameTooltip:AddLine("|cffffd100Group Loot Rolls:|r", 1, 1, 1)
            
            -- Find highest priority roll type
            local hasNeed = false
            local hasGreed = false
            local hasDisenchant = false
            local hasPass = false
            local needPlayer, greedPlayer, disenchantPlayer, passPlayer
            
            for _, roll in ipairs(entry.rolls) do
                if roll.rollType == "NEED" then
                    hasNeed = true
                    needPlayer = roll.name
                elseif roll.rollType == "GREED" then
                    hasGreed = true
                    greedPlayer = roll.name
                elseif roll.rollType == "DISENCHANT" then
                    hasDisenchant = true
                    disenchantPlayer = roll.name
                elseif roll.rollType == "PASS" then
                    hasPass = true
                    passPlayer = roll.name
                end
            end
            
            -- Display highest priority (Need > Greed > Disenchant > Pass)
            if hasNeed then
                GameTooltip:AddLine(string.format("Need: %s", needPlayer), 0, 1, 0)
            elseif hasGreed then
                GameTooltip:AddLine(string.format("Greed: %s", greedPlayer), 0, 0.7, 1)
            elseif hasDisenchant then
                GameTooltip:AddLine(string.format("Disenchant: %s", disenchantPlayer), 0.7, 0.3, 1)
            elseif hasPass then
                GameTooltip:AddLine(string.format("Pass: %s", passPlayer), 0.7, 0.7, 0.7)
            end
            
            hasInfo = true
        end

        -- Show roll message if available (e.g., when no rolls were registered)
        if entry.rollMessage and not hasInfo then
            GameTooltip:AddLine("|cffffd100Loot Roller:|r " .. entry.rollMessage, 1, 1, 0)
            hasInfo = true
        end

        -- Show default message if no info available
        if not hasInfo then
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

function ExtractItemIDFromLink(itemLink)
    if not itemLink then return nil end
    return itemLink:match("|Hitem:(%d+):")
end

-- Updates the most recent loot entry for a given item ID with roll information
-- Prioritizes the freshest record that doesn't have rolls yet
function UpdateLootWatcherDataWithRolls(itemID, rollsData)
    if not itemID or not LootWatcherData then return false end
    
    -- Find the most recent entry with matching itemID that has no rolls yet
    for i = #LootWatcherData, 1, -1 do
        local entry = LootWatcherData[i]
        local entryItemID = ExtractItemIDFromLink(entry.item)
        if entryItemID == tostring(itemID) then
            -- Check if this entry has no rolls or empty rolls
            if not entry.rolls or #entry.rolls == 0 then
                entry.rolls = rollsData or {}
                return true
            end
        end
    end
    return false
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
        row.playerFrame.info = data

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