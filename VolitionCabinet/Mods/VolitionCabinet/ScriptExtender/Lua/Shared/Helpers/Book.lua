--[[
--- This file contains helper functions related to detecting/retrieving books in the game.
--]]

---@class HelperBook: Helper
VCHelpers.Book = _Class:Create("HelperBook", Helper)

--- Checks if an object is a Book.
---@param object GUIDSTRING The object to check.
---@return boolean - true if the object is a Book, false otherwise.
function VCHelpers.Book:IsBook(object)
  return Osi.GetBookID(object) ~= nil
end

--- Gets all Book items in a character's inventory.
---@param character any character to check.
---@param shallow boolean If true, recursively checks inside bags and containers.
---@return table | nil - table of Book items in the character's inventory, or nil if none found.
function VCHelpers.Book:GetBooksInInventory(character, shallow)
  local inventory = VCHelpers.Inventory:GetInventory(character, false, shallow)
  local matchedItems = {}

  for _, item in ipairs(inventory) do
    local itemObject = VCHelpers.Format:LocalTemplate(item)
    if self:IsBook(itemObject) then
      table.insert(matchedItems, itemObject)
    end
  end

  if #matchedItems > 0 then
    return matchedItems
  else
    return nil
  end
end
