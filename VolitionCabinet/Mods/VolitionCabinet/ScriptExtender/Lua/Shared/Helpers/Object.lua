---@class HelperObject: Helper
---@field DefaultNearbyRadius 5
---@field ActionResources table<string, Guid>
Helpers.Object = _Class:Create("HelperObject", Helper, {
    DefaultNearbyRadius = 5,
})

---@param object any
---@return boolean
function Helpers.Object:IsCharacter(object)
    local objectType = type(object)
    if objectType == "userdata" then
        local mt = getmetatable(object)
        local userdataType = Ext.Types.GetObjectType(object)
        if mt == "EntityProxy" and object.IsCharacter ~= nil then
            return true
        elseif userdataType == "esv::CharacterComponent"
            or userdataType == "ecl::CharacterComponent"
            or userdataType == "esv::Character"
            or userdataType == "ecl::Character" then
            return true
        end
    elseif objectType == "string" or objectType == "number" then
        local entity = Ext.Entity.Get(object)
        return entity ~= nil and entity.IsCharacter ~= nil
    end
    return false
end

---@param object any
---@return boolean
function Helpers.Object:IsItem(object)
    local objectType = type(object)
    if objectType == "userdata" then
        local mt = getmetatable(object)
        local userdataType = Ext.Types.GetObjectType(object)
        if mt == "EntityProxy" and object.IsItem ~= nil then
            return true
        elseif userdataType == "esv::ItemComponent"
            or userdataType == "ecl::ItemComponent"
            or userdataType == "esv::Item"
            or userdataType == "ecl::Item" then
            return true
        end
    elseif objectType == "string" or objectType == "number" then
        local entity = Ext.Entity.Get(object)
        return entity ~= nil and entity.IsItem ~= nil
    end
    return false
end

---@param object any
---@return EntityHandle|nil
function Helpers.Object:GetCharacter(object)
    local objectType = type(object)
    if objectType == "userdata" then
        local mt = getmetatable(object)
        local userdataType = Ext.Types.GetObjectType(object)
        if mt == "EntityProxy" and object.IsCharacter ~= nil then
            return object
        elseif userdataType == "esv::CharacterComponent" or userdataType == "ecl::CharacterComponent" then
            return object.Character.MyHandle
        elseif userdataType == "esv::Character" or userdataType == "ecl::Character" then
            return object.MyHandle
        end
    elseif objectType == "string" or objectType == "number" then
        local entity = Ext.Entity.Get(object)
        if entity ~= nil and self:IsCharacter(entity) then
            return entity
        end
    end
end

---@param object any
---@return EsvCharacter|nil
function Helpers.Object:GetCharacterObject(object)
    local entity = self:GetCharacter(object)
    if entity ~= nil and self.IsServer then
        return entity.ServerCharacter
    end
end

---@param object any
---@return EntityHandle|nil
function Helpers.Object:GetItem(object)
    local objectType = type(object)
    if objectType == "userdata" then
        local userdataType = Ext.Types.GetObjectType(object)
        local mt = getmetatable(object)
        if mt == "EntityProxy" and object.IsItem ~= nil then
            return object
        elseif userdataType == "esv::ItemComponent" or userdataType == "ecl::ItemComponent" then
            return object.Item.MyHandle
        elseif userdataType == "esv::Item" or userdataType == "ecl::Item" then
            return object.MyHandle
        elseif userdataType == "CDivinityStats_Item" then
            return object.GameObject
        end
    elseif objectType == "string" or objectType == "number" then
        local entity = Ext.Entity.Get(object)
        if entity ~= nil and self:IsItem(object) then
            return entity
        end
    end
end

---@param object any
---@return EsvItem|nil
function Helpers.Object:GetItemObject(object)
    local entity = self:GetItem(object)
    if entity ~= nil and self.IsServer then
        return entity.ServerItem
    end
end

---@param object any
---@return EntityHandle|nil
function Helpers.Object:GetEntity(object)
    return self:GetCharacter(object) or self:GetItem(object)
end

---@param object any
---@return EsvCharacter|EsvItem|nil
function Helpers.Object:GetObject(object)
    return self:GetCharacterObject(object) or self:GetItemObject(object)
end

---@param object any
---@return Guid|nil
function Helpers.Object:GetGuid(object)
    local entity = self:GetEntity(object)
    if entity ~= nil then
        return Ext.Entity.HandleToUuid(entity)
    end
end

---@param object any
---@return Guid|nil
function Helpers.Object:GetTemplate(object)
    local object = self:GetObject(object)
    if object ~= nil and object.Template ~= nil then
        return object.Template.Id
    end
end

