---@class VCVarsLoadedParams:VCEventParams
---@field Levels table<string, boolean>
---@field IsEditorLevel boolean
VCParams.VarsLoaded = VCEventParamsBase:Create("VCVarsLoadedParams")

---@class VCEventVarsLoaded: VCCustomEventBase
---@field Subscribe fun(self:VCEventVarsLoaded, callback:fun(e:VCVarsLoadedParams))
Events.Custom.VarsLoaded = VCCustomEventBase:CreateEvent("VCEventVarsLoaded")

-- ---@return VCVarsLoadedParams
-- function Events.Custom.VarsLoaded:CreateParams()
--     return VCParams.VarsLoaded:New()
-- end

-- if Ext.IsServer() then
--     function Events.Custom.VarsLoaded:RegisterEvent()
--         Ext.Events.SessionLoaded:Subscribe(function()
--             Ext.OnNextTick(function()
--                 if self:HasCallback() then
--                     self:Throw(self:CreateParams())
--                 end
--             end)
--         end)
--     end
-- else
--     function Events.Custom.VarsLoaded:RegisterEvent()
--         ---@param e EsvLuaGameStateChangedEvent
--         Ext.Events.GameStateChanged:Subscribe(function(e)
--             if self:HasCallback() and e.FromState == "PrepareRunning" and e.ToState == "Running" then
--                 Ext.OnNextTick(function()
--                     self:Throw(self:CreateParams())
--                 end)
--             end
--         end)
--     end
-- end
