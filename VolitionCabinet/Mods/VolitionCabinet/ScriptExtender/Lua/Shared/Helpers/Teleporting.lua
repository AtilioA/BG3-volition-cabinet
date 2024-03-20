---@class HelperTeleporting: Helper
VCHelpers.Teleporting = _Class:Create("HelperTeleporting", Helper)

--- Teleports a character and summons to the specified position.
---@param character string
---@param x number
---@param y number
---@param z number
function VCHelpers.Teleporting:TeleportToPosition(character, x, y, z)
  Osi.TeleportToPosition(character, x, y, z, "TeleportToPosition_" .. character, 0, 0, 1, 0, 1)
end

--- Teleports linked/grouped party members to the specified character's position.
---@param character string
function VCHelpers.Teleporting:TeleportLinkedPartyMembersToCharacter(character)
  local x, y, z = Osi.GetPosition(character)
  if x and y and z then
    local otherPartyMembers = VCHelpers.Character:GetCharactersLinkedWith(character)
    for i, partyMember in ipairs(otherPartyMembers) do
      VCHelpers.Teleporting:TeleportToPosition(partyMember, x, y, z)
    end
  else
    VCWarn("VCHelpers.Teleporting:TeleportPartyMembersToCharacter() - Character position not found.")
  end
end

function VCHelpers.Teleporting:TeleportLinkedMembersToCharacter(character)
  local x, y, z = Osi.GetPosition(character)
  if x and y and z then
    VCHelpers.Teleporting:TeleportToPosition(character, x, y, z)
  else
    VCWarn("VCHelpers.Teleporting:TeleportLinkedMembersToCharacter() - Character position not found.")
  end
end
