---@class HelperFile: Helper
VCHelpers.File = _Class:Create("HelperFile", Helper)

---@param modDirectoryName string
---@param files string[]
---@param debug? boolean
function VCHelpers.File:LoadStats(modDirectoryName, files, debug)
    for _, file in ipairs(files) do
        local fileName = string.format("Public/%s/Stats/Generated/Data/%s.txt", modDirectoryName, file)
        Ext.Stats.LoadStatsFile(fileName, debug)
    end

    if debug then
        VCDebug(1, "Finished loading stat files.")
    end
end

---@param files string[]
---@param debug? boolean
function VCHelpers.File:LoadLoca(files, debug)
    for _, file in ipairs(files) do
        local fileName = string.format("Localization/English/%s.xml", file)
        local contents = Ext.IO.LoadFile(fileName, "data")

        for line in string.gmatch(contents, "([^\r\n]+)\r*\n") do
            local handle, value = string.match(line, '<content contentuid="(%w+)".->(.+)</content>')
            if handle ~= nil and value ~= nil then
                value = value:gsub("&[lg]t;", {
                    ['&lt;'] = "<",
                    ['&gt;'] = ">"
                })
                Ext.Loca.UpdateTranslatedString(handle, value)
            end
        end
    end

    if debug then
        VCDebug(0, "Finished loading loca files.")
    end
end

---@param object any
---@param fileName? string Must define file extension
function VCHelpers.File:DumpToFile(object, fileName)
    local contents
    local entity = VCHelpers.Object:GetEntity(object)
    if entity ~= nil then
        contents = Ext.DumpExport(object:GetAllComponents())
    elseif type(object) == "userdata" then
        contents = Ext.Types.Serialize(object)
    elseif type(object) == "string" or type(object) == "number" then
        contents = object
    elseif type(object) == "table" then
        contents = Ext.DumpExport(object)
    end

    if contents ~= nil then
        fileName = fileName or "DumpObject.json"
        Ext.IO.SaveFile(fileName, contents)
        VCDebug(0, "Created file %s", fileName)
    else
        VCDebug(0, "Could not contruct contents %s to save to file %s", object, fileName)
    end
end

function VCHelpers.File:GenerateIDEHelpers()
    local fileName = string.format("IDEHelpersV%s.lua", Ext.Utils.Version())
    Ext.Types.GenerateIdeHelpers(fileName, {
        -- AddOsiris = false,
        -- AddDeprecated = false,
        AddAliasEnums = true,
        UseBaseExtraData = false,
        GenerateExtraDataAsClass = false
    })
end
