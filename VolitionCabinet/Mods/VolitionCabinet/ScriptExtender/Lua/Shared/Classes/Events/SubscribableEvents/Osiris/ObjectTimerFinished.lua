---@class VCObjectTimerFinishedParams:VCEventParams
---@field Object EntityHandle
---@field ObjectGuid Guid
---@field Timer string
VCParams.ObjectTimerFinished = VCEventParamsBase:Create("VCObjectTimerFinishedParams")

---@class VCEventObjectTimerFinished: VCOsirisEventBase
---@field Subscribe fun(self:VCEventObjectTimerFinished, callback:fun(e:VCObjectTimerFinishedParams))
Events.Osiris.ObjectTimerFinished = VCOsirisEventBase:CreateEvent("VCEventObjectTimerFinished",
    { OsirisEvent = "ObjectTimerFinished", OsirisArity = 2 })

---@param object Guid
---@param timer string
---@return VCObjectTimerFinishedParams
function Events.Osiris.ObjectTimerFinished:CreateParams(object, timer)
    local params = VCParams.ObjectTimerFinished:New {
        Object = Ext.Entity.Get(object),
        ObjectGuid = Helpers.Format:Guid(object),
        Timer = timer
    }
    return params
end
