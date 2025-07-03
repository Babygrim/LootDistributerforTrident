-- Slash command to toggle UI
local addon = _G["LootDistributerforAnimia"]
local f = addon.frame

SLASH_LOOTDISTRIBUTER1 = "/animia"
SlashCmdList["LOOTDISTRIBUTER"] = function(msg)
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
    end
end

-- Alt+Click item announce in RAID_WARNING
hooksecurefunc("HandleModifiedItemClick", function(link)
    if IsAltKeyDown() then
        local itemName, itemLink = GetItemInfo(link)
        if itemLink and type(itemLink) == "string" then
            local reserves = SoftResSaved or {}
            if reserves[itemName] then
                local counts = {}
                for _, info in ipairs(reserves[itemName]) do
                    counts[info.name] = (counts[info.name] or 0) + 1
                end
                local names = {}
                for name, count in pairs(counts) do
                    if count >= 2 then
                        table.insert(names, name .. " (" .. count .. "x)")
                    else
                        table.insert(names, name)
                    end
                end
                local msg = "Roll for: " .. itemLink .. " - Reserved by: " .. table.concat(names, ", ")
                SendChatMessage(msg, "RAID_WARNING")
            else
                local msg = "Roll for: " .. itemLink .. " - No soft reserves"
                SendChatMessage(msg, "RAID_WARNING")
            end
        end
    end
end)
