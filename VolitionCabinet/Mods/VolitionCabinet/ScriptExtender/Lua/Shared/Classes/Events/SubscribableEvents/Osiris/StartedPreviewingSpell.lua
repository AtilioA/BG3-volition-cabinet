---@class VCPreviewingSpellParams:VCEventParams
---@field Attacker EsvCharacter|EsvItem|nil
---@field Spell string
---@field IsMostPowerful boolean
---@field HasMultipleLevels boolean
VCParams.PreviewingSpell = VCEventParamsBase:Create("VCPreviewingSpellParams")

---@class VCEventPreviewingSpell: VCOsirisEventBase
---@field Subscribe fun(self:VCEventPreviewingSpell, callback:fun(e:VCPreviewingSpellParams))
Events.Osiris.PreviewingSpell = VCOsirisEventBase:CreateEvent("VCEventPreviewingSpell",
    { OsirisEvent = "StartedPreviewingSpell", OsirisArity = 4 })

---@param attacker Guid
---@param spell string
---@param isMostPowerful integer
---@param hasMultipleLevels integer
---@return VCPreviewingSpellParams
function Events.Osiris.PreviewingSpell:CreateParams(attacker, spell, isMostPowerful, hasMultipleLevels)
    local params = VCParams.PreviewingSpell:New {
        Attacker = Ext.Entity.Get(attacker),
        Spell = spell,
        IsMostPowerful = isMostPowerful == 1,
        HasMultipleLevels = hasMultipleLevels == 1,
    }
    return params
end
