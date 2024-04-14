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
