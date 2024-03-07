---@class HelperSpellBook: Helper
Helpers.SpellBook = _Class:Create("HelperSpellBook", Helper)

-- Spells from scrolls are sourceType "ActiveDefense"
---@param object any
---@param learnedSpell string
---@param sourceType SpellSourceType
---@param class Guid
function Helpers.SpellBook:RemoveSpell(object, learnedSpell, sourceType, class)
    local entity = Helpers.Object:GetEntity(object)
    if entity == nil then return end

    if entity.HotbarContainer ~= nil then
        local hotbar = Ext.Types.Serialize(entity.HotbarContainer)
        local editedHotbar = false
        for containerName, container in pairs(hotbar.Containers) do
            for i, subContainer in ipairs(container) do
                for j, spell in ipairs(subContainer.Elements) do
                    if spell.SpellId.OriginatorPrototype == learnedSpell and spell.SpellId.SourceType == sourceType then
                        table.remove(hotbar.Containers[containerName][i].Elements, j)
                        editedHotbar = true
                    end
                end
            end
        end

        if editedHotbar then
            Ext.Types.Unserialize(entity.HotbarContainer, hotbar)
            entity:Replicate("HotbarContainer")
        end
    end

    if entity.LearnedSpells ~= nil then
        local learnedSpells = Ext.Types.Serialize(entity.LearnedSpells)
        local editedLearnedSpells = false
        for i, spell in ipairs(learnedSpells.field_18[class]) do
            if spell == learnedSpell then
                table.remove(learnedSpells.field_18[class], i)
                editedLearnedSpells = true
                break
            end
        end

        if editedLearnedSpells then
            Ext.Types.Unserialize(entity.LearnedSpells, learnedSpells)
            entity:Replicate("LearnedSpells")
        end
    end

    if entity.SpellBook ~= nil then
        local spellBook = Ext.Types.Serialize(entity.SpellBook)
        local editedSpellBook = false
        for i, spell in ipairs(spellBook.Spells) do
            if spell.Id.OriginatorPrototype == learnedSpell and spell.Id.SourceType == sourceType then
                table.remove(spellBook.Spells, i)
                editedSpellBook = true
                break
            end
        end
        if editedSpellBook then
            Ext.Types.Unserialize(entity.SpellBook, spellBook)
            entity:Replicate("SpellBook")
        end
    end

    if entity.PlayerPrepareSpell ~= nil then
        local playerPrepareSpell = Ext.Types.Serialize(entity.PlayerPrepareSpell)
        local editedPlayerPrepareSpell = false
        for i, spell in ipairs(playerPrepareSpell.Spells) do
            if spell.OriginatorPrototype == learnedSpell and spell.SourceType == sourceType then
                table.remove(playerPrepareSpell.Spells, i)
                editedPlayerPrepareSpell = true
                break
            end
        end
        if editedPlayerPrepareSpell then
            Ext.Types.Serialize(entity.PlayerPrepareSpell, playerPrepareSpell)
            entity:Replicate("PlayerPrepareSpell")
        end
    end

    if entity.SpellBookPrepares ~= nil then
        local spellBookPrepares = Ext.Types.Serialize(entity.SpellBookPrepares)
        local editedSpellBookPrepares = false
        for i, spell in ipairs(spellBookPrepares.PreparedSpells) do
            if spell.OriginatorPrototype == learnedSpell and spell.SourceType == sourceType then
                table.remove(spellBookPrepares.PreparedSpells, i)
                editedSpellBookPrepares = true
                break
            end
        end

        if editedSpellBookPrepares then
            Ext.Types.Unserialize(entity.SpellBookPrepares, spellBookPrepares)
            entity:Replicate("SpellBookPrepares")
        end
    end

    if entity.SpellContainer ~= nil then
        local spellContainer = Ext.Types.Serialize(entity.SpellContainer)
        local editedSpellContainer = false
        for i, spell in ipairs(spellContainer.Spells) do
            if spell.SpellId.OriginatorPrototype == learnedSpell and spell.SpellId.SourceType == sourceType then
                table.remove(spellContainer.Spells[i])
                editedSpellContainer = true
                break
            end
        end

        if editedSpellContainer then
            Ext.Types.Unserialize(entity.SpellContainer, spellContainer)
            entity:Replicate("SpellContainer")
        end
    end
end

local skills = {
    Projectile_RayOfFrost_Monk = true
}

