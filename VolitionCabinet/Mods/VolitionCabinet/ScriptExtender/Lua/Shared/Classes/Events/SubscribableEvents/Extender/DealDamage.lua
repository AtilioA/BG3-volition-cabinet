---@class VCDealDamageParams:VCEventParams
---@field Event EsvLuaDealDamageEvent
VCParams.DealDamage = VCEventParamsBase:Create("VCDealDamageParams")

---@class VCEventDealDamage: VCExtenderEventBase
---@field Subscribe fun(self:VCEventDealDamage, callback:fun(e:VCDealDamageParams))
Events.Extender.DealDamage = VCExtenderEventBase:CreateEvent("VCEventDealDamage", { ExtenderEvent = Ext.Events
.DealDamage })

---@param e EsvLuaDealDamageEvent
---@return VCDealDamageParams
function Events.Extender.DealDamage:CreateParams(e)
    return VCParams.DealDamage:New {
        Event = e
    }
end
