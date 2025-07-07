local LootDistr, LDData = ...
local f = LDData.main_frame

for k, v in pairs(f) do
    print("f." .. k, v)
end


function HideAllTabs()
    f.csvTab:Hide()
    f.reservesTab:Hide()
    f.lootWatcherTab:Hide()
    f.lootRollerTab:Hide()
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
        f.tickerFrame:Hide()
        f.csvEditBox:SetText(SoftResCSV or "")
    elseif index == 2 then
        f.reservesTab:Show()
        f.importBtn:Hide()
        f.deleteBtn:Show()
        f.searchBox:Show()
        f.reservesScroll:Show()
        f.reservesHeader:Show()
        UpdateReservesTable(f.searchBox:GetText())
        f.tickerFrame:Show()
    elseif index == 3 then
        f.lootWatcherTab:Show()
        f.importBtn:Hide()
        f.deleteBtn:Hide()
        f.searchBox:Hide()
        f.reservesScroll:Hide()
        f.reservesHeader:Hide()
        UpdateLootWatcherTable(f.lootSearchBox:GetText())
        f.tickerFrame:Show()
    elseif index == 4 then
        f:Show()
        ShowDummyLootRollerData()
        f.lootRollerTab:Show()
        f.lootWatcherTab:Hide()
        f.importBtn:Hide()
        f.deleteBtn:Hide()
        f.searchBox:Hide()
        f.reservesScroll:Hide()
        f.reservesHeader:Hide()
        f.tickerFrame:Hide()
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
    local tab = CreateFrame("Button", LootDistr .. "Tab" .. index, f)
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

local tabNames = { "Import CSV", "Soft Reserves", "Loot Watcher", "Loot Roller"}
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