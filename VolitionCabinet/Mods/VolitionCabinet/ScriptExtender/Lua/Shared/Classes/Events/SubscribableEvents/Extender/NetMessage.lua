---@class VCNetMessageParams:VCEventParams
---@field Event LuaNetMessageEvent
---@field Channel string
---@field Message any
VCParams.NetMessage = VCEventParamsBase:Create("VCNetMessageParams")

---@class VCEventNetMessage: VCExtenderEventBase
---@field Subscribe fun(self:VCEventNetMessage, callback:fun(e:VCNetMessageParams))
Events.Extender.NetMessage = VCExtenderEventBase:CreateEvent("VCEventNetMessage", { ExtenderEvent = Ext.Events
.NetMessage })

---@param e LuaNetMessageEvent
---@return VCNetMessageParams
function Events.Extender.NetMessage:CreateParams(e)
    return VCParams.NetMessage:New {
        Event = e,
        Channel = e.Channel,
        Message = e.Payload ~= "" and Helpers.Format:Parse(e.Payload) or ""
    }
end
