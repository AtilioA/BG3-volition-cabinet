---@class VCEquippedParams:VCEventParams
---@field CharacterGuid Guid
---@field Character EntityHandle
---@field ItemGuid Guid
---@field Item EntityHandle
VCParams.Equipped = VCEventParamsBase:Create("VCEquippedParams")

---@class VCEventEquipped: VCOsirisEventBase
---@field Subscribe fun(self:VCEventEquipped, callback:fun(e:VCEquippedParams))
Events.Osiris.Equipped = VCOsirisEventBase:CreateEvent("VCEventEquipped", { OsirisEvent = "Equipped", OsirisArity = 2 })

---@param item Guid
---@param character Guid
---@return VCEquippedParams
function Events.Osiris.Equipped:CreateParams(item, character)
    local params = VCParams.Equipped:New {
        CharacterGuid = Helpers.Format:Guid(character),
        Character = Ext.Entity.Get(character),
        ItemGuid = Helpers.Format:Guid(item),
        Item = Ext.Entity.Get(item),
    }
    return params
end