---@class LotsOfTags
---@field BackGroundTag table<string, Guid>
---@field ClassTag table<string, Guid>
---@field OriginTag table<string, Guid>
---@field ServerAnubisTag table<string, Guid>
---@field ServerBoostTag table<string, Guid>
---@field ServerDialogTag  table<string, Guid>
---@field ServerOsirisTag table<string, Guid>
---@field ServerRaceTag table<string, Guid>
---@field ServerTemplateTag table<string, Guid>
---@field Tag table<string, Guid>

---@param object any
---@return LotsOfTags
function Helpers.Object:GetTags(object)
    local tags = {}
    local esvObject = self:GetEntity(object)
    if esvObject ~= nil then
        for compName, v in pairs(esvObject:GetAllComponents()) do
            if compName:find("Tag") and v.Tags ~= nil then
                local compTags = {}
                for _, tag in pairs(v.Tags) do
                    local tagData = Ext.StaticData.Get(tag, "Tag")
                    if tagData ~= nil then
                        compTags[tagData.Name] = tag
                    end
                end
                tags[compName] = compTags
            end
        end
    end
    VCDump(tags)
    return tags
end

--Returns a distance-sorted array of characters nearby a position or object
---@param source EntityHandle|Guid|vec3
---@param radius? number
---@param ignoreHeight? boolean
---@return {Entity:EntityHandle, Guid:Guid, Distance:number, Name:string}[]
function Helpers.Object:GetNearbyCharacters(source, radius, ignoreHeight)
    local sourceEntity = self:GetEntity(source)
    local pos = sourceEntity ~= nil and sourceEntity.Transform.Transform.Translate or source
    radius = radius or self.DefaultNearbyRadius

    local nearbyEntities = {}
    for _, character in ipairs(Ext.Entity.GetAllEntitiesWithComponent("IsCharacter")) do
        local distance = Helpers.Grid:GetDistance(pos, character.Transform.Transform.Translate, ignoreHeight)
        if distance <= radius then
            table.insert(nearbyEntities, {
                Entity = character,
                Guid = character.Uuid.EntityUuid,
                Distance = distance,
                Name = Helpers.Loca:GetDisplayName(character)
            })
        end
    end

    table.sort(nearbyEntities, function(a, b) return a.Distance < b.Distance end)
    return nearbyEntities
end

--Returns a distance-sorted array of items nearby a position or object
---@param source EntityHandle|Guid|vec3
---@param radius? number
---@param ignoreHeight? boolean
---@param includeInSourceInventory? boolean
---@return {Entity: EntityHandle, Guid: Guid, Distance:number, Name:string, Template:Guid}[]
function Helpers.Object:GetNearbyItems(source, radius, ignoreHeight, includeInSourceInventory)
    local sourceEntity = self:GetEntity(source)
    local pos = sourceEntity ~= nil and sourceEntity.Transform.Transform.Translate or source
    radius = radius or self.DefaultNearbyRadius

    local nearbyEntities = {}
    if includeInSourceInventory or not sourceEntity then
        for _, item in ipairs(Ext.Entity.GetAllEntitiesWithComponent("IsItem")) do
            local distance = Helpers.Grid:GetDistance(pos, item.Transform.Transform.Translate, ignoreHeight)
            if distance <= radius then
                table.insert(nearbyEntities, {
                    Entity = item,
                    Guid = item.Uuid.EntityUuid,
                    Distance = distance,
                    Name = Helpers.Loca:GetDisplayName(item),
                    TemplateId = item.ServerItem.Template.Id
                })
            end
        end
    else
        for _, item in ipairs(Ext.Entity.GetAllEntitiesWithComponent("IsItem")) do
            local distance = Helpers.Grid:GetDistance(pos, item.Transform.Transform.Translate, ignoreHeight)
            if distance <= radius and not Helpers.Inventory:ItemIsInInventory(item, sourceEntity) then
                table.insert(nearbyEntities, {
                    Entity = item,
                    Guid = item.Uuid.EntityUuid,
                    Distance = distance,
                    Name = Helpers.Loca:GetDisplayName(item),
                    TemplateId = item.ServerItem.Template.Id
                })
            end
        end
    end

    table.sort(nearbyEntities, function(a, b) return a.Distance < b.Distance end)
    return nearbyEntities
end

---@param object any
---@return GameObjectTemplate|nil
function Helpers.Object:GetRootTemplate(object)
    local entityObj = self:GetObject(object)
    if entityObj ~= nil then
        if entityObj.Template ~= nil then
            return Ext.Template.GetRootTemplate(entityObj.Template.Id)
        end
    end
end

---@return EntityHandle|nil
function Helpers.Object:GetHostEntity()
    if Ext.IsServer() then
        return Ext.Entity.Get(Osi.GetHostCharacter())
    else
        for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("ClientControl")) do
            if entity.UserReservedFor.UserID == 1 then
                return entity
            end
        end
    end
end
