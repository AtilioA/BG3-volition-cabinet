---@class VCComponent: MetaClass
VCComponent = _Class:Create("VCComponent")
VCComponent.IsServer = Ext.IsServer()
VCComponent.IsClient = Ext.IsClient()

Components = {}
RequireFiles("Shared/Components/", {
    -- "Health",
    -- "SpellCastState",
})
