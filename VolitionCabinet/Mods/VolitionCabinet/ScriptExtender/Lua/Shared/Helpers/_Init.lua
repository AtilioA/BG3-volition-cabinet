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
    "Color",
    "Commander",
    "Dialog",
    "Dice",
    "File",
    "Food",
    "Grid",
    "Hit",
    "Inventory",
    "Loca",
    "Log",
    "Lootable",
    "MessageBox",
    "Net",
    "Object",
    "Party",
    "Passive",
    "Rarity",
    "Resource",
    "SpellBook",
    "SpellCast",
    "Status",
    "String",
    "Table",
    "Teleporting",
    "Template",
    "Timer",
    "TreasureTable",
    "Ware",
    "CF",
})
