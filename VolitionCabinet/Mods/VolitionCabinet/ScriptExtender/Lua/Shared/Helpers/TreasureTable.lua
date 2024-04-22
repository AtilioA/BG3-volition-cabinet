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

--- @class Category
--- @field Category string
--- @field Items TreasureCategoryItem[]

--- @class TreasureCategoryItem
--- @field ActPart integer
--- @field MaxAmount integer
--- @field MaxLevel integer
--- @field MinAmount integer
--- @field MinLevel integer
--- @field Name string
--- @field Priority integer
--- @field Unique integer

--- @class TreasureSubTable
--- @field Categories StatTreasureCategory[]
--- @field DropCounts DropCount[]
--- @field EndLevel integer
--- @field StartLevel integer
--- @field TotalCount integer

--- @class StatTreasureTable
--- @field CanMerge boolean
--- @field IgnoreLevelDiff boolean
--- @field MaxLevel integer
--- @field MinLevel integer
--- @field Name string
--- @field SubTables TreasureSubTable[]
--- @field UseTreasureGroupContainers boolean

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

-- VCHelpers.TreasureTable.TemplatesNames = VCHelpers.Template:GetTemplateNameToTemplateData()

-- TODO: Only usable when SE v16 is released
-- Postpone the generation of the template-name-to-UUID table until the game has started, as an optimization.
-- if Ext.IsServer() then
--     Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(levelName, isEditorMode)
--         VCHelpers.TreasureTable.TemplatesNames = VCHelpers.Template:GetTemplateNameToTemplateData()
--     end)
-- end

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
---@return StatTreasureTable? TreasureTable treasure table associated with the specified name, or nil if not found.
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
---@return StatTreasureTable? The processed treasure table, or nil if not found.
function VCHelpers.TreasureTable:ProcessSingleTreasureTable(treasureTableName)
    local treasureTable = self:GetTT(treasureTableName)
    if treasureTable and treasureTable["TreasureTable"] ~= "Empty" then
        return self:RecursivelyGetTT(treasureTable)
    end
    return nil
end

--- Processes the treasure tables contained in the specified treasure tables.
---@param treasureTables string[] The treasure tables to process.
---@return StatTreasureTable[] The processed treasure tables.
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
---@param treasureTable StatTreasureTable The treasure table to retrieve.
function VCHelpers.TreasureTable:RecursivelyGetTT(treasureTable)
    if treasureTable and treasureTable["TreasureTable"] ~= "Empty" then
        local subTables = treasureTable["SubTables"]
        if subTables then
            for i, subTable in ipairs(subTables) do
                local categories = subTable["Categories"]
                if categories then
                    for j, category in ipairs(categories) do
                        if category then
                            -- FIXME: borked probably but I don't know enough about treasure tables to fix it
                            local tt = VCHelpers.TreasureTable:GetTT(category["TreasureTable"])
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

---@param treasureTable StatTreasureTable The treasure table to extract TreasureCategory objects from
---@return Category[] An array of all the TreasureCategory objects in the treasure table
function VCHelpers.TreasureTable:ExtractTreasureCategories(treasureTable)
    local categories = {}

    --- Extracts all the TreasureCategory objects from a table
    --- @param treasureTable StatTreasureTable The table to extract the TreasureCategory objects from
    local function extractCategories(treasureTable)
        if treasureTable.SubTables then
            for _, subTable in ipairs(treasureTable.SubTables) do
                if subTable.Categories then
                    for _, category in ipairs(subTable.Categories) do
                        if category.TreasureCategory then
                            table.insert(categories,
                                VCHelpers.TreasureTable:GetTC(tostring(category.TreasureCategory)))
                        end
                    end
                end
            end
        end
    end

    extractCategories(treasureTable)
    return categories
end

--- Retrieves the items contained in the treasure categories contained in the specified treasure table.
---@param treasureTableName string The treasure table to retrieve the items from.
---@return string[] items The items contained in the treasure categories contained in the specified treasure table.
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
            nestedItems = {}
        })
        if item.InventoryList then
            for _, treasureTableName in ipairs(item.InventoryList) do
                local nestedItemsFromTable = self:GetTableOfItemsFromTreasureTable(treasureTableName)
                for _, nestedItem in ipairs(nestedItemsFromTable) do
                    table.insert(nestedItems, nestedItem)
                end
            end
            result[#result].nestedItems = nestedItems
        end
    end

    return result
end

--- Retrieves the items contained in the specified treasure categories.
---@param treasureCategories Category[] The treasure categories to retrieve the items from.
---@return table items The items contained in the specified treasure categories.
function VCHelpers.TreasureTable:GetItemsFromTreasureCategories(treasureCategories)
    local items = {}
    local rootTemplates = Ext.Template.GetAllRootTemplates()

    for _, category in pairs(treasureCategories) do
        _D(category)
        self:GetItemsFromCategory(category, rootTemplates, items)
    end

    return items
end

--- Retrieves the items contained in the specified treasure category.
---@param category Category The treasure category to retrieve the items from.
---@param rootTemplates GameObjectTemplate[] The root templates to check against.
---@param items table The items table to add to.
---@return void
function VCHelpers.TreasureTable:GetItemsFromCategory(category, rootTemplates, items)
    for _, item in pairs(category.Items) do
        _D(item.Name)
        local templateUUID = VCHelpers.TreasureTable.TemplatesNames[item.Name]
        if templateUUID then
            _D(rootTemplates[templateUUID].InventoryList)
            table.insert(items,
                {
                    InventoryList = rootTemplates[templateUUID].InventoryList,
                    Name = rootTemplates[templateUUID].Name,
                    Id = rootTemplates[templateUUID].Id,
                    Quantity = item.MinAmount
                })
        end
    end
end

--- Retrieves the treasure tables associated with the specified template.
---@param template ItemTemplate The template to retrieve the treasure table from.
---@return string[] treasureTableNames The treasure tables names associated with the specified template.
function VCHelpers.TreasureTable:GetTreasureTableFromTemplate(template)
    return template.InventoryList
end