-- Character must have passive with "DynamicAnimationTag" "c4598bdb-fc07-40dd-a62c-90cc138bd76f"
---@param object Guid
function Helpers.SpellBook:SetMonkAnimations(object)
    Osi.AddBoosts(object, "ActionResource(KiPoint, 10, 0)", "", object)
    Osi.ApplyStatus(object, "FOCUSCORE_MONKANIMATION", -1)
    Osi.AddSpell(object, "Projectile_RayOfFrost_Monk")

    local progression = "c4598bdb-fc07-40dd-a62c-90cc138bd76f" -- Monk
    local source = "Progression1"
    local spellUUID = "d136c5d9-0ff0-43da-acce-a74a07f8d6bf"

    local entity = Ext.Entity.Get(object)
    if entity == nil then return end
    if entity.HotbarContainer ~= nil then
        for _, container in pairs(entity.HotbarContainer.Containers) do
            for _, subContainer in ipairs(container) do
                for _, spell in ipairs(subContainer.Elements) do
                    if skills[spell.SpellId.OriginatorPrototype] then
                        spell.SpellId.SourceType = source
                        spell.SpellId.ProgressionSource = progression
                        entity:Replicate("HotbarContainer")
                    end
                end
            end
        end
    end

    if entity.SpellBook ~= nil then
        for _, spell in pairs(entity.SpellBook.Spells) do
            if skills[spell.Id.OriginatorPrototype] then
                spell.Id.SourceType = source
                spell.Id.ProgressionSource = progression
                spell.SpellUUID = spellUUID
                entity:Replicate("SpellBook")
            end
        end
    
        for _, spell in pairs(entity.AddedSpells.Spells) do
            if skills[spell.SpellId.OriginatorPrototype] then
                spell.SpellId.SourceType = source
                spell.SpellId.ProgressionSource = progression
                spell.SpellUUID = spellUUID
            end
        end
    end

    if entity.PlayerPrepareSpell ~= nil then
        for _, spell in ipairs(entity.PlayerPrepareSpell.Spells) do
            if skills[spell.OriginatorPrototype] then
                spell.SourceType = source
                spell.ProgressionSource = progression
                entity:Replicate("PlayerPrepareSpell")
            end
        end
    end

    if entity.SpellBookPrepares ~= nil then
        for _, spell in ipairs(entity.SpellBookPrepares.PreparedSpells) do
            if skills[spell.OriginatorPrototype] then
                spell.SourceType = source
                spell.ProgressionSource = progression
                entity:Replicate("SpellBookPrepares")
            end
        end
    end

    if entity.SpellContainer ~= nil then
        for _, spell in ipairs(entity.SpellContainer.Spells) do
            if skills[spell.SpellId.OriginatorPrototype] then
                spell.SpellId.SourceType = source
                spell.SpellId.ProgressionSource = progression
                spell.SpellUUID = spellUUID
                entity:Replicate("SpellContainer")
            end
        end
    end

    Ext.Entity.Subscribe("SpellBook", function()
        for _, spell in pairs(entity.SpellBook.Spells) do
            if skills[spell.Id.OriginatorPrototype] then
                spell.Id.SourceType = source
                spell.Id.ProgressionSource = progression
                spell.SpellUUID = spellUUID
            end
        end

        for _, spell in pairs(entity.AddedSpells.Spells) do
            if skills[spell.SpellId.OriginatorPrototype] then
                spell.SpellId.SourceType = source
                spell.SpellId.ProgressionSource = progression
                spell.SpellUUID = spellUUID
            end
        end
    end, entity)

    Ext.Entity.Subscribe("PlayerPrepareSpell", function()
        for _, spell in ipairs(entity.PlayerPrepareSpell.Spells) do
            if skills[spell.OriginatorPrototype]then
                spell.SourceType = source
                spell.ProgressionSource = progression
            end
        end
    end, entity)


    Ext.Entity.Subscribe("SpellBookPrepares", function()
        for _, spell in ipairs(entity.SpellBookPrepares.PreparedSpells) do
            if skills[spell.OriginatorPrototype] then
                spell.SourceType = source
                spell.ProgressionSource = progression
            end
        end
    end, entity)

    Ext.Entity.Subscribe("SpellContainer", function()
        for _, spell in ipairs(entity.SpellContainer.Spells) do
            if skills[spell.SpellId.OriginatorPrototype] then
                spell.SpellId.SourceType = source
                spell.SpellId.ProgressionSource = progression
                spell.SpellUUID = spellUUID
            end
        end
    end, entity)
end