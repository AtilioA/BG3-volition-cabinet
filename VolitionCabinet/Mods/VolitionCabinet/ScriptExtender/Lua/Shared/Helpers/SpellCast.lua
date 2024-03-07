---@class HelperSpellCast: Helper
Helpers.SpellCast = _Class:Create("HelperSpellCast", Helper)

-- Checks if the object is a spellcast entity
---@param object any
---@return boolean
function Helpers.SpellCast:IsSpellCast(object)
    if type(object) == "userdata" then
        if getmetatable(object) == "EntityProxy" and object.SpellCastState ~= nil then
            return true
        end
    end
    return false
end

---@param object any
---@return EntityHandle|nil
function Helpers.SpellCast:GetSpellCast(object)
    local entity = Helpers.Object:GetEntity(object)
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
function Helpers.SpellCast:GetCaster(object)
    local cast = self:GetSpellCast(object)
    if cast ~= nil then
        -- get caster
    end
end

---@param object any
---@return EntityHandle[]
function Helpers.SpellCast:GetTargets(object)
    local targets = {}

    local cast = self:GetSpellCast(object)
    if cast ~= nil then
        -- iterate through cast targets and add to array
    end

    return targets
end
