--[[
--- This file contains helper functions related to managing item lists in the game.
--- It allows for the creation of blocklists and allowlists for items, which can be then used to check if an item is in the list or not.
--- It supports saving and loading the lists from JSON files, with the ability to merge default items with the loaded items (e.g.: for updating the list with new), and has some error handling for missing or invalid files built-in.
--]]

---@class ItemList:MetaClass
---@field filePath string The path to the JSON file where the item list will be saved.
---@field items table A table of items to initialize the list with.
---@field defaultItems table A table of default items to initialize the list with.
---@field listType string The type of the list, either "blocklist" or "allowlist".
ItemList = _Class:Create("ItemList")

local ListTypes = {
    BLOCKLIST = "blocklist",
    ALLOWLIST = "allowlist",
}

--- Merges defaultItems with the loaded items, adding missing/new options
--- and ensuring that the items list remains a key-value mapping.
function ItemList:MergeItems(defaultItems)
    local hasNewItems = false
    for key, value in pairs(defaultItems or {}) do
        if self.items[key] == nil then -- Key does not exist, so add it
            self.items[key] = value
            hasNewItems = true
        end
    end
    return hasNewItems
end

--- Constructor for the ItemList class.
--- @class ItemList
--- @param filePath string The path to the JSON file where the item list will be saved.
--- @param defaultItems table A table of default items to initialize the list with.
function ItemList:New(filePath, defaultItems, listType)
    local self = setmetatable({}, ItemList)
    -- self.filePath = VCHelpers.Config:GetModFolderPath(filePath)
    self.filePath = filePath
    self.listType = listType or ListTypes.BLOCKLIST -- Default to "blocklist" if not provided
    self.defaultItems = defaultItems or {}

    -- Check if the JSON file exists
    local itemFileContent = Ext.IO.LoadFile(self.filePath)
    if itemFileContent and itemFileContent ~= "" then
        -- Load items from the file instead of using the default items or writing a new file
        self:Load()
        -- Merge defaultItems with the loaded items, adding missing/new options
        if self:MergeItems(defaultItems) then
            -- Save the updated list back to the file if there were new items
            self:Save()
        end
    else
        -- Use default items if file doesn't exist
        self.items = defaultItems or {}
        self:Save()
    end

    return self
end

--- Saves the current item list to a JSON file.
--- @param useDefaultItems boolean If true, the default items will be used instead of the current items.
function ItemList:Save(useDefaultItems)
    local writeItems = self.items
    if useDefaultItems then
        writeItems = self.defaultItems
    end

    local jsonString = Ext.Json.Stringify(writeItems, { Beautify = true })
    Ext.IO.SaveFile(self.filePath, jsonString)
end

--- Loads the item list from the JSON file.
function ItemList:Load()
    local fileContent = Ext.IO.LoadFile(self.filePath)
    if fileContent and fileContent ~= "" then
        local success, loadedItems = pcall(Ext.Json.Parse, fileContent)
        if success then
            self.items = loadedItems
        else
            VCWarn(0, "Failed to parse item list JSON: " .. self.filePath .. " - Creating new item list file.")
            self:Save(true)
        end
    else
        VCWarn(0, "Item list file not found: " .. self.filePath .. " - Creating new item list file.")
        self:Save(true)
    end
end

--- Gets the number of items in the item list table.
--- @return number The number of items in the item list table.
function ItemList:GetItemCount()
    local count = 0
    for _ in pairs(self.items) do
        count = count + 1
    end
    return count
end

--- Checks if an item is in the list.
--- @param itemName string The name of the item to check.
--- @return boolean Returns true if the item is in the list, false otherwise.
function ItemList:Contains(itemName)
    return self.items[itemName] == true
end

--- Gets the type of the list.
--- @return string The type of the list.
function ItemList:GetListType()
    return self.listType
end

--- Gets a random item from the list.
--- @return string|nil The name of a random item in the list, or nil if the list is empty.
function ItemList:GetRandomItem()
    local randomItems = {}
    for itemName, isIncluded in pairs(self.items) do
        if isIncluded then
            table.insert(randomItems, itemName)
        end
    end

    if #randomItems > 0 then
        return randomItems[math.random(#randomItems)]
    else
        return nil
    end
end

--- Filters out items from an inventory.
---@param inventory table An array of tables representing items, with Entity, Guid, Name, TemplateId, and TemplateName as keys.
---@return table An array of tables representing items, with Entity, Guid, Name, TemplateId, and TemplateName as keys, excluding items in the items list.
function ItemList:FilterOutIgnoredItems(inventory)
    local filteredItems = {}
    for _, item in ipairs(inventory) do
        -- Check if the item's template name is in the ignored items list
        if not self:Contains(item.TemplateName) then
            table.insert(filteredItems, item)
        end
    end

    return filteredItems
end
