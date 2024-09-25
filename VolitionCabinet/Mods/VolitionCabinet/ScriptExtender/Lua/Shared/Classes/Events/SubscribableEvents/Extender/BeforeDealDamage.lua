-- ---@type table<integer, {Attacker:EntityHandle, Target:EntityHandle}>
-- local HitPairs = {}

-- if Ext.IsServer() then
--     ---@param e EsvLuaDealDamageEvent
--     Ext.Events.DealDamage:Subscribe(function(e)
--         HitPairs[e.StoryActionId] = {
--             Attacker = e.Caster,
--             Target = e.Target
--         }
--     end)

--     ---@param e EsvLuaBeforeDealDamageEvent
--     Ext.Events.BeforeDealDamage:Subscribe(function(e)
--         HitPairs[e.Hit.StoryActionId] = nil
--     end, { Priority = 99 })
-- end

-- ---@class VCBeforeDealDamageParams:VCEventParams
-- ---@field Event EsvLuaBeforeDealDamageEvent
-- ---@field Attacker EntityHandle
-- ---@field Target EntityHandle
-- ---@field SpellId string
-- ---@field TotalDamage integer
-- VCParams.BeforeDealDamage = VCEventParamsBase:Create("VCBeforeDealDamageParams")

-- ---@class VCEventBeforeDealDamage: VCExtenderEventBase
-- ---@field Subscribe fun(self:VCEventBeforeDealDamage, callback:fun(e:VCBeforeDealDamageParams))
-- Events.Extender.BeforeDealDamage = VCExtenderEventBase:CreateEvent("VCEventBeforeDealDamage",
--     { ExtenderEvent = Ext.Events.BeforeDealDamage })

-- ---@param e EsvLuaBeforeDealDamageEvent
-- ---@return VCBeforeDealDamageParams
-- function Events.Extender.BeforeDealDamage:CreateParams(e)
--     return VCParams.BeforeDealDamage:New {
--         Event = e,
--         Attacker = HitPairs[e.Hit.StoryActionId].Attacker,
--         Target = HitPairs[e.Hit.StoryActionId].Target,
--         SpellId = e.Hit.SpellId,
--         TotalDamage = e.Hit.TotalDamageDone,
--     }
-- end
