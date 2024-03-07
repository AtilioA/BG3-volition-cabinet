---@class VCSawParams:VCEventParams
---@field SeerGuid Guid
---@field SeerName string
---@field SeerEntity EntityRef
---@field SpottedGuid Guid
---@field SpottedName string
---@field SpottedEntity EntityRef
---@field SpottedWasSneaking boolean
VCParams.Saw = VCEventParamsBase:Create("VCSawParams")

---@class VCEventSaw: VCOsirisEventBase
---@field Subscribe fun(self:VCEventSaw, callback:fun(e:VCSawParams))
Events.Osiris.Saw = VCOsirisEventBase:CreateEvent("VCEventSaw", { OsirisEvent = "Saw", OsirisArity = 3 })

---@param seer Guid
---@param spotted Guid
---@return VCSawParams
function Events.Osiris.Saw:CreateParams(seer, spotted, wasSneaking)
    local params = VCParams.Saw:New {
        SeerGuid = Helpers.Format:Guid(seer),
        SeerName = Osi.ResolveTranslatedString(Osi.GetDisplayName(seer)),
        SeerEntity = Ext.Entity.Get(seer),
        SpottedGuid = Helpers.Format:Guid(spotted),
        SpottedName = Osi.ResolveTranslatedString(Osi.GetDisplayName(spotted)),
        SpottedEntity = Ext.Entity.Get(spotted),
        SpottedWasSneaking = wasSneaking == 1
    }
    return params
end
