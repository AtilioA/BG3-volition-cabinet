---@class VCCastedSpellParams:VCEventParams
---@field CasterGuid Guid
---@field Caster EntityHandle
---@field Spell string
---@field SpellType SpellType
---@field SpellElement DamageType
---@field StoryActionID integer
VCParams.CastedSpell = VCEventParamsBase:Create("VCCastedSpellParams")


---@vararg string
---@return boolean
function VCParams.CastedSpell:IsSpell(...)
    for _, id in pairs({ ... }) do
        if id == self.Spell then
            return true
        end
    end
    return false
end

---@class VCEventCastedSpell: VCOsirisEventBase
---@field Subscribe fun(self:VCEventCastedSpell, callback:fun(e:VCCastedSpellParams))
Events.Osiris.CastedSpell = VCOsirisEventBase:CreateEvent("VCEventCastedSpell",
    { OsirisEvent = "CastedSpell", OsirisArity = 5 })

---@param caster Guid
---@param spell string
---@param spellType SpellType
---@param spellElement DamageType
---@param storyActionID integer
---@return VCCastedSpellParams
function Events.Osiris.CastedSpell:CreateParams(caster, spell, spellType, spellElement, storyActionID)
    local params = VCParams.CastedSpell:New {
        Caster = Ext.Entity.Get(caster),
        CasterGuid = VCHelpers.Format:Guid(caster),
        Spell = spell,
        SpellType = spellType,
        SpellElement = spellElement,
        StoryActionID = storyActionID,
    }
    return params
end
