---@class HelperObject: Helper
---@field DefaultNearbyRadius 5
---@field ActionResources table<string, Guid>
VCHelpers.Object = _Class:Create("HelperObject", Helper, {
    DefaultNearbyRadius = 5,
})

---@param object any
---@return boolean
function VCHelpers.Object:IsCharacter(object)
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
function VCHelpers.Object:IsItem(object)
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
function VCHelpers.Object:GetCharacter(object)
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
function VCHelpers.Object:GetCharacterObject(object)
    local entity = self:GetCharacter(object)
    if entity ~= nil and self.IsServer then
        return entity.ServerCharacter
    end
end

---@param object any
---@return EntityHandle|nil
function VCHelpers.Object:GetItem(object)
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
function VCHelpers.Object:GetItemObject(object)
    local entity = self:GetItem(object)
    if entity ~= nil and self.IsServer then
        return entity.ServerItem
    end
end

---@param object any
---@return EntityHandle|nil
function VCHelpers.Object:GetEntity(object)
    return self:GetCharacter(object) or self:GetItem(object)
end

---@param object any
---@return EsvCharacter|EsvItem|nil
function VCHelpers.Object:GetObject(object)
    return self:GetCharacterObject(object) or self:GetItemObject(object)
end

---@param object any
---@return Guid|nil
function VCHelpers.Object:GetGuid(object)
    local entity = self:GetEntity(object)
    if entity ~= nil then
        return Ext.Entity.HandleToUuid(entity)
    end
end

---@param object any
---@return Guid|nil
function VCHelpers.Object:GetTemplate(object)
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
function VCHelpers.Object:GetTags(object)
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

    VCDump(2, tags)

    return tags
end

--Returns a distance-sorted array of characters nearby a position or object
---@param source EntityHandle|Guid|vec3
---@param radius? number
---@param ignoreHeight? boolean
---@return {Entity:EntityHandle, Guid:Guid, Distance:number, Name:string}[]
function VCHelpers.Object:GetNearbyCharacters(source, radius, ignoreHeight)
    local sourceEntity = self:GetEntity(source)
    local pos = sourceEntity ~= nil and sourceEntity.Transform.Transform.Translate or source
    radius = radius or self.DefaultNearbyRadius

    local nearbyEntities = {}
    for _, character in ipairs(Ext.Entity.GetAllEntitiesWithComponent("IsCharacter")) do
        if character.Transform and character.Transform.Transform then
            local distance = VCHelpers.Grid:GetDistance(pos, character.Transform.Transform.Translate, ignoreHeight)
            if distance <= radius then
                table.insert(nearbyEntities, {
                    Entity = character,
                    Guid = character.Uuid.EntityUuid,
                    Distance = distance,
                    Name = VCHelpers.Loca:GetDisplayName(character)
                })
            end
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
function VCHelpers.Object:GetNearbyItems(source, radius, ignoreHeight, includeInSourceInventory)
    local sourceEntity = self:GetEntity(source)
    local pos = sourceEntity ~= nil and sourceEntity.Transform.Transform.Translate or source
    radius = radius or self.DefaultNearbyRadius

    local nearbyEntities = {}
    if includeInSourceInventory or not sourceEntity then
        for _, item in ipairs(Ext.Entity.GetAllEntitiesWithComponent("IsItem")) do
            local distance = VCHelpers.Grid:GetDistance(pos, item.Transform.Transform.Translate, ignoreHeight)
            if distance <= radius then
                table.insert(nearbyEntities, {
                    Entity = item,
                    Guid = item.Uuid.EntityUuid,
                    Distance = distance,
                    Name = VCHelpers.Loca:GetDisplayName(item),
                    TemplateId = item.ServerItem.Template.Id
                })
            end
        end
    else
        for _, item in ipairs(Ext.Entity.GetAllEntitiesWithComponent("IsItem")) do
            local distance = VCHelpers.Grid:GetDistance(pos, item.Transform.Transform.Translate, ignoreHeight)
            if distance <= radius and not VCHelpers.Inventory:ItemIsInInventory(item, sourceEntity) then
                table.insert(nearbyEntities, {
                    Entity = item,
                    Guid = item.Uuid.EntityUuid,
                    Distance = distance,
                    Name = VCHelpers.Loca:GetDisplayName(item),
                    TemplateId = item.ServerItem.Template.Id
                })
            end
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
function VCHelpers.Object:GetNearbyContainers(source, radius, ignoreHeight, includeInSourceInventory)
    local sourceEntity = VCHelpers.Object:GetEntity(source)
    local pos = sourceEntity ~= nil and sourceEntity.Transform.Transform.Translate or source
    radius = radius or self.DefaultNearbyRadius

    local nearbyEntities = {}
    if includeInSourceInventory or not sourceEntity then
        for _, item in ipairs(Ext.Entity.GetAllEntitiesWithComponent("IsItem")) do
            if item.Transform and item.Transform.Transform then
                local distance = VCHelpers.Grid:GetDistance(pos, item.Transform.Transform.Translate, ignoreHeight)
                if distance <= radius then
                    table.insert(nearbyEntities, {
                        Entity = item,
                        Guid = item.Uuid.EntityUuid,
                        Distance = distance,
                        Name = VCHelpers.Loca:GetDisplayName(item),
                        TemplateId = item.ServerItem.Template.Id
                    })
                end
            end
        end
    else
        for _, item in ipairs(Ext.Entity.GetAllEntitiesWithComponent("IsItem")) do
            local distance = VCHelpers.Grid:GetDistance(pos, item.Transform.Transform.Translate, ignoreHeight)
            if distance <= radius and not VCHelpers.Inventory:ItemIsInInventory(item, sourceEntity) then
                table.insert(nearbyEntities, {
                    Entity = item,
                    Guid = item.Uuid.EntityUuid,
                    Distance = distance,
                    Name = VCHelpers.Loca:GetDisplayName(item),
                    TemplateId = item.ServerItem.Template.Id
                })
            end
        end
    end

    table.sort(nearbyEntities, function(a, b) return a.Distance < b.Distance end)
    return nearbyEntities
