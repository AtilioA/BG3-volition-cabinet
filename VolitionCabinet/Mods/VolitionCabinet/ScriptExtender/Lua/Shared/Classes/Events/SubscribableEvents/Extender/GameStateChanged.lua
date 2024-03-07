---@class VCGameStateChangedParams:VCEventParams
---@field Event EsvLuaGameStateChangedEvent|EclLuaGameStateChangedEvent
---@field FromState ServerGameState|ClientGameState
---@field ToState ServerGameState|ClientGameState
VCParams.GameStateChanged = VCEventParamsBase:Create("VCGameStateChangedParams")

---@class VCEventGameStateChanged: VCExtenderEventBase
---@field Subscribe fun(self:VCEventGameStateChanged, callback:fun(e:VCGameStateChangedParams))
Events.Extender.GameStateChanged = VCExtenderEventBase:CreateEvent("VCEventGameStateChanged",
    { ExtenderEvent = Ext.Events.GameStateChanged })

---@param e EsvLuaGameStateChangedEvent|EclLuaGameStateChangedEvent
---@return VCGameStateChangedParams
function Events.Extender.GameStateChanged:CreateParams(e)
    return VCParams.GameStateChanged:New {
        Event = e,
        FromState = e.FromState,
        ToState = e.ToState,
    }
end
