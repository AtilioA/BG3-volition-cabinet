--[[
--- This file contains helper functions related to detecting food items in the game.
--]]

---@class HelperFood: Helper
Helpers.Food = _Class:Create("HelperFood", Helper)

function Helpers.Food:IsFood(object)
  if Helpers.Object:IsItem(object) then
    return Osi.ItemGetSupplyValue(object) > 0
  end
end

function Helpers.Food:IsBeverage(object)
  return self.IsFood(object) and Osi.IsConsumable(object) == 1
end

--- Gets all food items in a character's inventory.
---@param character GUIDSTRING character to check.
---@param shallow boolean If true, recursively checks inside bags and containers.
---@return table | nil - table of food items in the character's inventory, or nil if none found.
function GetFoodInInventory(character, shallow)
  local inventory = Helpers.Inventory:GetInventory(character, false, shallow)
  local matchedItems = {}

  for _, item in ipairs(inventory) do
    local itemObject = item.TemplateName .. item.Guid
    if Helpers.Food:IsFood(itemObject) then
      table.insert(matchedItems, itemObject)
    end
  end

  if #matchedItems > 0 then
    return matchedItems
  else
    return nil
  end
end
