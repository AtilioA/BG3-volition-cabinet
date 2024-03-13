---@class Helper: MetaClass
Helper = _Class:Create("Helper")
Helper.IsServer = Ext.IsServer()
Helper.IsClient = Ext.IsClient()

Helpers = {
    IsServer = Ext.IsServer(),
    IsClient = Ext.IsClient()
}

RequireFiles("Shared/Helpers/", {
    "Config",
    "Printer",
    "Format",
    "ModVars",
    "UserVars",
    "Camp",
    "Character",
    "Teleporting",
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
    "String",
    "Timer",
    "Commander",
})
