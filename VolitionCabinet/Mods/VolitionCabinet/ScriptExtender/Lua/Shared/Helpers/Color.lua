---@class HelperColor: Helper
VCHelpers.Color = _Class:Create("HelperColor", Helper)

--- Create a table for the RGBA values
--- This is useful because of syntax highlighting that is not present when typing a table directly
---@param r number
---@param g number
---@param b number
---@param a number
---@return table<number> - The RGBA values as a table
function VCHelpers.Color:RGBA(r, g, b, a)
    return { r, g, b, a }
end

--- Create a table for the RGBA values, normalized to 0-1
--- This is useful because of syntax highlighting that is not present when typing a table directly
---@param r number
---@param g number
---@param b number
---@param a number
---@return table<number> - The RGBA values as a table
function VCHelpers.Color:NormalizedRGBA(r, g, b, a)
    return { r / 255, g / 255, b / 255, a }
end


--- Deprecated: Use VCHelpers.Color:HexToRGBA instead
function VCHelpers.Color:hex_to_rgba(hex)
    return self:HexToRGBA(hex)
end

--- Create a table for the RGBA values from a hex color string
---@param hex string The hex color string
---@return vec4
function VCHelpers.Color:HexToRGBA(hex)
    hex = hex:gsub('#', '')
    local r, g, b, a

    if hex:len() == 3 then
        r = tonumber('0x' .. hex:sub(1, 1)) * 17 / 255
        g = tonumber('0x' .. hex:sub(2, 2)) * 17 / 255
        b = tonumber('0x' .. hex:sub(3, 3)) * 17 / 255
    elseif hex:len() == 6 then
        r = tonumber('0x' .. hex:sub(1, 2)) / 255
        g = tonumber('0x' .. hex:sub(3, 4)) / 255
        b = tonumber('0x' .. hex:sub(5, 6)) / 255
    end

    r = r or 0
    g = g or 0
    b = b or 0
    a = 1

    return { r, g, b, a }
end

---@param hex string
---@return vec4
function VCHelpers.Color:HexToEffectRGB(hex)
    local rgb = self:HexToRGBA(hex)
    rgb = Ext.Math.Div(rgb, 255)
    return rgb
end

---@param rgba vec4
---@return string
function VCHelpers.Color:RGBAToHex(rgba)
    return string.format('%.2x%.2x%.2x%.2x', rgba[1], rgba[2], rgba[3], rgba[4] or 1)
end
