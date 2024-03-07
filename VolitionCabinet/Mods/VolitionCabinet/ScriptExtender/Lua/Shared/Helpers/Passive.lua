---@class HelperPassive: Helper
---@field CurrentPassives table<Guid, Guid>
Helpers.Passive = _Class:Create("HelperPassive", Helper)

-- Passive.field_8 is the source, e.g. ItemEntity, CharacterEntity, ProgressionMeta
-- Passive.field_10 is the target, e.g. ItemEntity or CharacterEntity
---@param object any
---@param passive string
---@return PassiveComponent|nil
function Helpers.Passive:GetPassive(object, passive)
    local entity = Helpers.Object:GetEntity(object)
    if entity ~= nil then
        local passivesContainer = entity.PassiveContainer
        if passivesContainer ~= nil then
            for _, passiveEntity in pairs(passivesContainer.Passives) do
                if passiveEntity.Passive.PassiveId == passive then
                    return passiveEntity
                end
            end
        end
    end
end

---@param object any
---@param passive string
---@return boolean
function Helpers.Passive:HasActivePassive(object, passive)
    local entity = Helpers.Object:GetEntity(object)
    if entity ~= nil then
        if self:GetPassive(entity, passive) ~= nil then
            if entity.ServerToggledPassives ~= nil and entity.ServerToggledPassives.Passives[passive] ~= nil then
                return entity.ServerToggledPassives.Passives[passive]
            else
                return true
            end
        end
    end
    return false
end