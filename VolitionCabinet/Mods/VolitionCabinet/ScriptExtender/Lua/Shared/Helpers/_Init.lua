---@class Helper: MetaClass
Helper = _Class:Create("Helper")
Helper.IsServer = Ext.IsServer()
Helper.IsClient = Ext.IsClient()

Helpers = {
    IsServer = Ext.IsServer(),
    IsClient = Ext.IsClient()
}
RequireFiles("Shared/Helpers/", {
    "Printer",
    "Format",
    "ModVars",
    "UserVars",
    "Grid",
    "Object",
    "Appearance",
    "Dice",
    "File",
    "Hit",
    "Inventory",
    "Loca",
    "Log",
    "Passive",
    "Resource",
    "SpellCast",
    "SpellBook",
    "Status",
    "Timer",
    "Commander",
})
