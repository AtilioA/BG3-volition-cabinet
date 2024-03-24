--[[
--- This file contains helper functions related to managing the party in the game.
--]]

---@class HelperParty: Helper
VCHelpers.Party = _Class:Create("HelperParty", Helper)


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
