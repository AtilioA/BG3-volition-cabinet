---@class VCUnequippedParams:VCEventParams
---@field ItemGuid Guid
---@field ItemEntity EntityHandle
---@field CharacterGuid Guid
---@field CharacterEntity Guid
VCParams.Unequipped = VCEventParamsBase:Create("VCUnequippedParams")

---@class VCEventUnequipped: VCOsirisEventBase
---@field Subscribe fun(self:VCEventUnequipped, callback:fun(e:VCUnequippedParams))
Events.Osiris.Unequipped = VCOsirisEventBase:CreateEvent("VCEventUnequipped",
    { OsirisEvent = "Unequipped", OsirisArity = 2 })

---@param item Guid
---@param character Guid
---@return VCUnequippedParams
function Events.Osiris.Unequipped:CreateParams(item, character)
    local params = VCParams.Unequipped:New {
        ItemGuid = VCHelpers.Format:Guid(item),
        ItemEntity = Ext.Entity.Get(item),
        CharacterGuid = VCHelpers.Format:Guid(character),
        CharacterEntity = Ext.Entity.Get(character),
    }
    return params
end
