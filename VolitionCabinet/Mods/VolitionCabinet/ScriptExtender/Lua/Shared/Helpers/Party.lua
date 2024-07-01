--[[
--- This file contains helper functions related to managing the party in the game.
--]]

---@class HelperParty: Helper
VCHelpers.Party = _Class:Create("HelperParty", Helper)

-- Return the party members currently following the player
function VCHelpers.Party:GetPartyMembers()
  local teamMembers = {}

  local allPlayers = Osi.DB_Players:Get(nil)
  for _, player in ipairs(allPlayers) do
    if not string.match(player[1]:lower(), "%f[%A]dummy%f[%A]") then
      teamMembers[#teamMembers + 1] = VCHelpers.Format:Guid(player[1])
    end
  end

  return teamMembers
end

-- Return all party members, including the ones at camp
function VCHelpers.Party.GetAllPartyMembers()
  local teamMembers = {}

  local allPlayers = Osi.DB_PartOfTheTeam:Get(nil)
  for _, player in ipairs(allPlayers) do
    local isDummy = string.match(player[1]:lower(), "%f[%A]dummy%f[%A]")
    local isJergal = string.match(player[1]:lower(), "%f[%A]jergalavatar%f[%A]")
    if isDummy == nil and isJergal == nil then
      teamMembers[#teamMembers + 1] = VCHelpers.Format:Guid(player[1])
    end
  end

  return teamMembers
end


-- Function to return all other party members
---@param characterGuid Guid
---@return Guid[] otherPartyMembers A table of guids of other party members
function VCHelpers.Party:GetOtherPartyMembers(characterGuid)
    local otherPartyMembers = {}
    local companions = Osi.DB_Players:Get(nil)
    for i, companion in ipairs(companions) do
      local companionGuid = VCHelpers.Format:Guid(tostring(companion[1]))
      if companionGuid ~= characterGuid then
        table.insert(otherPartyMembers, companionGuid)
      end
    end

    return otherPartyMembers
  end
