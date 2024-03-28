---@class HelperFormat: Helper
VCHelpers.Format = _Class:Create("HelperFormat", Helper)
VCHelpers.Format.NullUuid = "00000000-0000-0000-0000-000000000000"

---Numericize keys and values that are strings but should be numbers
---@param data any
---@return any
function VCHelpers.Format:Destringify(data)
    if type(data) == 'table' then
        local newtable = {}
        for key, value in pairs(data) do
            value = self:Destringify(value)
            if type(key) ~= "number" and tonumber(key) then
                newtable[tonumber(key)] = value
            else
                newtable[key] = value
            end
        end
        return newtable
    end
    return tonumber(data) or data
end

---Wrapper for json parse and destringify
---@param data any
---@return any
function VCHelpers.Format:Parse(data)
    local success, parsed = pcall(Ext.Json.Parse, data)
    if success then
        return self:Destringify(parsed)
    else
        return self:Destringify(data)
    end
end

---@param guid Guid
---@return string guid
function VCHelpers.Format:Guid(guid)
    return string.sub(tostring(guid), -36)
end

--- Get the template name from a local template UUID
---@param localtemplateUUID string
---@return string result
function VCHelpers.Format:GetTemplateName(localtemplateUUID)
    if #localtemplateUUID <= 36 then
        return localtemplateUUID -- Return the original string if it's too short
    end

    local result = string.sub(localtemplateUUID, 1, -37) -- Remove last 36 characters

    -- Remove trailing underscore if present
    result = result:gsub("_$", "")

    return result
end

---Copies an object and sets the copy's metatable as the original's.
---@param orig any
---@param copies? table
---@return any
function VCHelpers.Format:DeepCopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[self:DeepCopy(orig_key, copies)] = self:DeepCopy(orig_value, copies)
            end
            setmetatable(copy, self:DeepCopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--Takes a table and returns a new table with removed gaps in indexing due to nil values.
---@param t table
---@return table
function VCHelpers.Format:GetNonNilsTable(t)
    local new = {}
    local newIndex = 1
    for i, entry in pairs(t) do
        if tonumber(i) then
            new[newIndex] = entry
            newIndex = newIndex + 1
        elseif entry then
            new[i] = entry
        end
    end
    return new
end

---@param hex string
---@return vec3
function VCHelpers.Format:HexToRGB(hex)
    hex = hex:gsub('#', '')
    local r, g, b

    if hex:len() == 3 then
        r = tonumber('0x' .. hex:sub(1, 1)) * 17
        g = tonumber('0x' .. hex:sub(2, 2)) * 17
        b = tonumber('0x' .. hex:sub(3, 3)) * 17
    elseif hex:len() == 6 then
        r = tonumber('0x' .. hex:sub(1, 2))
        g = tonumber('0x' .. hex:sub(3, 4))
        b = tonumber('0x' .. hex:sub(5, 6))
    end

    r = r or 0
    g = g or 0
    b = b or 0

    return { r, g, b }
end

---@param hex string
---@return vec3
function VCHelpers.Format:HexToEffectRGB(hex)
    local rgb = self:HexToRGB(hex)
    rgb = Ext.Math.Div(rgb, 255)
    return rgb
end

---@param rgb vec3
---@return string
function VCHelpers.Format:RGBToHex(rgb)
    return string.format('%.2x%.2x%.2x', rgb[1], rgb[2], rgb[3])
end

---@param rgb vec3
---@return string
function VCHelpers.Format:EffectRGBToHex(rgb)
    return string.format('%.2x%.2x%.2x', Ext.Math.Round(rgb[1] * 255), Ext.Math.Round(rgb[2] * 255),
        Ext.Math.Round(rgb[3] * 255))
end

---@return Guid
function VCHelpers.Format:CreateUUID()
    return string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy]", function(c)
        return string.format("%x", c == "x" and Ext.Math.Random(0, 0xf) or Ext.Math.Random(8, 0xb))
    end)
end

function VCHelpers.Format:CreateHandle()
    return "h" .. string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy-]", function(c)
        if c == "x" then
            return string.format("%x", Ext.Math.Random(0, 0xf))
        elseif c == "y" then
            return string.format("%x", Ext.Math.Random(8, 0xb))
        elseif c == "-" then
            return "g"
        end
    end)
end

function VCHelpers.Format:MonotonicTimeToString()
    local timeInMilliseconds = Ext.Utils.MonotonicTime()
    local seconds = math.floor(timeInMilliseconds / 1000)
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)

    return string.format("%02d:%02d:%02d.%03d", hours, minutes % 60, seconds % 60, timeInMilliseconds % 1000)
end
