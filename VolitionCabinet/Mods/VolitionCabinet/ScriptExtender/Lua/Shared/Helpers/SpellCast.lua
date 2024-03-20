---@class HelperSpellCast: Helper
VCHelpers.SpellCast = _Class:Create("HelperSpellCast", Helper)

-- Checks if the object is a spellcast entity
---@param object any
---@return boolean
function VCHelpers.SpellCast:IsSpellCast(object)
    if type(object) == "userdata" then
        if getmetatable(object) == "EntityProxy" and object.SpellCastState ~= nil then
            return true
        end
    end
    return false
end

---@param object any
---@return EntityHandle|nil
function VCHelpers.SpellCast:GetSpellCast(object)
    local entity = VCHelpers.Object:GetEntity(object)
    if entity ~= nil then
        if entity.SpellCastIsCasting ~= nil then
            return entity.SpellCastIsCasting.Cast
        end
    elseif self:IsSpellCast(object) then
        return object
    end
end

---@param object any
---@return EntityHandle|nil
function VCHelpers.SpellCast:GetCaster(object)
    local cast = self:GetSpellCast(object)
    if cast ~= nil then
        -- get caster
    end
end

---@param object any
---@return EntityHandle[]
function VCHelpers.SpellCast:GetTargets(object)
    local targets = {}

    local cast = self:GetSpellCast(object)
    if cast ~= nil then
        -- iterate through cast targets and add to array
    end

    return targets
end
