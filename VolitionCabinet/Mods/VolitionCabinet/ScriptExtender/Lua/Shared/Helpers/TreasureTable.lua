-- TODO: document all this

--[[
    This Helper file holds functions and types that related to treasure tables, mainly treasure table retrieval without having to spawn containers and such.
-- ]]

---@class HelperTreasureTable: Helper
VCHelpers.TreasureTable = _Class:Create("HelperTreasureTable", Helper)

--- @class DropCount
--- @field Amount integer
--- @field Chance number

--- @class StatTreasureCategory
--- @field Common integer
--- @field Divine integer
--- @field Epic integer
--- @field Frequency integer
--- @field Legendary integer
--- @field Rare integer
--- @field TreasureCategory Category
--- @field Uncommon integer
--- @field Unique integer

--- @class TreasureTableItem
--- @field Name string
--- @field Id string
--- @field Quantity integer
--- @field NestedItems TreasureTableItem[]

--- Generates a JSON file containing all the treasure tables in the game.
function VCHelpers.TreasureTable:GenerateTreasureTableFile(filename)
    filename = filename or "All_TTs.json"
    local templates = Ext.Template.GetAllRootTemplates()
    local localTemp = Ext.Template.GetAllLocalTemplates()
    local result = {}
    local unpackedTT = {}

    -- Combine templates and localTemp tables
    local allTemplates = {}
    for k, v in pairs(templates) do
        table.insert(allTemplates, v)
    end
    for k, v in pairs(localTemp) do
        table.insert(allTemplates, v)
    end

    for i, template in pairs(allTemplates) do
        if template.TemplateType == "character" then
            if #template.TradeTreasures == 0 then
                TT = {}
            else
                TT = self:ProcessTreasureTables(template.TradeTreasures)
            end
            table.insert(result,
                {
                    LocaName = Ext.Loca.GetTranslatedString(template.DisplayName.Handle.Handle),
                    Name = template.Name,
                    Root = template.Id,
                    treasureTables = TT
                })
        end
    end

    Ext.IO.SaveFile(filename, Ext.DumpExport(result))
end

---@param template GameObjectTemplate
---@param filename string
function VCHelpers.TreasureTable:GenerateTreasureTableFromTemplate(template)
    local result = {}
    local unpackedTT = {}

    if template.TemplateType == "character" then
        if #template.TradeTreasures == 0 then
            TT = {}
        else
            TT = self:ProcessTreasureTables(template.TradeTreasures)
        end
        table.insert(result, {
            LocaName = Ext.Loca.GetTranslatedString(template.DisplayName.Handle.Handle),
            Name = template.Name,
            Root = template.Id,
            treasureTables = TT
        })
    end

    local filename = string.format("%s_TT.json", template.Name)
    Ext.IO.SaveFile(filename, Ext.DumpExport(result))
end

--Retrieves the treasure table associated with the specified name.
---@param treasureTableName string The name of the treasure table to retrieve.
---@return StatsTreasureTable? TreasureTable treasure table associated with the specified name, or nil if not found.
function VCHelpers.TreasureTable:GetTT(treasureTableName)
    return Ext.Stats.TreasureTable.GetLegacy(treasureTableName)
end

--- Retrieves the items contained in the specified treasure category.
---@param treasureCategoryName string The name of the treasure category to retrieve.
---@return StatTreasureCategory? TreasureCategory items contained in the specified treasure category, or nil if not found.
function VCHelpers.TreasureTable:GetTC(treasureCategoryName)
    return Ext.Stats.TreasureCategory.GetLegacy(treasureCategoryName)
end

--- Processes the treasure table given the specified treasure table name.
---@param treasureTableName string The name of the treasure table to process.
---@return StatsTreasureTable? The processed treasure table, or nil if not found.
function VCHelpers.TreasureTable:ProcessSingleTreasureTable(treasureTableName)
    local treasureTable = self:GetTT(treasureTableName)
    if treasureTable and treasureTable["TreasureTable"] ~= "Empty" then
        return self:RecursivelyGetTT(treasureTable)
    end
    return nil
end

--- Processes the treasure tables contained in the specified treasure tables.
---@param treasureTables string[] The treasure tables to process.
---@return StatsTreasureTable[] The processed treasure tables.
function VCHelpers.TreasureTable:ProcessTreasureTables(treasureTables)
    local processedTables = {}
    for k, v in pairs(treasureTables) do
        local TT = v
        if TT and #TT > 0 and TT ~= "Empty" then
            local tt = self:GetTT(TT)
            if tt then
                table.insert(processedTables, self:RecursivelyGetTT(tt))
            end
        end
    end
    return processedTables
end

--- Recursively retrieves the treasure tables and treasure categories contained in the specified treasure table.
---@param treasureTable StatsTreasureTable The treasure table to retrieve.
function VCHelpers.TreasureTable:RecursivelyGetTT(treasureTable)
    if treasureTable and treasureTable["TreasureTable"] ~= "Empty" then
        local subTables = treasureTable.SubTables
        if subTables then
            for i, subTable in ipairs(subTables) do
                local categories = subTable["Categories"]
                if categories then
                    for j, category in ipairs(categories) do
                        if category then
                            -- FIXME: borked probably but I don't know enough about treasure tables to fix it
                            local tt = VCHelpers.TreasureTable:GetTT(category.TreasureTable)
                            if tt then
                                category["TreasureTable"] = self:RecursivelyGetTT(tt)
                            end
                        elseif category["TreasureCategory"] then
                            category["TreasureCategory"] = self:GetTC(tostring(category["TreasureCategory"]))
                        end
                    end
                end
            end
        end
    end
    return treasureTable
