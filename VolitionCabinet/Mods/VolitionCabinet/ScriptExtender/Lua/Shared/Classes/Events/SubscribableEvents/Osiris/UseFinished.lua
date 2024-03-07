---@class VCUseFinishedParams:VCEventParams
---@field ItemGuid Guid
---@field ItemEntity EntityHandle
---@field CharacterGuid Guid
---@field CharacterEntity Guid
---@field Success boolean
VCParams.UseFinished = VCEventParamsBase:Create("VCUseFinishedParams")

---@class VCEventUseFinished: VCOsirisEventBase
---@field Subscribe fun(self:VCEventUseFinished, callback:fun(e:VCUseFinishedParams))
Events.Osiris.UseFinished = VCOsirisEventBase:CreateEvent("VCEventUseFinished",
    { OsirisEvent = "UseFinished", OsirisArity = 3 })

---@param item Guid
---@param character Guid
---@return VCUseFinishedParams
function Events.Osiris.UseFinished:CreateParams(character, item, success)
    local params = VCParams.UseFinished:New {
        ItemGuid = Helpers.Format:Guid(item),
        ItemEntity = Ext.Entity.Get(item),
        CharacterGuid = Helpers.Format:Guid(character),
        CharacterEntity = Ext.Entity.Get(character),
        Success = success == 1
    }
    return params
end
