---@class VCTickParams:VCEventParams
---@field Time GameTime
VCParams.Tick = VCEventParamsBase:Create("VCTickParams")

---@class VCEventTick: VCExtenderEventBase
---@field Subscribe fun(self:VCEventTick, callback:fun(e:VCTickParams))
Events.Extender.Tick = VCExtenderEventBase:CreateEvent("VCEventTick", { ExtenderEvent = Ext.Events.Tick })

---@param e LuaTickEvent
---@return VCTickParams
function Events.Extender.Tick:CreateParams(e)
    return VCParams.Tick:New {
        Time = e.Time
    }
end
