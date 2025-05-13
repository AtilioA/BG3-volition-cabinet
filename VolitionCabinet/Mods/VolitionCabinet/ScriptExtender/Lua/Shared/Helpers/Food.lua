--[[
--- This file contains helper functions related to detecting food items in the game.
--]]

---@class HelperFood: Helper
VCHelpers.Food = _Class:Create("HelperFood", Helper)

--- Check if an object is a food item.
---@param object GUIDSTRING
---@return boolean
function VCHelpers.Food:IsFood(object)
    if VCHelpers.Object:IsItem(object) then
        return Osi.ItemGetSupplyValue(object) > 0
    end
end

--- Check if an object is a beverage item.
---@param object GUIDSTRING
---@return boolean
function VCHelpers.Food:IsConsumableFood(object)
    return self:IsFood(object) and Osi.IsConsumable(object) == 1
end

function VCHelpers.Food:IsAlcoholicItem(object)
    if not object then return false end
    if not self:IsConsumableFood(object) then return false end
    local itemEntity = Ext.Entity.Get(object)
    if not itemEntity then return false end
    if not itemEntity.UseAction then return false end
    if not itemEntity.UseAction.UseActions then return false end
    if not itemEntity.UseAction.UseActions[1] then return false end
    if not itemEntity.UseAction.UseActions[1]   .StatsId then return false end
    return itemEntity.UseAction.UseActions[1].StatsId == "DRINK_ALCOHOL"
end

--- Gets all food items in a character's inventory.
---@param character GUIDSTRING character to check.
---@param shallow boolean If true, recursively checks inside bags and containers.
---@return table | nil - table of food items in the character's inventory, or nil if none found.
function VCHelpers.Food:GetFoodInInventory(character, shallow)
    local inventory = VCHelpers.Inventory:GetInventory(character, false, shallow)
    local matchedItems = {}

    for _, item in ipairs(inventory) do
        local itemObject = item.TemplateName .. item.Guid
        if VCHelpers.Food:IsFood(itemObject) then
            table.insert(matchedItems, itemObject)
        end
    end

    if #matchedItems > 0 then
        return matchedItems
    else
        return nil
    end
end
