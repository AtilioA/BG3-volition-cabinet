---@class Helper: MetaClass
Helper = _Class:Create("Helper")
Helper.IsServer = Ext.IsServer()
Helper.IsClient = Ext.IsClient()

VCHelpers = {
    IsServer = Ext.IsServer(),
    IsClient = Ext.IsClient(),
}

RequireFiles("Shared/Helpers/", {
    "Config",
    "Printer",
    "Format",
    "ModVars",
    "UserVars",
    "Appearance",
    "Book",
    "Camp",
    "Character",
    "Commander",
    "Dice",
    "File",
    "Food",
    "Grid",
    "Hit",
    "Inventory",
    "Loca",
    "Log",
    "Object",
    "Party",
    "Passive",
    "Resource",
    "SpellBook",
    "SpellCast",
    "Status",
    "String",
    "Teleporting",
    "Timer",
    "Ware",
})
