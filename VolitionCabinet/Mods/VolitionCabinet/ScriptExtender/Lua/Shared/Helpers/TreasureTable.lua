--[[
    This Helper file holds functions and types that related to treasure tables, mainly treasure table retrieval without having to spawn containers and such.
-- ]]

---@class HelperTreasureTable: Helper
VCHelpers.TreasureTable = _Class:Create("HelperTreasureTable", Helper)

---@class StatTreasureCategoryItem
---@field Name string
---@field MinAmount integer
---@field MaxAmount integer

---@class StatTreasureCategory
---@field Items? StatTreasureCategoryItem[]

---@class StatTreasureCategoryEdge
---@field TreasureTable? string
---@field TreasureCategory? string

---@class StatTreasureSubTable
---@field Categories? StatTreasureCategoryEdge[]

---@class StatTreasureTable
---@field SubTables? StatTreasureSubTable[]

---@class TreasureCandidate
---@field Name string
---@field Id string
---@field MinAmount integer
---@field MaxAmount integer
---@field NestedItems TreasureCandidate[]

---@class TreasureRefillAggregate
---@field Id string
---@field MinAmount integer
---@field NestedItems TreasureCandidate[]

---@class TreasureResolutionState
---@field active table<string, integer>
---@field path string[]
---@field reportedCycles table<string, boolean>
---@field rootTemplates table<string, GameObjectTemplate>

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

--- Maps treasure table names to their unmodified snapshot.
---@param helper HelperTreasureTable
---@param treasureTableNames string[]
---@return StatTreasureTable[]
local function getTreasureTableSnapshots(helper, treasureTableNames)
    local snapshots = {}

    for _, treasureTableName in ipairs(treasureTableNames) do
        if treasureTableName and treasureTableName ~= "" and treasureTableName ~= "Empty" then
            local snapshot = helper:GetTT(treasureTableName)
            if snapshot then
                table.insert(snapshots, snapshot)
            end
        end
    end

    return snapshots
end

--- Builds a treasure table result entry from a character template.
---@param helper HelperTreasureTable
---@param template GameObjectTemplate
---@return table|nil
local function buildTreasureTableResult(helper, template)
    if template.TemplateType ~= "character" then
        return nil
    end
    local treasureTables = getTreasureTableSnapshots(helper, template.TradeTreasures)
    local locaName
    if template.DisplayName and template.DisplayName.Handle then
        locaName = Ext.Loca.GetTranslatedString(template.DisplayName.Handle.Handle)
    end
    locaName = locaName or template.Name
    return {
        LocaName = locaName,
        Name = template.Name,
        Root = template.Id,
        treasureTables = treasureTables
    }
end

--- Generates a JSON file containing all the treasure tables in the game.
---@param filename? string
function VCHelpers.TreasureTable:GenerateTreasureTableFile(filename)
    filename = filename or "All_TTs.json"
    local templates = Ext.Template.GetAllRootTemplates()
    local localTemp = Ext.Template.GetAllLocalTemplates()
    local result = {}

    local allTemplates = {}
    for _, v in pairs(templates) do
        table.insert(allTemplates, v)
    end
    for _, v in pairs(localTemp) do
        table.insert(allTemplates, v)
    end

    for _, template in ipairs(allTemplates) do
        local entry = buildTreasureTableResult(self, template)
        if entry then
            table.insert(result, entry)
        end
    end

    Ext.IO.SaveFile(filename, Ext.DumpExport(result))
end

---@param template GameObjectTemplate
function VCHelpers.TreasureTable:GenerateTreasureTableFromTemplate(template)
    local result = {}
    local entry = buildTreasureTableResult(self, template)
    if entry then
        table.insert(result, entry)
    end
    local filename = string.format("%s_TT.json", template.Name)
    Ext.IO.SaveFile(filename, Ext.DumpExport(result))
end

--- Appends candidates while preserving occurrence order and duplicates.
---@param target TreasureCandidate[]
---@param source TreasureCandidate[]?
local function appendCandidates(target, source)
    for _, candidate in ipairs(source or {}) do
        table.insert(target, candidate)
    end
end

--- Warns once for the cycle represented by the current active path.
---@param state TreasureResolutionState
---@param treasureTableName string
local function warnForCycle(state, treasureTableName)
    local cycle = {}
    for index = state.active[treasureTableName], #state.path do
        table.insert(cycle, state.path[index])
    end
    table.insert(cycle, treasureTableName)

    local cyclePath = table.concat(cycle, " -> ")
    if not state.reportedCycles[cyclePath] then
        state.reportedCycles[cyclePath] = true
        VCWarn(0, "Treasure table cycle detected: " .. cyclePath)
    end
end

---@type fun(helper: HelperTreasureTable, treasureTableName: string, state: TreasureResolutionState, isRoot: boolean): TreasureCandidate[]?
local resolveTreasureTable

--- Returns whether a value is a finite nonnegative integer.
---@param value any
---@return boolean
local function isNonnegativeInteger(value)
    return type(value) == "number" and value >= 0 and value < math.huge and value == math.floor(value)
end

