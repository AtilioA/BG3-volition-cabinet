---@class HelperTeleporting: Helper
VCHelpers.Teleporting = _Class:Create("HelperTeleporting", Helper)

--- Teleports a character and summons to the specified position.
--- It is just a wrapper for Osi.TeleportToPosition teleporting only summons + snapping to ground.
---@param character string
---@param x number
---@param y number
---@param z number
function VCHelpers.Teleporting:TeleportToPosition(character, x, y, z)
  Osi.TeleportToPosition(character, x, y, z, "VCTeleportToPosition_" .. character, 0, 0, 1, 0, 1)
end

--- Teleports linked/grouped party members to the specified character's position.
--- This is better than teleporting the character to itself with teleportLinkedCharacters set to true because it will not interrupt the character's current action.
---@param character string
function VCHelpers.Teleporting:TeleportLinkedPartyMembersToCharacter(character)
  local x, y, z = Osi.GetPosition(character)
  if x and y and z then
    local otherPartyMembers = VCHelpers.Character:GetCharactersLinkedWith(character)
    for i, partyMember in ipairs(otherPartyMembers) do
      VCHelpers.Teleporting:TeleportToPosition(partyMember, x, y, z)
    end
  else
    VCWarn(0, "VCHelpers.Teleporting:TeleportPartyMembersToCharacter() - Character position not found.")
  end
end
