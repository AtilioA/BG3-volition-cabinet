---@class HelperInventory: Helper
VCHelpers.Inventory = _Class:Create("HelperInventory", Helper)

--- Returns a name-sorted array of all items in an object's inventory
---@param object any
---@param primaryOnly? boolean
---@param shallow? boolean
---@return {Entity:EntityHandle, Guid:Guid, Name:string, TemplateId:string, TemplateName:string}[]
function VCHelpers.Inventory:GetInventory(object, primaryOnly, shallow)
    local items = {}
    local entity = VCHelpers.Object:GetEntity(object)
    if entity ~= nil then
        local inventory = entity.InventoryOwner
        if inventory ~= nil then
            local inventories = primaryOnly and 1 or #inventory.Inventories
            for i = 1, inventories do
                for _, itemObj in pairs(inventory.Inventories[i].InventoryContainer.Items) do
                    local item = itemObj.Item
                    local info = {
                        Entity = item,
                        Guid = item.Uuid.EntityUuid,
                        Name = Ext.Loca.GetTranslatedString(item.DisplayName.NameKey.Handle.Handle),
                        TemplateId = "",
                        TemplateName = ""
                    }

                    local esvObject = VCHelpers.Object:GetObject(item)
                    if esvObject ~= nil then
                        info.TemplateId = esvObject.Template.Id
                        info.TemplateName = esvObject.Template.Name
                    end

                    table.insert(items, info)

                    if not shallow and item.InventoryOwner ~= nil then
                        for _, itemInfo in ipairs(self:GetInventory(item)) do
                            table.insert(items, itemInfo)
                        end
                    end
                end
            end
        end
    end

    table.sort(items, function(a, b) return a.Name < b.Name end)
    return items
end

---@param object GUIDSTRING|EntityHandle
---@return EntityHandle|nil
function VCHelpers.Inventory:GetHolder(object)
    local entity = nil
    if type(object) == "string" then
        entity = VCHelpers.Object:GetEntity(object)
    else
        entity = object
    end

    if entity ~= nil and entity.InventoryMember ~= nil then
        return entity.InventoryMember.Inventory.InventoryIsOwned.Owner
    end

    return nil
end

---@param object any
---@return EntityHandle|nil
function VCHelpers.Inventory:GetOwner(object)
    local entity = VCHelpers.Object:GetEntity(object)
    if entity ~= nil and entity.OwneeCurrent ~= nil then
        return entity.OwneeCurrent.Ownee
    end
end

---@param item EntityHandle|Guid
---@param holder EntityHandle|Guid
---@return boolean
function VCHelpers.Inventory:ItemIsInInventory(item, holder)
    local itemEntity = VCHelpers.Object:GetEntity(item)
    local holderEntity = VCHelpers.Object:GetEntity(holder)
    if itemEntity ~= nil and holderEntity ~= nil then
        local parentInventory = itemEntity.InventoryMember and
            itemEntity.InventoryMember.Inventory.InventoryIsOwned.Owner
        while parentInventory do
            if parentInventory == holderEntity then
                return true
            else
                parentInventory = parentInventory.InventoryMember and
                    parentInventory.InventoryMember.Inventory.InventoryIsOwned.Owner
            end
        end
    end
    return false
end

---@param template Guid
---@param holder EntityHandle|Guid
---@return EntityHandle|nil
function VCHelpers.Inventory:GetItemTemplateInInventory(template, holder)
    local templateID = VCHelpers.Format:GetTemplateName(template)
    local holderEntity = VCHelpers.Object:GetEntity(holder)
    if holderEntity ~= nil then
        local inventory = holderEntity.InventoryOwner
        if inventory ~= nil then
            for _, container in pairs(inventory.Inventories) do
                for _, itemObj in pairs(container.InventoryContainer.Items) do
                    local esvItem = VCHelpers.Object:GetItemObject(itemObj.Item)
                    if esvItem ~= nil then
                        local itemTemplate = esvItem.Template
                        if itemTemplate.Name == templateID
                            or itemTemplate.TemplateName == templateID
                            or itemTemplate.Id == templateID then
                            return itemObj.Item
                        else
                            local containedItem = self:GetItemTemplateInInventory(template, itemObj.Item.Uuid.EntityUuid)
                            if containedItem ~= nil then
                                return containedItem
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

---@param template Guid
---@param holder any
---@param primaryOnly? boolean
---@param shallow? boolean
---@return EntityHandle[]
function VCHelpers.Inventory:GetAllItemsWithTemplateInInventory(template, holder, primaryOnly, shallow)
    local items = {}
    for _, item in pairs(self:GetInventory(holder, primaryOnly, shallow)) do
        if item.TemplateId == template then
            table.insert(items, item)
        end
    end
    return items
end

---@param template string
---@param holder EntityHandle|Guid
---@return boolean
function VCHelpers.Inventory:ItemTemplateIsInInventory(template, holder)
    local templateGuid = VCHelpers.Format:Guid(template)
    local holderEntity = VCHelpers.Object:GetEntity(holder)
    if holderEntity ~= nil then
        local inventory = holderEntity.InventoryOwner
        if inventory ~= nil then
            for _, container in pairs(inventory.Inventories) do
                for _, itemObj in pairs(container.InventoryContainer.Items) do
                    local object = VCHelpers.Object:GetItemObject(itemObj.Item)
                    if object ~= nil then
                        local itemTemplate = object.Template
                        if itemTemplate.Name == template
                            or itemTemplate.TemplateName == templateGuid
                            or itemTemplate.Id == templateGuid
                            or self:ItemTemplateIsInInventory(template, itemObj.Item.Uuid.EntityUuid) then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

