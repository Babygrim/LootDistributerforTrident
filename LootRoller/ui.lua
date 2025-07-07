local LootDistr, LDData = ...
local f = LDData.main_frame

-- Loot Roller Tab
f.lootRollerTab = CreateFrame("Frame", LootDistr .. "LootRollerTab", f)
f.lootRollerTab:SetPoint("TOPLEFT", 10, -70)
f.lootRollerTab:SetPoint("BOTTOMRIGHT", -10, 60)
f.lootRollerTab:Hide()

-- Item Icon
f.lootRollerItemIcon = f.lootRollerTab:CreateTexture(nil, "ARTWORK")
f.lootRollerItemIcon:SetSize(40,40)
f.lootRollerItemIcon:SetPoint("TOPLEFT", 10, -10)

-- Item Info Text (name, id, source, ilvl)
f.lootRollerItemInfo = f.lootRollerTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
f.lootRollerItemInfo:SetPoint("LEFT", f.lootRollerItemIcon, "RIGHT", 10, 0)
f.lootRollerItemInfo:SetJustifyH("LEFT")
f.lootRollerItemInfo:SetHeight(40)
f.lootRollerItemInfo:SetWidth(f.lootRollerTab:GetWidth() - 70)

-- Scroll Frame for rolls table
f.scrollFrame = CreateFrame("ScrollFrame", LootDistr .. "LootRollerScrollFrame", f.lootRollerTab, "UIPanelScrollFrameTemplate")
f.scrollFrame:SetPoint("TOPLEFT", f.lootRollerItemIcon, "BOTTOMLEFT", 0, -10)
f.scrollFrame:SetPoint("BOTTOMRIGHT", f.lootRollerTab, "BOTTOMRIGHT", -30, 10)

-- Scroll content (table container)
f.scrollContent = CreateFrame("Frame", LootDistr .. "LootRollerScrollContent", f.scrollFrame)
f.scrollContent:SetSize(f.scrollFrame:GetWidth(), 300)
f.scrollFrame:SetScrollChild(f.scrollContent)

-- Column Headers
local headers = {
    { name = "Player", x = 10, width = 120 },
    { name = "Class",  x = 140, width = 100 },
    { name = "Roll",   x = 250, width = 80 },
    { name = "Date",   x = 340, width = 160 },
}

local lootRollerHeaders = {}

for i, header in ipairs(headers) do
    local fontString = f.scrollContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fontString:SetPoint("TOPLEFT", header.x, -10)
    fontString:SetText(header.name)
    lootRollerHeaders[i] = fontString
end

-- Table Row Template
lootRollerRows = {}
function CreateRollRow(index)
    local row = CreateFrame("Frame", nil, f.scrollContent)
    row:SetSize(f.scrollContent:GetWidth(), 20)
    row:SetPoint("TOPLEFT", 0, -30 - (index - 1) * 20)

    row.player = row:CreateFontString(nil, "OVERLAY", "GameFontWhite")
    row.player:SetPoint("LEFT", 10, 0)
    row.player:SetWidth(120)

    row.class = row:CreateFontString(nil, "OVERLAY", "GameFontWhite")
    row.class:SetPoint("LEFT", 140, 0)
    row.class:SetWidth(100)

    row.roll = row:CreateFontString(nil, "OVERLAY", "GameFontWhite")
    row.roll:SetPoint("LEFT", 250, 0)
    row.roll:SetWidth(80)

    row.date = row:CreateFontString(nil, "OVERLAY", "GameFontWhite")
    row.date:SetPoint("LEFT", 340, 0)
    row.date:SetWidth(160)

    return row
end

-- Function to populate and refresh the table
function LDData:UpdateLootRollerTable(data)
    -- Sort by roll descending
    table.sort(data, function(a, b) return a.roll > b.roll end)

    -- Clear previous rows
    for _, row in ipairs(lootRollerRows) do
        row:Hide()
    end

    -- Show new rows
    for i, entry in ipairs(data) do
        if not lootRollerRows[i] then
            lootRollerRows[i] = CreateRollRow(i)
        end
        local row = lootRollerRows[i]
        row.player:SetText(entry.player or "")
        row.class:SetText(entry.class or "")
        row.roll:SetText(tostring(entry.roll or ""))
        row.date:SetText(entry.date or "")
        row:Show()
    end
end
