local LootDistr, LDData = ...
local f = LDData.main_frame

-- Import CSV click event
f.importBtn:SetScript("OnClick", function()
    local text = f.csvEditBox:GetText()
    if not text or text == "" then
        print("|cffFF4500[LootDistributer]|r No CSV text to import!")
        return
    end

    -- Simple CSV check: first line should contain commas and required headers
    local firstLine = text:match("([^\r\n]+)")
    if not firstLine or not firstLine:find(",") then
        print("|cffFF4500[LootDistributer]|r Not a valid CSV format (missing commas or header row).")
        return
    end

    -- Check required columns exist in header
    local requiredCols = {["Item"] = true, ["ItemId"] = true, ["Name"] = true, ["Date"] = true}
    local found = {}
    for col in firstLine:gmatch("([^,]+)") do
        col = col:match("^%s*(.-)%s*$")
        if requiredCols[col] then
            found[col] = true
        end
    end
    for colName, _ in pairs(requiredCols) do
        if not found[colName] then
            print("|cffFF4500[LootDistributer]|r CSV is missing required column: |cffffff00" .. colName .. "|r")
            return
        end
    end

    -- If SoftResSaved already has data, confirm overwrite
    if next(SoftResSaved) ~= nil then
        StaticPopup_Show(LootDistr .. "ConfirmOverwrite")
    else
        -- No existing data, proceed directly
        local ok, result = pcall(parseCSV, text)
        if not ok then
            print("|cffFF4500[LootDistributer]|r CSV parse error: " .. result)
            return
        end
        SoftResSaved = result
        SoftResCSV = text
        print("|cff00FF00[LootDistributer]|r Imported soft reserves!")
        if f.reservesTab:IsShown() then
            UpdateReservesTable(f.searchBox:GetText())
        end
    end
end)