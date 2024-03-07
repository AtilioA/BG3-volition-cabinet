---@class VCDealtDamageParams:VCEventParams
---@field Event EsvLuaDealtDamageEvent
---@field Attacker EntityHandle|nil
---@field AttackerGuid Guid|nil
---@field Target EntityHandle
---@field TargetGuid Guid
---@field SpellId string
---@field TotalDamage integer
VCParams.DealtDamage = VCEventParamsBase:Create("VCDealtDamageParams")

--- Checks if the damage was dealt from a spell. Accepts any number of string params.
---@vararg string
---@return boolean
function VCParams.DealtDamage:FromSpell(...)
    for _, id in pairs({ ... }) do
        if self.SpellId == id then
            return true
        end
    end
    return false
end

--- Checks if the damage was dealt from a spell that contains the given name. Accepts any number of string params.
function VCParams.DealtDamage:FromSpellPrototype(...)
    for _, id in pairs({ ... }) do
        if string.find(self.SpellId, id) then
            return true
        end
    end
    return false
end

---@class VCEventDealtDamage: VCExtenderEventBase
---@field Subscribe fun(self:VCEventDealtDamage, callback:fun(e:VCDealtDamageParams))
Events.Extender.DealtDamage = VCExtenderEventBase:CreateEvent("VCEventDealtDamage",
    { ExtenderEvent = Ext.Events.DealtDamage })

---@param e EsvLuaDealtDamageEvent
---@return VCDealtDamageParams
function Events.Extender.DealtDamage:CreateParams(e)
    local params = VCParams.DealtDamage:New {
        Event = e,
        Attacker = e.Caster,
        Target = e.Target,
        SpellId = e.SpellId.Prototype,
        TotalDamage = e.Result.DamageSums.TotalDamageDone
    }

    if e.Caster ~= nil then
        params.AttackerGuid = e.Caster.Uuid.EntityUuid
    end

    params.TargetGuid = e.Target.Uuid.EntityUuid

    return params
end
