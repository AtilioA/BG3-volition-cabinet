---Ext.Require files at the path
---@param path string
---@param files string[]
function RequireFiles(path, files)
    for _, file in pairs(files) do
        Ext.Require(string.format("%s%s.lua", path, file))
    end
end

RequireFiles("Shared/", {
    "MetaClass",
    "Data/_Init",
    "Helpers/_Init",
    "Components/_Init",
    "Classes/_Init",
})

if Ext.Debug.IsDeveloperMode() then
    Helpers.Log:LogGameStates()
end