end

--- Extracts the TreasureCategory objects from a sub-table
--- @param subTable StatsTreasureTable The sub-table to extract the categories from
--- @param categories StatsTreasureCategory[] The array to store the extracted categories
local function extractSubTableCategories(subTable, categories)
    if not subTable or not subTable.Categories then
        return
    end

    for _, category in ipairs(subTable.Categories) do
        if category.TreasureCategory then
            table.insert(categories, VCHelpers.TreasureTable:GetTC(tostring(category.TreasureCategory)))
        end
    end
end

--- Extracts all the TreasureCategory objects from a table
--- @param treasureTable StatsTreasureTable The table to extract the TreasureCategory objects from
--- @param categories StatsTreasureCategory[] The array to store the extracted categories
local function extractTreasureCategories(treasureTable, categories)
    if not treasureTable or not treasureTable.SubTables then
        return
    end

    for _, subTable in ipairs(treasureTable.SubTables) do
        extractSubTableCategories(subTable, categories)
    end
end

---@param treasureTable StatsTreasureTable The treasure table to extract TreasureCategory objects from
---@return StatsTreasureCategory[] An array of all the TreasureCategory objects in the treasure table
function VCHelpers.TreasureTable:ExtractTreasureCategories(treasureTable)
    local categories = {}
    extractTreasureCategories(treasureTable, categories)
    return categories
end

--- Retrieves the items contained in the treasure categories contained in the specified treasure table.
---@param treasureTableName string The treasure table to retrieve the items from.
---@return TreasureTableItem[] items The items contained in the treasure categories contained in the specified treasure table.
function VCHelpers.TreasureTable:GetTableOfItemsFromTreasureTable(treasureTableName)
    local treasureTable = self:ProcessSingleTreasureTable(treasureTableName)
    if not treasureTable then
        VCDebug(1, "Treasure table not found.")
        return {}
    end

    local treasureCategories = self:ExtractTreasureCategories(treasureTable)
    if not treasureCategories then
        VCDebug(1, "Treasure categories not found.")
        return {}
    end

    local items = self:GetItemsFromTreasureCategories(treasureCategories)
    local result = {}

    -- Recursively get items from the InventoryList of each item
    for _, item in ipairs(items) do
        local nestedItems = {}
        table.insert(result, {
            Name = item.Name,
            Id = item.Id,
            Quantity = item.Quantity,
            NestedItems = {}
        })
        if item.InventoryList then
            for _, treasureTableName in ipairs(item.InventoryList) do
                local nestedItemsFromTable = self:GetTableOfItemsFromTreasureTable(treasureTableName)
                for _, nestedItem in ipairs(nestedItemsFromTable) do
                    table.insert(nestedItems, nestedItem)
                end
            end
            result[#result].NestedItems = nestedItems
        end
    end

    return result
end

--- Retrieves the items contained in the specified treasure categories.
---@param treasureCategories Category[] The treasure categories to retrieve the items from.
---@return table items The items contained in the specified treasure categories.
function VCHelpers.TreasureTable:GetItemsFromTreasureCategories(treasureCategories)
    local rootTemplates = Ext.Template.GetAllRootTemplates()
    local items = {}

    for _, category in pairs(treasureCategories) do
        local categoryItems = self:GetItemsFromCategory(category, rootTemplates)
        for _, item in ipairs(categoryItems) do
            table.insert(items, item)
        end
    end

    return items
end

--- Retrieves the items contained in the specified treasure category.
---@param category Category The treasure category to retrieve the items from.
---@param rootTemplates GameObjectTemplate[] The root templates to check against.
---@return table items The items contained in the specified treasure category.
function VCHelpers.TreasureTable:GetItemsFromCategory(category, rootTemplates)
    local templatesNames = VCHelpers.Template.TemplateNameToUUID
    local items = {}

    for _, item in pairs(category.Items) do
        local rtInfo = templatesNames[item.Name]
        if rtInfo and rootTemplates[rtInfo.Id] then
            table.insert(items, {
                    InventoryList = rootTemplates[rtInfo.Id].InventoryList,
                    Name = rootTemplates[rtInfo.Id].Name,
                    Id = rootTemplates[rtInfo.Id].Id,
                    Quantity = item.MinAmount
                })
        end
    end

    return items
end

--- Retrieves the treasure tables associated with the specified template.
---@param template ItemTemplate The template to retrieve the treasure table from.
---@return string[] treasureTableNames The treasure tables names associated with the specified template.
function VCHelpers.TreasureTable:GetTreasureTableFromTemplate(template)
    return template.InventoryList
end


--- Refills the container with items from the treasure table, recursively handling nested items.
---@param containerID string The ID of the container to refill.
---@param ttItems TreasureTableItem[] The items to refill the container with, as returned by VCHelpers.TreasureTable:GetTableOfItemsFromTreasureTable.
function VCHelpers.TreasureTable:RefillContainerWithTTItems(containerID, ttItems)
    for _, item in ipairs(ttItems) do
        local hasRefillCreatedItem = VCHelpers.Inventory:RefillInventoryWithItem(item.Id, item.Quantity, containerID)

        -- Item already exists in the container, refill nested items if any
        if not hasRefillCreatedItem and item.NestedItems and #item.NestedItems > 0 then
            -- Get the local template of item, then refill it with its nested items
            local existingItem = VCHelpers.Inventory:GetItemTemplateInInventory(item.Id, containerID)
            if existingItem then
                -- Recursively refill the container with nested items; this will handle nested items of nested items as well
                self:RefillContainerWithTTItems(existingItem.Uuid.EntityUuid, item.NestedItems)
            end
        end
    end
end
