--[[
--- This file contains helper functions related to managing/detecting lootable objects in the game.
--]]

---@class HelperLootable: Helper
VCHelpers.Lootable = _Class:Create("HelperLootable", Helper)

---Checks if the given object is a corpse.
---@param object integer
---@return boolean
function VCHelpers.Lootable:IsCorpse(object)
  return VCHelpers.Inventory:GetInventory(object, true, true) ~= nil and Osi.IsDead(object) == 1
end

---Checks if the given object is knocked out.
---@param object integer
---@return boolean
function VCHelpers.Lootable:IsKnockedOut(object)
  local objectEntityComponents = Ext.Entity.Get(object)
  return objectEntityComponents and objectEntityComponents.CanBeLooted and objectEntityComponents.CanBeLooted.Flags ~= 0
end

---Checks if the given object is a buried chest.
---@param object integer
---@return boolean
function VCHelpers.Lootable:IsBuriedChest(object)
  local objectEntity = Ext.Entity.Get(object)
  if objectEntity and objectEntity.ServerItem and objectEntity.ServerItem.Template then
    local TemplateName = objectEntity.ServerItem.Template.Name
    return string.find(TemplateName, "BuriedChest") ~= nil
  end
  return false
end

---Checks if the given object is lootable.
---@param object integer
---@return boolean
function VCHelpers.Lootable:IsLootable(object)
  return ((Osi.IsContainer(object) == 1) or VCHelpers.Lootable:IsCorpse(object) or VCHelpers.Lootable:IsKnockedOut(object)) and
      not VCHelpers.Lootable:IsBuriedChest(object)
end