--- Resolves and appends every item occurrence from a treasure category.
---@param helper HelperTreasureTable
---@param treasureCategoryName string
---@param candidates TreasureCandidate[]
---@param state TreasureResolutionState
local function appendTreasureCategoryCandidates(helper, treasureCategoryName, candidates, state)
    local treasureCategory = helper:GetTC(treasureCategoryName)
    if not treasureCategory then
        VCWarn(0, "Treasure category not found: " .. treasureCategoryName)
        return
    end

    for itemIndex, item in ipairs(treasureCategory.Items or {}) do
        local isValidName = type(item.Name) == "string" and item.Name:find("%S") ~= nil
        local isValidMinAmount = isNonnegativeInteger(item.MinAmount)
        local isValidMaxAmount = isNonnegativeInteger(item.MaxAmount)
        if not isValidName or not isValidMinAmount or not isValidMaxAmount or item.MaxAmount < item.MinAmount then
            VCWarn(0, string.format(
                "Invalid treasure category item in '%s' at index %d: Name=%s, MinAmount=%s, MaxAmount=%s",
                treasureCategoryName, itemIndex, tostring(item.Name), tostring(item.MinAmount), tostring(item.MaxAmount)))
        else
            local templateInfo = VCHelpers.Template.TemplateNameToUUID[item.Name]
            ---@type ItemTemplate?
            local template = templateInfo and state.rootTemplates[templateInfo.Id]
            if not template then
                VCWarn(0, "Treasure template not found: " .. item.Name)
            else
                local candidate = {
                    Name = template.Name,
                    Id = template.Id,
                    MinAmount = item.MinAmount,
                    MaxAmount = item.MaxAmount,
                    NestedItems = {}
                }

                for _, nestedTreasureTableName in ipairs(template.InventoryList or {}) do
                    appendCandidates(candidate.NestedItems,
                        resolveTreasureTable(helper, nestedTreasureTableName, state, false))
                end

                table.insert(candidates, candidate)
            end
        end
    end
end

--- Resolves one treasure table without modifying its snapshot.
---@param helper HelperTreasureTable
---@param treasureTableName string
---@param state TreasureResolutionState
---@param isRoot boolean
---@return TreasureCandidate[]?
resolveTreasureTable = function(helper, treasureTableName, state, isRoot)
    if not treasureTableName or treasureTableName == "" or treasureTableName == "Empty" then
        return {}
    end

    if state.active[treasureTableName] then
        warnForCycle(state, treasureTableName)
        return {}
    end

    local treasureTable = helper:GetTT(treasureTableName)
    if not treasureTable then
        VCWarn(0, "Treasure table not found: " .. treasureTableName)
        if isRoot then
            return nil
        end
        return {}
    end

    local candidates = {}
    state.active[treasureTableName] = #state.path + 1
    table.insert(state.path, treasureTableName)

    for _, subTable in ipairs(treasureTable.SubTables or {}) do
        for _, category in ipairs(subTable.Categories or {}) do
            if category.TreasureTable then
                appendCandidates(candidates,
                    resolveTreasureTable(helper, category.TreasureTable, state, false))
            end
            if category.TreasureCategory then
                appendTreasureCategoryCandidates(helper, category.TreasureCategory, candidates, state)
            end
        end
    end

    table.remove(state.path)
    state.active[treasureTableName] = nil
    return candidates
end

--- Enumerates all reachable item candidates from a treasure table.
---@param treasureTableName string
---@return TreasureCandidate[]? candidates Nil only when the named root table is missing.
function VCHelpers.TreasureTable:ResolveTreasureTableCandidates(treasureTableName)
    local state = {
        active = {},
        path = {},
        reportedCycles = {},
        rootTemplates = Ext.Template.GetAllRootTemplates(),
    }

    return resolveTreasureTable(self, treasureTableName, state, true)
end

--- Refills a container to the summed minimum quantity for each candidate ID.
---@param containerID string The ID of the container to refill.
---@param candidates TreasureCandidate[] The candidates returned by ResolveTreasureTableCandidates.
---@return integer refilledCount Number of distinct templates refilled.
function VCHelpers.TreasureTable:RefillContainerWithTreasureCandidates(containerID, candidates)
    if not containerID or containerID == "" or not candidates then
        return 0
    end

    ---@type TreasureRefillAggregate[]
    local aggregates = {}
    ---@type table<string, TreasureRefillAggregate>
    local aggregateById = {}

    for _, candidate in ipairs(candidates) do
        local aggregate = aggregateById[candidate.Id]
        if not aggregate then
            aggregate = {
                Id = candidate.Id,
                MinAmount = 0,
                NestedItems = {}
            }
            aggregateById[candidate.Id] = aggregate
            table.insert(aggregates, aggregate)
        end

        aggregate.MinAmount = aggregate.MinAmount + candidate.MinAmount
        appendCandidates(aggregate.NestedItems, candidate.NestedItems)
    end

    local refilledCount = 0
    for _, aggregate in ipairs(aggregates) do
        -- only repairs the first existing copy; multi-copy repair would need GetAllItemsWithTemplateInInventory
        local existingItem = #aggregate.NestedItems > 0
            and VCHelpers.Inventory:GetItemTemplateInInventory(aggregate.Id, containerID, false)
            or nil

        local hasRefillCreatedItem = VCHelpers.Inventory:RefillInventoryWithItem(aggregate.Id, aggregate.MinAmount,
            containerID)

        if hasRefillCreatedItem then
            refilledCount = refilledCount + 1
        end
        if existingItem then
            refilledCount = refilledCount +
                self:RefillContainerWithTreasureCandidates(existingItem.Uuid.EntityUuid, aggregate.NestedItems)
        end
    end

    return refilledCount
end
