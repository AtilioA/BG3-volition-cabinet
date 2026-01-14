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
---@param ignoreHeight? boolean - Deprecated: This parameter is ignored when using the new spherical search
---@return {Entity:EntityHandle, Guid:Guid, Distance:number, Name:string}[]
function VCHelpers.Object:GetNearbyCharacters(source, radius, ignoreHeight)
    local sourceEntity = self:GetEntity(source)
    local pos = sourceEntity ~= nil and sourceEntity.Transform.Transform.Translate or source
    radius = radius or self.DefaultNearbyRadius

    local nearbyEntities = Ext.Entity.GetEntitiesAroundPosition(pos, radius, true, false)
    local results = {}

    for _, entity in ipairs(nearbyEntities) do
        if entity then
            local distance = VCHelpers.Grid:GetDistance(pos, entity.Transform.Transform.Translate, ignoreHeight)
            table.insert(results, {
                Entity = entity,
                Guid = entity.Uuid.EntityUuid,
                Distance = distance,
                Name = VCHelpers.Loca:GetDisplayName(entity)
            })
        end
    end

    table.sort(results, function(a, b) return a.Distance < b.Distance end)
    return results
end

--- Returns a sorted table of NPCs by distance from the host character, including detailed info.
---@param npcs EntityHandle[] A table of NPC handles.
---@return table NPCsInfo A table with details of involved NPCs: Entity, Guid, Distance, and Name, sorted by Distance.
function VCHelpers.Object:GetNPCsByDistance(npcs)
    local hostCharacter = Osi.GetHostCharacter()
    local NPCsInfo = {}

    for _, npcHandle in ipairs(npcs) do
        local npcEntity = Ext.Entity.Get(npcHandle)
        if npcEntity ~= nil then
            local distance = Osi.GetDistanceTo(npcHandle, hostCharacter)
            table.insert(NPCsInfo, {
                Entity = npcEntity,
                Guid = npcEntity.Uuid.EntityUuid,
                Distance = distance,
                Name = Ext.Loca.GetTranslatedString(npcEntity.DisplayName.NameKey.Handle.Handle)
            })
        end
    end

    -- Sort the NPCs by distance in descending order
    table.sort(NPCsInfo, function(a, b) return a.Distance > b.Distance end)

    return NPCsInfo
end

--Returns a distance-sorted array of items nearby a position or object
---@param source EntityHandle|Guid|vec3
---@param radius? number
---@param ignoreHeight? boolean - Deprecated: This parameter is ignored when using the new spherical search
---@param includeInSourceInventory? boolean
---@return {Entity: EntityHandle, Guid: Guid, Distance:number, Name:string, Template:Guid}[]
function VCHelpers.Object:GetNearbyItems(source, radius, ignoreHeight, includeInSourceInventory)
    local sourceEntity = self:GetEntity(source)
    local pos = sourceEntity ~= nil and sourceEntity.Transform.Transform.Translate or source
    radius = radius or self.DefaultNearbyRadius

    local nearbyEntities = Ext.Entity.GetEntitiesAroundPosition(pos, radius, false, true)
    local results = {}

    for _, entity in ipairs(nearbyEntities) do
        if entity then
            if includeInSourceInventory or not VCHelpers.Inventory:ItemIsInInventory(entity, sourceEntity) then
                local distance = VCHelpers.Grid:GetDistance(pos, entity.Transform.Transform.Translate, ignoreHeight)
                table.insert(results, {
                    Entity = entity,
                    Guid = entity.Uuid.EntityUuid,
                    Distance = distance,
                    Name = VCHelpers.Loca:GetDisplayName(entity),
                    TemplateId = entity.ServerItem.Template.Id
                })
            end
        end
    end

    table.sort(results, function(a, b) return a.Distance < b.Distance end)
    return results
end

--Returns a distance-sorted array of items nearby a position or object
---@param source EntityHandle|Guid|vec3
---@param radius? number
---@param ignoreHeight? boolean - Deprecated
---@param includeInSourceInventory? boolean
---@return {Entity: EntityHandle, Guid: Guid, Distance:number, Name:string, Template:Guid}[]
function VCHelpers.Object:GetNearbyContainers(source, radius, ignoreHeight, includeInSourceInventory)
    return self:GetNearbyItems(source, radius, ignoreHeight, includeInSourceInventory)
end

-- Main function to get both nearby characters and items
function VCHelpers.Object:GetNearbyCharactersAndItems(source, radius, ignoreHeight, includeInSourceInventory)
    local sourceEntity = self:GetEntity(source)
    local pos = sourceEntity ~= nil and sourceEntity.Transform.Transform.Translate or source
    radius = radius or self.DefaultNearbyRadius

    local nearbyEntities = Ext.Entity.GetEntitiesAroundPosition(pos, radius, true, true)
    local results = {}

    for _, entity in ipairs(nearbyEntities) do
        if entity then
            local isItem = entity.IsItem
            -- For characters, includeInSourceInventory is irrelevant
            -- For items, check if we should include it
            if not isItem or (includeInSourceInventory or not VCHelpers.Inventory:ItemIsInInventory(entity, sourceEntity)) then
                local distance = VCHelpers.Grid:GetDistance(pos, entity.Transform.Transform.Translate, ignoreHeight)
                table.insert(results, {
                    Entity = entity,
                    Guid = entity.Uuid.EntityUuid,
                    Distance = distance,
                    Name = VCHelpers.Loca:GetDisplayName(entity),
                    TemplateId = isItem and entity.ServerItem.Template.Id or nil
                })
            end
        end
    end

    -- Sort the combined list by distance
    table.sort(results, function(a, b) return a.Distance < b.Distance end)

    return results
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

--- DEPRECATED: Move this to format
---@deprecated Use VCHelpers.Format:LocalTemplate instead
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

--- Ping an object and play an effect on it
---@param object GUIDSTRING The UUID of the object
---@return nil
function VCHelpers.Object:PingObject(object)
    local objectPositionX, objectPositionY, objectPositionZ = Osi.GetPosition(object)
    if objectPositionX and objectPositionY and objectPositionZ then
        Osi.RequestPing(objectPositionX, objectPositionY, objectPositionZ, object, Osi.GetHostCharacter())
    end
end
