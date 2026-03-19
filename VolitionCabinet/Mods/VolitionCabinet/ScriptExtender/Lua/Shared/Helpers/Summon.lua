---@class HelperSummon: Helper
VCHelpers.Summon = _Class:Create("HelperSummon", Helper)

--- Returns the stack group ID for a spell by inspecting its Summon/Spawn functors.
---@param spellId string
---@return string|nil
function VCHelpers.Summon:GetStackId(spellId)
    local stat = Ext.Stats.Get(spellId)
    if not stat or not stat.SpellProperties then return nil end
    for _, propGroup in ipairs(stat.SpellProperties) do
        for _, functor in ipairs(propGroup.Functors) do
            local typeId = functor.TypeId
            if (typeId == "Summon" or typeId == "Spawn") and functor.StackId and functor.StackId ~= "" then
                return functor.StackId
            end
        end
    end
    return nil
end

--- Returns the stack group ID for a summon template UUID, or nil if unmapped.
--- Caller must provide the template→stack data map.
---@param templateUuid string
---@param templateToStackMap table<string, string>
---@return string|nil
function VCHelpers.Summon:GetStackIdForTemplate(templateUuid, templateToStackMap)
    return templateToStackMap[templateUuid]
end
