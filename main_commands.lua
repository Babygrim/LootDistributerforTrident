local LootDistr, LDData = ...
local f = LDData.main_frame

SLASH_LOOTDISTRIBUTER1 = "/trident"
SlashCmdList["LOOTDISTRIBUTER"] = function(msg)
    if f:IsShown() then
        f:Hide()
    else
        LDData.CreateAddonTabs()
        f:Show()
    end
end

-- Alt+Click announce hook (unchanged)
hooksecurefunc("HandleModifiedItemClick", function(link)
    local lootMethod, masterLooter = GetLootMethod()
    srNames = {}

    if IsAltKeyDown() and link then
        if GetNumRaidMembers() > 0 then
            if lootMethod == "master" then
                if masterLooter == 0 then
                    if CurrentRollItem.ID == nil then
                        local itemName, itemLink, _, ilvl = GetItemInfo(link)
                        local itemID = tonumber(link:match("item:(%d+)"))

                        if itemID and itemLink and type(itemLink) == "string" then
                            LootRollerLocaleSettings = LootRollerLocaleSettings or GetLocale() or "enUS"
                            if SoftResSaved[itemID] then
                                local counts = {}
                                for _, info in ipairs(SoftResSaved[itemID]) do
                                    counts[info.name] = (counts[info.name] or 0) + 1
                                    source = info.source
                                end

                                
                                for name, count in pairs(counts) do
                                    if count >= 2 then
                                        table.insert(srNames, name .. " (" .. count .. "x)")
                                    else
                                        table.insert(srNames, name)
                                    end
                                end

                                local msg = string.format(LDData.localeMessages[LootRollerLocaleSettings].system.rollStartWithReserves, itemLink, table.concat(srNames, ", "))
                                SendChatMessage(msg, "RAID_WARNING")
                                LDData.softResRollNames = srNames
                                ShowLootRollerForItem(link, itemID, source, ilvl)
                            else
                                local msg = string.format(LDData.localeMessages[LootRollerLocaleSettings].system.rollStartNoReserves, itemLink)
                                SendChatMessage(msg, "RAID_WARNING")
                                LDData.softResRollNames = srNames
                                ShowLootRollerForItem(link, itemID, nil, ilvl)
                            end
                        else
                            print("|cffFF4500[LootDistributer]|r "..LDData.messages.system.itemIDError)
                        end
                    else
                        local itemName, itemLink, _, ilvl = GetItemInfo(CurrentRollItem.ID)
                        print("|cffFF4500[LootDistributer]|r "..string.format(LDData.messages.system.itemIsBeingRolledFor, itemLink))
                    end
                else
                    print("|cffFF4500[LootDistributer]|r "..LDData.messages.system.notLootMaster)
                end
            else
                print("|cffFF4500[LootDistributer]|r "..string.format(LDData.messages.system.lootNotMaster, lootMethod))
            end
        else
            print("|cffFF4500[LootDistributer]|r "..LDData.messages.system.notInRaid)
        end
    end
end)