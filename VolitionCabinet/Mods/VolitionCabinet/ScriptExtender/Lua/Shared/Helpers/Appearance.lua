---@class HelperAppearance: Helper
---@field CurrentAppearances table<Guid, Guid>
Helpers.Appearance = _Class:Create("HelperAppearance", Helper, {
    CurrentAppearances = {}
})

---@param item any
---@param appearance any
function Helpers.Appearance:SetItemAppearance(item, appearance)
    local entity = Helpers.Object:GetItem(item)
    if entity ~= nil then
        local appearanceUUID = Ext.Template.GetTemplate(appearance) ~= nil and appearance
        if not appearanceUUID then
            local appearanceEntity = Helpers.Object:GetItem(appearance)
            if appearanceEntity ~= nil then
                appearanceUUID = appearanceEntity.GameObjectVisual.RootTemplateId
            end
        end
        if appearanceUUID then
            self.CurrentAppearances[entity.Uuid.EntityUuid] = appearanceUUID
            entity:Replicate("GameObjectVisual")
            Osi.RemoveTransforms(entity.Uuid.EntityUuid)
            Events.Entity.GameObjectVisual:Subscribe(function(e)
                if self.CurrentAppearances[entity.Uuid.EntityUuid] == appearanceUUID then
                    e.Visual.RootTemplateId = appearanceUUID
                else
                    e:Unsubscribe()
                end
            end, {Entity = entity})
        end
    end
end

---@param characer any
---@param appearance any
function Helpers.Appearance:SetCharacterAppearance(characer, appearance)
    local entity = Helpers.Object:GetCharacter(characer)
    if entity ~= nil then
        local appearanceUUID = Ext.Template.GetTemplate(appearance) ~= nil and appearance
        if not appearanceUUID then
            local appearanceEntity = Helpers.Object:GetCharacter(appearance)
            if appearanceEntity ~= nil then
                appearanceUUID = appearanceEntity.GameObjectVisual.RootTemplateId
            end
        end
        if appearanceUUID then
            self.CurrentAppearances[entity.Uuid.EntityUuid] = appearanceUUID
            entity:Replicate("GameObjectVisual")
            entity:Replicate("EquipmentVisual")
            Events.Entity.GameObjectVisual:Subscribe(function(e)
                if self.CurrentAppearances[entity.Uuid.EntityUuid] == appearanceUUID then
                    e.Visual.RootTemplateId = appearanceUUID
                else
                    e:Unsubscribe()
                end
            end, {Entity = entity})
        end
    end
end

---@param object any
function Helpers.Appearance:UnsetAppearance(object)
    local entity = Helpers.Object:GetEntity(object)
    if entity ~= nil and self.CurrentAppearances[entity.Uuid.EntityUuid] then
        self.CurrentAppearances[entity.Uuid.EntityUuid] = nil
        entity:Replicate("GameObjectVisual")
    end
end

---@param object any
---@return string|nil
function Helpers.Appearance:GetObjectColorPreset(object)
    local colorPreset

    local entity = Helpers.Object:GetEntity(object)
    if entity ~= nil then
        if entity.ItemDye ~= nil and entity.ItemDye.Color ~= nil then
            colorPreset = entity.ItemDye.Color
        else
            local objectRT = Helpers.Object:GetRootTemplate(entity)
            if objectRT ~= nil then
                colorPreset = objectRT.ColorPreset
            end
        end
    end

    return colorPreset
end

---@param object any
function Helpers.Appearance:RemoveMaterialOverrides(object)
    local entity = Helpers.Object:GetEntity(object)
    if entity ~= nil and entity.MaterialParameterOverride ~= nil then
        entity.MaterialParameterOverride.field_0 = {}
        entity:Replicate("MaterialParameterOverride")
    end
end