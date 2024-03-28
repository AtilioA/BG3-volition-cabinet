--[[
    This Helper file is for functions that are related to the camp, such as camp chest functionality.
-- ]]

---@class HelperCamp: Helper
VCHelpers.Camp = _Class:Create("HelperCamp", Helper)

VCHelpers.Camp.CampChestsToPlayerIDMapping = {
  ["CONT_PlayerCampChest_A"] = 65537, -- Player 1
  ["CONT_PlayerCampChest_B"] = 65538, -- Player 2
  ["CONT_PlayerCampChest_C"] = 65539, -- Player 3
  ["CONT_PlayerCampChest_D"] = 65540, -- Player 4
}

--- Gets the player ID of the camp chest.
---@param chestName string The UUID of the camp chest.
---@return integer|nil
function VCHelpers.Camp:GetPlayerIDFromCampChestName(chestName)
  return VCHelpers.Camp.CampChestsToPlayerIDMapping[chestName]
end

--- Gets the camp chest UUID from the player ID.
--- Iterates over the mapping, but it is and will always be a small table, so there's no need to optimize it.
---@param playerID integer The player ID.
---@return string|nil
function VCHelpers.Camp:GetCampChestNameFromPlayerID(playerID)
  for chestName, id in pairs(VCHelpers.Camp.CampChestsToPlayerIDMapping) do
    if id == playerID then
      return chestName
    end
  end
end

--- Gets the local UUID of the camp chest template for Player 1.
---@return Guid|nil
function VCHelpers.Camp:GetChestTemplateUUID()
  local result = Osi.DB_Camp_UserCampChest:Get(nil, nil)
  local chestName = result and result[1] and result[1][2] or nil

  -- I don't know if I can just return 'and tostring(result[1][2])', so I'm doing it in two more steps.
  if chestName then
    return chestName
  else
    return nil
  end
end

function VCHelpers.Camp:GetAllCampChestsUUIDs()
  local campChestUUIDs = {}

  local campChests = Osi.DB_Camp_UserCampChest:Get(nil, nil)
  if campChests then
    for _, chestInfo in ipairs(campChests) do
      -- _D(chestInfo)
      local playerID = chestInfo[1]
      local chestUUID = chestInfo[2]
      if playerID and chestUUID then
        campChestUUIDs[tostring(playerID)] = chestUUID
      end
    end
  end

  return campChestUUIDs
end
