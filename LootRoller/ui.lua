local LootDistr, LDData = ...
local f = LDData.main_frame

-- Loot Roller Tab
f.lootRollerTab = CreateFrame("Frame", LootDistr .. "LootRollerTab", f)
f.lootRollerTab:SetPoint("TOPLEFT", 10, -70)
f.lootRollerTab:SetPoint("BOTTOMRIGHT", -10, 60)

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


-- Header Labels
f.headerRoll = f.scrollContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
f.headerRoll:SetPoint("TOPLEFT", 10, -10)
f.headerRoll:SetText("Roll")

f.headerPlayer = f.scrollContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
f.headerPlayer:SetPoint("TOPLEFT", 80, -10)
f.headerPlayer:SetText("Player")

f.headerNote = f.scrollContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
f.headerNote:SetPoint("TOPLEFT", 250, -10)
f.headerNote:SetText("Note")
