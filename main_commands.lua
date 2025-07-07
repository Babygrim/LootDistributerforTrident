local LootDistr, LDData = ...
local f = LDData.main_frame

SLASH_LOOTDISTRIBUTER1 = "/trident"
SlashCmdList["LOOTDISTRIBUTER"] = function(msg)
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
    end
end

-- Alt+Click announce hook (unchanged)
hooksecurefunc("HandleModifiedItemClick", function(link)
    local lootMethod, masterLooter = GetLootMethod()

    if IsAltKeyDown() then
        if lootMethod == "master" then
            if masterLooter == 0 then
                local itemName, itemLink, _, ilvl = GetItemInfo(link)
                local itemID = tonumber(link:match("item:(%d+)"))

                if itemID and itemLink and type(itemLink) == "string" then
                    if SoftResSaved[itemID] then
                        local counts = {}
                        for _, info in ipairs(SoftResSaved[itemID]) do
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
                    ShowLootRollerForItem(itemID, itemName, "", ilvl)
                else
                    print("|cffFF4500[LootDistributer]|r Could not get itemID or link.")
                end
            else
                print("|cffFF4500[LootDistributer]|r You are not the loot master.")
            end
        else
            print("|cffFF4500[LootDistributer]|r Master loot is not enabled. Current loot system: " .. lootMethod)
        end
    end
end)

