---@class VCUsingSpellParams:VCEventParams
---@field AttackerEntity EntityHandle
---@field AttackerObject EsvCharacter|EsvItem
---@field AttackerGuid Guid
---@field Spell string
---@field SpellType string
---@field SpellElement string
---@field StoryID integer
VCParams.UsingSpell = VCEventParamsBase:Create("VCUsingSpellParams")

---@class VCEventUsingSpell: VCOsirisEventBase
---@field Subscribe fun(self:VCEventUsingSpell, callback:fun(e:VCUsingSpellParams))
Events.Osiris.UsingSpell = VCOsirisEventBase:CreateEvent("VCEventUsingSpell",
    { OsirisEvent = "UsingSpell", OsirisArity = 5 })

---@param attacker Guid
---@param spell string
---@param spellType string
---@param spellElement string
---@param storyActionID integer
---@return VCUsingSpellParams
function Events.Osiris.UsingSpell:CreateParams(attacker, spell, spellType, spellElement, storyActionID)
    local params = VCParams.UsingSpell:New {
        AttackerEntity = Helpers.Object:GetEntity(attacker),
        AttackerObject = Helpers.Object:GetObject(attacker),
        AttackerGuid = Helpers.Format:Guid(attacker),
        Spell = spell,
        SpelType = spellType,
        SpellElement = spellElement,
        StoryID = storyActionID,
    }
    return params
end