---@param item any
---@return boolean
function VCHelpers.Inventory:IsMainStackEntity(item)
    local entity = VCHelpers.Object:GetItem(item)
    return entity ~= nil and entity.InventoryStack ~= nil
end

---@param item any
function VCHelpers.Inventory:DestroyEntireStack(item)
    local entity = VCHelpers.Object:GetItem(item)
    if entity ~= nil and entity.InventoryStackMember ~= nil then
        local mainEntity = entity.InventoryStackMember.Stack
        for _, stackEntity in pairs(mainEntity.InventoryStack.Arr_u64) do
            Osi.RequestDelete(stackEntity.Uuid.EntityUuid)
        end
    end
end

---@param object any
---@param slot StatsItemSlot|EQUIPMENTSLOTNAME|integer
---@return EntityHandle|nil
function VCHelpers.Inventory:GetEquippedItem(object, slot)
    local entity = VCHelpers.Object:GetCharacter(object)
    if entity ~= nil then
        local equippedItems = entity.InventoryOwner.Inventories[2]
        if equippedItems ~= nil then
            local equipmentSlot
            if type(slot) == "string" then
                if slot == "Melee Main Weapon" then
                    slot = "MeleeMainHand"
                elseif slot == "Melee Offhand Weapon" then
                    slot = "MeleeOffHand"
                elseif slot == "Ranged Main Weapon" then
                    slot = "RangedMainHand"
                elseif slot == "Ranged Offhand Weapon" then
                    slot = "RangedOffHand"
                end
                equipmentSlot = Ext.Enums.StatsItemSlot[slot].Value
            else
                equipmentSlot = slot
            end

            if equippedItems.InventoryContainer.Items[equipmentSlot] ~= nil then
                return equippedItems.InventoryContainer.Items[equipmentSlot].Item
            end
        end
    end
    return nil
end

---@param treasureTable string
---@param target? any
---@param level? integer
---@param finder? any
---@param generateInBag? boolean
function VCHelpers.Inventory:GenerateTreasureTable(treasureTable, target, level, finder, generateInBag)
    target = VCHelpers.Object:GetEntity(target or Osi.GetHostCharacter())
    local targetGuid = target.Uuid.EntityUuid
    if level == nil then
        if Osi.IsItem(targetGuid) == 1 then
            level = -1
        else
            level = Osi.GetLevel(targetGuid)
        end
    end

    if finder == nil then
        if Osi.IsItem(targetGuid) == 1 then
            finder = Osi.GetHostCharacter()
        else
            finder = targetGuid
        end
    end

    if generateInBag then
        local bag = Osi.CreateAt("3e6aac21-333b-4812-a554-376c2d157ba9", 0, 0, 0, 0, 0, "")
        Osi.GenerateTreasure(bag, treasureTable, level, finder)
        Osi.ToInventory(bag, targetGuid)
    else
        Osi.GenerateTreasure(targetGuid, treasureTable, level, finder)
    end
end

function VCHelpers.Inventory:IsItemInPartyInventory(item)
    local itemEntity = Ext.Entity.Get(item)
    -- For some reason InPartyInventory is not being set as one would expect 🤔
    return itemEntity.InventoryMember ~= nil or itemEntity.ServerItem.InPartyInventory == true
end

--- Check if item is (probably) quest related. Adapted from Fararagi (this was from the Auto Sell Loot mod though, not Mark Book as Read)
---@param item GUIDSTRING|ItemEntity
---@return boolean
function VCHelpers.Inventory:IsProbablyQuestItem(item)
    if type(item) == "string" then
        ---@cast item string
        return Osi.IsStoryItem(item) == 1 or VCHelpers.String:StringContains(Osi.GetStatString(item), "quest") or
            VCHelpers.String:StringContains(item, "quest")
    elseif type(item) == "userdata" then
        ---@cast item ItemEntity
        local uuid = item.Uuid.EntityUuid or VCHelpers.Format.NullUuid
        return Osi.IsStoryItem(uuid) == 1 or VCHelpers.String:StringContains(item.Data.StatsId, "quest") or
            VCHelpers.String:StringContains(item.ServerItem.Template.Name, "quest")
    else
        return false
    end
end

--- Get the inventory of the camp chest
---@param shallow? boolean
function VCHelpers.Inventory:GetCampChestInventory(shallow)
    local chestGUID = VCHelpers.Camp:GetChestTemplateUUID()
    if chestGUID then
        return VCHelpers.Inventory:GetInventory(chestGUID, true, shallow)
    else
        return {}
    end
end

---@param item Guid
---@return boolean
function VCHelpers.Inventory:IsItemInCampChest(item)
    local chestGUID = VCHelpers.Camp:GetChestTemplateUUID()
    if chestGUID then
        return VCHelpers.Inventory:GetItemTemplateInInventory(item, chestGUID) ~= nil
    else
        return false
    end
end
