---@class HelperSpellStats: Helper
VCHelpers.SpellStats = _Class:Create("HelperSpellStats", Helper)

--- Parses a UseCosts string into a list of cost entries.
--- e.g. "ActionPoint:1;SpellSlotsGroup:1:1:3" →
---   { { resource="ActionPoint", amount=1 }, { resource="SpellSlotsGroup", amount=1, minLevel=3 } }
---@param useCostsString string|nil
---@return table[]
function VCHelpers.SpellStats:ParseUseCosts(useCostsString)
    if not useCostsString or useCostsString == "" then return {} end

    local costs = {}
    for entry in useCostsString:gmatch("[^;]+") do
        local parts = {}
        for part in entry:gmatch("[^:]+") do
            parts[#parts + 1] = part
        end

        local resource = parts[1]
        if resource == "SpellSlotsGroup" or resource == "SpellSlot" then
            costs[#costs + 1] = {
                resource = resource,
                amount = tonumber(parts[2]) or 1,
                minLevel = tonumber(parts[4]) or tonumber(parts[2]) or 1,
            }
        else
            costs[#costs + 1] = {
                resource = resource,
                amount = tonumber(parts[2]) or 1,
            }
        end
    end
    return costs
end

--- Returns the cost classification for a spell.
---@param spellId string
---@return "SpellSlot"|"ShortRest"|"LongRest"|"Free"
function VCHelpers.SpellStats:ClassifySpellCost(spellId)
    local stat = Ext.Stats.Get(spellId)
    if not stat then return "Free" end

    local useCosts = stat.UseCosts or ""
    if string.find(useCosts, "SpellSlot", 1, true) then
        return "SpellSlot"
    end

    local cooldown = stat.Cooldown or ""
    if cooldown == "OnShortRest" then return "ShortRest" end
    if cooldown == "OnLongRest" then return "LongRest" end

    return "Free"
end

--- Resolves the root spell ID for a given spell.
--- Follows RootSpellID chain. Returns the original spellId if no root exists.
---@param spellId string
---@return string rootSpellId
function VCHelpers.SpellStats:ResolveRootSpell(spellId)
    local stats = Ext.Stats.Get(spellId)
    if stats and stats.RootSpellID and stats.RootSpellID ~= "" and stats.RootSpellID ~= spellId then
        return stats.RootSpellID
    end
    return spellId
end

--- Returns the list of sub-spell IDs from a container spell's ContainerSpells field.
--- Returns an empty table if the spell is not a container or has no sub-spells.
---@param spellId string
---@return string[]
function VCHelpers.SpellStats:GetContainerSubSpells(spellId)
    local stat = Ext.Stats.Get(spellId)
    if not stat then return {} end
    local containerSpells = stat.ContainerSpells
    if not containerSpells or containerSpells == "" then return {} end
    local result = {}
    for sub in containerSpells:gmatch("[^;]+") do
        table.insert(result, sub)
    end
    return result
end

--- Returns true if the given Summon/Spawn functor represents a permanent summon.
--- SpawnLifetime is a C++ variant: either a float (e.g. 60.0 = temporary) or a
--- StatsSummonLifetimeType enum (e.g. "Permanent", "UntilLongRest" = permanent).
---@param functor table
---@return boolean
function VCHelpers.SpellStats:IsPermanentSummon(functor)
    local lifetime = functor.SpawnLifetime
    if Ext.Types.GetValueType(lifetime) == "number" and lifetime > 0 then
        return false
    end
    return true
end

--- Returns true if the spell has a Summon or Spawn functor whose Template is a character.
---@param spellId string
---@param isCharacterTemplate fun(templateUuid: string): boolean  Callback to check if a template is a character
---@return boolean
function VCHelpers.SpellStats:HasSummonFunctor(spellId, isCharacterTemplate)
    local stat = Ext.Stats.Get(spellId)
    if not stat or not stat.SpellProperties then return false end

    local foundPermanent = false
    for _, propGroup in ipairs(stat.SpellProperties) do
        for _, functor in ipairs(propGroup.Functors) do
            if functor.TypeId == "Summon" or functor.TypeId == "Spawn" then
                if functor.Template and isCharacterTemplate(functor.Template) then
                    if not self:IsPermanentSummon(functor) then
                        return false
                    else
                        foundPermanent = true
                    end
                end
            end
        end
    end
    return foundPermanent
end

--- Looks up a spell in the entity's SpellBook to get real metadata.
--- Accepts both root spells and upcast variants (falls back to RootSpellID).
--- For container sub-spells, falls back to finding the container entry.
--- Returns the matched metadata plus OriginatorId: the spellbook key actually found.
---@param entity table
---@param spellId string
---@return table|nil  { ProgressionSource, Source, SourceType, OriginatorId }
function VCHelpers.SpellStats:FindSpellInBook(entity, spellId)
    if not entity or not entity.SpellBook or not entity.SpellBook.Spells then
        return nil
    end
    local rootId = self:ResolveRootSpell(spellId)
    for _, spell in ipairs(entity.SpellBook.Spells) do
        if spell.Id.OriginatorPrototype == rootId or spell.Id.Prototype == rootId then
            return {
                ProgressionSource = spell.Id.ProgressionSource,
                Source            = spell.Id.Source,
                SourceType        = spell.Id.SourceType,
                OriginatorId      = rootId,
            }
        end
    end

    -- Container sub-spell fallback
    local subStat = Ext.Stats.Get(spellId)
    local containerId = subStat and subStat.SpellContainerID
    if containerId and containerId ~= "" then
        for _, spell in ipairs(entity.SpellBook.Spells) do
            if spell.Id.OriginatorPrototype == containerId or spell.Id.Prototype == containerId then
                return {
                    ProgressionSource = spell.Id.ProgressionSource,
                    Source            = spell.Id.Source,
                    SourceType        = spell.Id.SourceType,
                    OriginatorId      = containerId,
                }
            end
        end
    end

    return nil
end
