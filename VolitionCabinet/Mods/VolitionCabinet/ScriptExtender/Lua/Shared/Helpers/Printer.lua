---@class VolitionCabinetPrinter: MetaClass
---@field Prefix string
---@field Machine "S"|"C"
---@field Beautify boolean
---@field StringifyInternalTypes boolean
---@field IterateUserdata boolean
---@field AvoidRecursion boolean
---@field LimitArrayElements integer
---@field LimitDepth integer
---@field FontColor vec3
---@field BackgroundColor vec3
---@field ApplyColor boolean
VolitionCabinetPrinter = _Class:Create("VolitionCabinetPrinter", nil, {
    Prefix = "VolitionCabinetPrinter",
    Machine = Ext.IsServer() and "S" or "C",
    Beautify = true,
    StringifyInternalTypes = true,
    IterateUserdata = true,
    AvoidRecursion = true,
    LimitArrayElements = 3,
    LimitDepth = 1,
    FontColor = { 192, 192, 192 },
    BackgroundColor = { 12, 12, 12 },
    ApplyColor = false
})

---@param r integer 0-255
---@param g integer 0-255
---@param b integer 0-255
function VolitionCabinetPrinter:SetFontColor(r, g, b)
    self.FontColor = { r or 0, g or 0, b or 0 }
    --self:Print("Changed Font Color to %s %s %s", r, g, b)
end

---@param r integer 0-255
---@param g integer 0-255
---@param b integer 0-255
function VolitionCabinetPrinter:SetBackgroundColor(r, g, b)
    self.BackgroundColor = { r or 0, g or 0, b or 0 }
    --self:Print("Changed Background Color to %s %s %s", r, g, b)
end

---@param text string
---@param fontColor? vec3 Override the current font color
---@param backgroundColor? vec3 Override the current background color
---@return string
function VolitionCabinetPrinter:Colorize(text, fontColor, backgroundColor)
    local fr, fg, fb = table.unpack(fontColor or self.FontColor)
    local br, bg, bb = table.unpack(backgroundColor or self.BackgroundColor)
    return string.format("\x1b[38;2;%s;%s;%s;48;2;%s;%s;%sm%s", fr, fg, fb, br, bg, bb, text)
end

function VolitionCabinetPrinter:ToggleApplyColor()
    self.ApplyColor = not self.ApplyColor
    self:Print("Applying Color: %s", self.ApplyColor)
end

---@vararg any
function VolitionCabinetPrinter:Print(...)
    local s = string.format("[%s %s] ", self.Machine, self.Prefix)
    if self.ApplyColor then
        s = self:Colorize(s)
    end

    local f
    if #{ ... } <= 1 then
        f = tostring(...)
    else
        f = string.format(...)
    end

    Ext.Utils.Print(s .. f)
end

---@vararg any
function VolitionCabinetPrinter:PrintTest(...)
    local s = string.format("[%s %s][%s][%s] ", self.Machine, self.Prefix, "TEST", Ext.Utils.MonotonicTime())
    if self.ApplyColor then
        s = self:Colorize(s)
    end

    local f
    if #{ ... } <= 1 then
        f = tostring(...)
    else
        f = string.format(...)
    end

    Ext.Utils.Print(s .. f)
end

function VolitionCabinetPrinter:PrintWarning(...)
    local s = string.format("[%s %s][%s] ", self.Machine, self.Prefix, "WARN")
    if self.ApplyColor then
        s = self:Colorize(s)
    end

    local f
    if #{ ... } <= 1 then
        f = tostring(...)
    else
        f = string.format(...)
    end

    Ext.Utils.PrintWarning(s .. f)
end

function VolitionCabinetPrinter:PrintDebug(...)
    local s = string.format("[%s %s][%s][%s] ", self.Machine, self.Prefix, "DEBUG", Ext.Utils.MonotonicTime())
    if self.ApplyColor then
        s = self:Colorize(s)
    end

    local f
    if #{ ... } <= 1 then
        f = tostring(...)
    else
        f = string.format(...)
    end

    Ext.Utils.Print(s .. f)
end

---@param info any
---@param useOptions? boolean
---@param includeTime? boolean
function VolitionCabinetPrinter:Dump(info, useOptions, includeTime)
    local s = string.format("[%s %s][%s]", self.Machine, self.Prefix, "DUMP")
    if self.ApplyColor then
        s = self:Colorize(s)
    end

    if includeTime == true then
        s = string.format("%s[%s]", s, Ext.Utils.MonotonicTime())
    end

    s = s .. " "

    local infoString
    if useOptions == true then
        infoString = Ext.Json.Stringify(info, {
            Beautify = self.Beautify,
            StringifyInternalTypes = self.StringifyInternalTypes,
            IterateUserdata = self.IterateUserdata,
            AvoidRecursion = self.AvoidRecursion,
            LimitArrayElements = self.LimitArrayElements,
            LimitDepth = self.LimitDepth
        })
    else
        infoString = Ext.DumpExport(info)
    end
    Ext.Utils.Print(s, infoString)
end

---@param array FlashArray
---@param arrayName? string
function VolitionCabinetPrinter:DumpArray(array, arrayName)
    local name = arrayName or "array"
    for i = 1, #array do
        self:Print("%s[%s]: %s", name, i, array[i])
    end
end

--- VC printers

VCPrinter = VolitionCabinetPrinter:New { Prefix = "VolitionCabinet", ApplyColor = true }
function VCPrint(...)
    VCPrinter:SetFontColor(0, 255, 255)
    VCPrinter:Print(...)
end

function VCTest(...)
    VCPrinter:SetFontColor(100, 200, 150)
    VCPrinter:PrintTest(...)
end

function VCDebug(...)
    VCPrinter:SetFontColor(200, 200, 0)
    VCPrinter:PrintDebug(...)
end

function VCWarn(...)
    VCPrinter:SetFontColor(200, 100, 50)
    VCPrinter:PrintWarning(...)
end

function VCDump(...)
    VCPrinter:SetFontColor(190, 150, 225)
    VCPrinter:Dump(...)
end

function VCDumpArray(...) VCPrinter:DumpArray(...) end
