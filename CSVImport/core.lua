local LootDistr, LDData = ...
local f = LDData.main_frame

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
        local dungeon = LDData.BossToDungeon[bossName or ""] or nil
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
    local requiredCols = {
        ["Item"] = true, 
        ["ItemId"] = true, 
        ["From"] = true, 
        ["Name"] = true, 
        ["Date"] = true, 
        ["Class"] = true
    }

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

            local itemid = tonumber(cols[colIndices["ItemId"]])
            local raider = cols[colIndices["Name"]]
            local date = cols[colIndices["Date"]]
            local source = cols[colIndices["From"]]
            local class = cols[colIndices["Class"]]

            if itemid then
                if not reserves[itemid] then reserves[itemid] = {} end
                table.insert(reserves[itemid], {
                    name = raider or "Unknown",
                    date = date or "-",
                    source = source or "",
                    class = class or "Unknown",
                })
            end
        end
    end

    return reserves
end