end

-- Main function to get both nearby characters and items
function VCHelpers.Object:GetNearbyCharactersAndItems(source, radius, ignoreHeight, includeInSourceInventory)
    local characters = self:GetNearbyCharacters(source, radius, ignoreHeight)
    local items = self:GetNearbyContainers(source, radius, ignoreHeight, includeInSourceInventory)

    -- Combine characters and items into a single table
    local allNearbyEntities = {}
    for _, entity in ipairs(characters) do
        table.insert(allNearbyEntities, entity)
    end
    for _, entity in ipairs(items) do
        table.insert(allNearbyEntities, entity)
    end

    -- Sort the combined list by distance
    table.sort(allNearbyEntities, function(a, b) return a.Distance < b.Distance end)

    return allNearbyEntities
end

---@param object any
---@return GameObjectTemplate|nil
function VCHelpers.Object:GetRootTemplate(object)
    local entityObj = self:GetObject(object)
    if entityObj ~= nil then
        if entityObj.Template ~= nil then
            return Ext.Template.GetRootTemplate(entityObj.Template.Id)
        end
    end
end

---@param object EntityHandle
function VCHelpers.Object:GetItemUUID(object)
    return object.TemplateName .. '_' .. object.Guid
end

---@return EntityHandle|nil
function VCHelpers.Object:GetHostEntity()
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

---@param object Guid
function VCHelpers.Object:DumpObjectEntity(object, fileName)
    local objectEntity = Ext.Entity.Get(object)
    local fullFileName = 'object-entity-' ..
        VCHelpers.Loca:GetDisplayName(object) .. '-' .. fileName .. '-' .. Ext.Utils.MonotonicTime() .. '.json'
    Ext.IO.SaveFile(fullFileName, Ext.DumpExport(objectEntity:GetAllComponents()))
    VCDebug(0, "Dumped object entity (" .. VCHelpers.Loca:GetDisplayName(object) .. ") to " .. fullFileName)
end

---@param object Guid
function VCHelpers.Object:IsObjectInWorld(object)
    return Osi.IsInInventory(object) == 0
end
