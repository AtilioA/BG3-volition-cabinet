--- Get the difference between two array-like tables
---@param table1 table
---@param table2 table
function table.getDifference(table1, table2)
    local difference = {}
    local set = {}

    for _, v in ipairs(table2) do
        set[v] = true
    end

    for _, v in ipairs(table1) do
        if not set[v] then
            table.insert(difference, v)
        end
    end

    return difference
end

--- Check if a table contains a value
---@param tbl table The table to search
---@param element any The element to find
---@return boolean - Whether the table contains the element
function table.contains(tbl, element)
    if type(tbl) ~= "table" then
        return false
    end

    if tbl == nil or element == nil then
        return false
    end

    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

--- Find the index of an element in a table
---@param tbl table The table to search
---@param element any The element to find
---@return integer|nil i The index of the element in the table, or nil if the element is not found
function table.indexOf(tbl, element)
    for i, value in ipairs(tbl) do
        if value == element then
            return i
        end
    end
    return nil
end

--- Check if a table is an array, since Lua couldn't be bothered to separate arrays and hash tables
---@param tbl table The table to check.
---@return boolean True if the table is an array, false otherwise.
function table.isArray(tbl)
    local index = 0
    for _ in pairs(tbl) do
        index = index + 1
        if tbl[index] == nil then
            return false
        end
    end
    return true
end

--- Check if a table is empty ([], {})
function table.isEmpty(tbl)
    return next(tbl) == nil
end

--- Lazily load a table value using a loader function.
---@param t table The table to modify.
---@param key any The key to lazily load.
---@param loader function The function to load the value.
function table.lazyLoad(t, key, loader)
    local cache = {}
    setmetatable(t, {
        __index = function(_, k)
            if k ~= key then
                return nil
            end

            if not cache[key] or table.isEmpty(cache[key]) then
                _D("Lazy loading key: " .. key)
                cache[key] = loader()
            end

            return cache[key]
        end
    })
end
