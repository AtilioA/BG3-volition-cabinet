--[[
--- This file contains helper functions related to managing wares in the game.
--- DontAddToHotbar is strangely used to mark items as wares in the game. There has been no indication of any side effects of using this flag.
--]]

---@class HelperWare: Helper
VCHelpers.Ware = _Class:Create("HelperWare", Helper)

function VCHelpers.Ware:IsWare(object)
  if type(object) == "string" then
    local objectEntity = Ext.Entity.Get(object)
    if objectEntity ~= nil then
      return objectEntity.ServerItem and objectEntity.ServerItem.DontAddToHotbar == true
    end
  elseif type(object) == "userdata" then
    return object.ServerItem and object.ServerItem.DontAddToHotbar == true
  end

  return false
end

function VCHelpers.Ware:MarkAsWare(item)
  if not VCHelpers.Inventory:IsProbablyQuestItem(item) then
    if type(item) == "string" then
      -- VCPrint(2, "Marking " .. item .. " as ware")
      local itemEntity = Ext.Entity.Get(item)
      if itemEntity and itemEntity.ServerItem then
        itemEntity.ServerItem.DontAddToHotbar = true
      end
    elseif type(item) == "userdata" then
      -- VCPrint(2, "Marking item entity as ware")
      if item.ServerItem then
        item.ServerItem.DontAddToHotbar = true
      end
    end
  else
    -- VCPrint(2, "Not marking " .. item .. " as ware because it is a quest item")
  end
end
