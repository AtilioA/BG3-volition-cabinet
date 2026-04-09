---@class HelperResource: Helper
---@field ActionResources table<string, Guid>
VCHelpers.Resource = _Class:Create("HelperResource", Helper, {
    ActionResources = {}
})

-- Ext.Events.SessionLoaded:Subscribe(function()
--     for _, resourceGuid in pairs(Ext.StaticData.GetAll("ActionResource")) do
--         local resource = Ext.StaticData.Get(resourceGuid, "ActionResource")
--         VCHelpers.Resource.ActionResources[resource.Name] = resourceGuid
--     end
-- end)


---@param object any
---@param resource "ActionPoint"|"BonusActionPoint"|"ReactionActionPoint"|"FocusSoulSpellCharge"|Guid|string Will accept resource guids or names
---@param amount "Max"|number
---@param subResourceId? integer Used for spell slot levels, etc.
---@param addTo? boolean Add to the current resource amount instead of overwriting
function VCHelpers.Resource:SetActionResource(object, resource, amount, subResourceId, addTo)
    local entity = VCHelpers.Object:GetEntity(object)
    if entity ~= nil then
        local res = self.ActionResources[resource] or resource
        local entityRes = entity.ActionResources.Resources[res]
        if entityRes ~= nil then
            subResourceId = subResourceId or 0
            for _, subRes in pairs(entityRes) do
                if subRes.ResourceUUID == res then
                    local finalAmount = amount == "Max" and subRes.MaxAmount or amount
                    if addTo then
                        subRes.Amount = Ext.Math.Clamp(subRes.Amount + finalAmount, 0, subRes.MaxAmount)
                    else
                        subRes.Amount = Ext.Math.Clamp(finalAmount, 0, subRes.MaxAmount)
                    end

                    entity:Replicate("ActionResources")
                end
            end
        end
    end
end

---@param object any
---@param resource "ActionPoint"|"BonusActionPoint"|"ReactionActionPoint"|"FocusSoulSpellCharge"|Guid|string Will accept resource guids or names
---@param subResourceId? integer Used for spell slot levels, etc.
---@return integer
function VCHelpers.Resource:GetActionResource(object, resource, subResourceId)
    local entity = VCHelpers.Object:GetEntity(object)
    if entity ~= nil then
        local res = self.ActionResources[resource] or resource
        local entityRes = entity.ActionResources.Resources[res]
        if entityRes ~= nil then
            subResourceId = subResourceId or 0
            for _, subRes in pairs(entityRes) do
                if subRes.ResourceUUID == subResourceId then
                    return subRes.Amount
                end
            end
        end
    end
    return 0
end

--- Returns true if the spell is currently on cooldown for this entity.
--- For container sub-spells, also checks the container's cooldown.
---@param entity table Entity with SpellBookCooldowns component
---@param spellId string
---@return boolean
function VCHelpers.Resource:IsSpellOnCooldown(entity, spellId)
    if not entity or not entity.SpellBookCooldowns then return false end

    local stat = Ext.Stats.Get(spellId)
    local containerId = (stat and stat.SpellContainerID ~= nil and stat.SpellContainerID ~= "")
        and stat.SpellContainerID or spellId

    for _, cooldownData in pairs(entity.SpellBookCooldowns.Cooldowns) do
        local onCooldownId = cooldownData.SpellId.Prototype
        if onCooldownId == spellId or onCooldownId == containerId then
            return true
        end
    end
    return false
end

--- Checks if a character has enough resources to cast a spell.
--- Uses Osi.GetActionResourceValuePersonal for resource queries.
---@param charGuid string
---@param spellId string
---@param getEntity fun(guid: string): table|nil  Function to resolve entity from guid
---@param getResourceValue fun(guid: string, resource: string, level: number): number|nil  Function to get action resource value
---@return boolean
function VCHelpers.Resource:HasResourcesForSpell(charGuid, spellId, getEntity, getResourceValue)
    local entity = getEntity(charGuid)
    if self:IsSpellOnCooldown(entity, spellId) then
        return false
    end

    local stats = Ext.Stats.Get(spellId)
    if not stats then return false end

    local costs = VCHelpers.SpellStats:ParseUseCosts(stats.UseCosts)
    if #costs == 0 then return true end

    for _, cost in ipairs(costs) do
        if cost.resource == "SpellSlotsGroup" or cost.resource == "SpellSlot" then
            local found = false
            for level = cost.minLevel, 6 do
                local slots = getResourceValue(charGuid, "SpellSlot", level) or 0
                local warlockSlots = getResourceValue(charGuid, "WarlockSpellSlot", level) or 0
                if slots >= cost.amount or warlockSlots >= cost.amount then
                    found = true
                    break
                end
            end
            if not found then return false end
        else
            local value = getResourceValue(charGuid, cost.resource, 0) or 0
            if value < cost.amount then return false end
        end
    end
    return true
