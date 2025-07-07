local LootDistr, LDData = ...
local f = LDData.main_frame

function LDData.OnLootHeaderClickWatcher(self)
    local key = self.sortKey
    if LDData.currentLootSort.column == key then
        LDData.currentLootSort.ascending = not LDData.currentLootSort.ascending
    else
        LDData.currentLootSort.column = key
        LDData.currentLootSort.ascending = true
    end
    UpdateLootWatcherTable(f.lootSearchBox:GetText())
end

function LDData.OnLootHeaderClickReserves(self)
    local key = self.sortKey
    if LDData.currentSort.column == key then
        LDData.currentSort.ascending = not LDData.currentSort.ascending
    else
        LDData.currentSort.column = key
        LDData.currentSort.ascending = true
    end
    UpdateReservesTable(f.searchBox:GetText())
end

function LDData.OnLootHeaderEnter(self)
    self.text:SetTextColor(1, 1, 0, 1)
    self:SetBackdropColor(0.3, 0.3, 0.3, 0.5)
end

function LDData.OnLootHeaderLeave(self)
    self.text:SetTextColor(1, 1, 1, 1)
    self:SetBackdropColor(0, 0, 0, 0)
end

function LDData.OnTabClick(self)
    ShowTab(self.index)
    for i, t in ipairs(tabs) do
        if i == self.index then
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
end
