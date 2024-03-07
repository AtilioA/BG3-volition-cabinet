---@class VCDoConsoleCommandParams:VCEventParams
---@field Event LuaDoConsoleCommandEvent
---@field Command string
VCParams.DoConsoleCommand = VCEventParamsBase:Create("VCDoConsoleCommandParams")

---@class VCEventDoConsoleCommand: VCExtenderEventBase
---@field Subscribe fun(self:VCEventDoConsoleCommand, callback:fun(e:VCDoConsoleCommandParams))
Events.Extender.DoConsoleCommand = VCExtenderEventBase:CreateEvent("VCEventDoConsoleCommand",
    { ExtenderEvent = Ext.Events.DoConsoleCommand })

---@param e LuaDoConsoleCommandEvent
---@return VCDoConsoleCommandParams
function Events.Extender.DoConsoleCommand:CreateParams(e)
    return VCParams.DoConsoleCommand:New {
        Event = e,
        Command = e.Command
    }
end
