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

--- Builds a ServerCastRequest table for injecting into OsirisCastRequests.
---@param charGuid string
---@param spellId string
---@param targetGuid string|nil  Optional entity target, otherwise casts at a nearby position
---@param distance number|nil  Distance along facing normal for position target (default 2)
---@param getPosition fun(guid: string): number, number, number  Returns x, y, z
---@param getRotation fun(guid: string): number  Returns Y rotation in degrees
---@param findValidPosition fun(x: number, y: number, z: number, radius: number, guid: string, avoid: integer): number|nil, number|nil, number|nil
---@return table|nil
function VCHelpers.SpellCast:BuildCastRequest(charGuid, spellId, targetGuid, distance, getPosition, getRotation, findValidPosition)
    local entity = Ext.Entity.Get(charGuid)
    if not entity then return nil end

    local rootSpellId = VCHelpers.SpellStats:ResolveRootSpell(spellId)

    local spellInfo = VCHelpers.SpellStats:FindSpellInBook(entity, spellId)
    if not spellInfo then return nil end

    local nullUuid = "00000000-0000-0000-0000-000000000000"

    local stats = Ext.Stats.Get(spellId)
    local targetingType = stats and stats.SpellType or "Target"

    local targetInfo = {
        TargetingType = targetingType
    }

    if targetGuid then
        targetInfo.Target = Ext.Entity.Get(targetGuid)
    else
        local x, y, z = getPosition(charGuid)
        if x then
            local rotY = getRotation(charGuid)
            local rad = math.rad(rotY)
            local normal = { math.sin(rad), 0, math.cos(rad) }
            local pos = VCHelpers.Grid:FindPositionAlongNormal({ x, y, z }, normal, distance or 2)
            local vx, vy, vz = findValidPosition(pos[1], pos[2], pos[3], 5, charGuid, 1)
            if vx then
                pos = { vx, vy, vz }
            end
            targetInfo.Position = pos
        end
    end

    local originatorId = spellInfo.OriginatorId or rootSpellId

    return {
        CastOptions = {
            "ShowPrepareAnimation",
            "IgnoreSpellRolls",
            "IgnoreTargetChecks",
        },
        Caster = entity,
        RequestGuid = VCHelpers.Format:CreateUUID(),
        Spell = {
            OriginatorPrototype = originatorId,
            ProgressionSource   = spellInfo and spellInfo.ProgressionSource or nullUuid,
            Prototype           = spellId,
            Source              = spellInfo and spellInfo.Source or nullUuid,
            SourceType          = spellInfo and spellInfo.SourceType or "Osiris",
        },
        Targets = { targetInfo },
        field_A8 = 1
    }
end

--- Injects a cast request into OsirisCastRequests.
---@param request table
function VCHelpers.SpellCast:InjectCastRequest(request)
    local queuedRequests = Ext.System.ServerCastRequest.OsirisCastRequests
    queuedRequests[#queuedRequests + 1] = request
end

--- Convenience: build + inject in one call.
---@param charGuid string
---@param spellId string
---@param targetGuid string|nil
---@param distance number|nil
---@param getPosition fun(guid: string): number, number, number
---@param getRotation fun(guid: string): number
---@param findValidPosition fun(x: number, y: number, z: number, radius: number, guid: string, avoid: integer): number|nil, number|nil, number|nil
---@return boolean success
function VCHelpers.SpellCast:CastSpell(charGuid, spellId, targetGuid, distance, getPosition, getRotation, findValidPosition)
    local request = self:BuildCastRequest(charGuid, spellId, targetGuid, distance, getPosition, getRotation, findValidPosition)
    if not request then return false end
    self:InjectCastRequest(request)
    return true
end