end

--- Creates a snapshot of a character's current resources for multi-cast planning.
---@param charGuid string
---@param getResourceValue fun(guid: string, resource: string, level: number): number  Function to get action resource value
---@return table pool { SpellSlot={[1]=n,...,[6]=n}, WarlockSpellSlot={[1]=n,...,[6]=n}, [resourceName]=n }
function VCHelpers.Resource:CreateResourcePool(charGuid, getResourceValue)
    local pool = {
        SpellSlot = {},
        WarlockSpellSlot = {},
    }
    for level = 1, 6 do
        pool.SpellSlot[level] = getResourceValue(charGuid, "SpellSlot", level)
        pool.WarlockSpellSlot[level] = getResourceValue(charGuid, "WarlockSpellSlot", level)
    end
    pool.ActionPoint = getResourceValue(charGuid, "ActionPoint", 0)
    pool.BonusActionPoint = getResourceValue(charGuid, "BonusActionPoint", 0)
    pool.ChannelDivinity = getResourceValue(charGuid, "ChannelDivinity", 0)
    pool.KiPoint = getResourceValue(charGuid, "KiPoint", 0)
    pool.SorceryPoint = getResourceValue(charGuid, "SorceryPoint", 0)
    pool.WildShape = getResourceValue(charGuid, "WildShape", 0)
    return pool
end

--- Attempts to deduct costs for a spell from a virtual resource pool.
--- Mutates pool on success. Returns true if all costs satisfied, false otherwise.
--- Checks real cooldowns via entity (not simulated).
---@param pool table  Resource pool from CreateResourcePool
---@param entity table  Entity for cooldown checking
---@param spellId string
---@return boolean
function VCHelpers.Resource:TryDeductFromPool(pool, entity, spellId)
    if self:IsSpellOnCooldown(entity, spellId) then
        return false
    end

    local stats = Ext.Stats.Get(spellId)
    if not stats then return false end

    local costs = VCHelpers.SpellStats:ParseUseCosts(stats.UseCosts)
    if #costs == 0 then return true end

    -- Pre-check: verify all costs can be satisfied before mutating
    local deductions = {}
    for _, cost in ipairs(costs) do
        if cost.resource == "SpellSlotsGroup" or cost.resource == "SpellSlot" then
            local found = false
            for level = cost.minLevel, 6 do
                local slots = (pool.SpellSlot[level] or 0)
                local warlockSlots = (pool.WarlockSpellSlot[level] or 0)
                if slots >= cost.amount then
                    table.insert(deductions, { type = "SpellSlot", level = level, amount = cost.amount })
                    found = true
                    break
                elseif warlockSlots >= cost.amount then
                    table.insert(deductions, { type = "WarlockSpellSlot", level = level, amount = cost.amount })
                    found = true
                    break
                end
            end
            if not found then return false end
        elseif cost.resource == "ActionPoint" or cost.resource == "BonusActionPoint" then
            -- Skip per-turn combat resources
        else
            local current = pool[cost.resource] or 0
            if current < cost.amount then return false end
            table.insert(deductions, { type = "resource", name = cost.resource, amount = cost.amount })
        end
    end

    -- Apply deductions
    for _, d in ipairs(deductions) do
        if d.type == "SpellSlot" or d.type == "WarlockSpellSlot" then
            pool[d.type][d.level] = pool[d.type][d.level] - d.amount
        else
            pool[d.name] = pool[d.name] - d.amount
        end
    end
    return true
end
