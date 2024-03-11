---@class HelperTeleporting: Helper
Helpers.Teleporting = _Class:Create("HelperTeleporting", Helper)

--- Teleports a character and summons to the specified position.
---@param character string
---@param x number
---@param y number
---@param z number
function Helpers.Teleporting:TeleportToPosition(character, x, y, z)
  Osi.TeleportToPosition(character, x, y, z, "TeleportToPosition_" .. character, 0, 0, 1, 0, 1)
end

--- Teleports linked/grouped party members to the specified character's position.
---@param character string
function Helpers.Teleporting:TeleportLinkedPartyMembersToCharacter(character)
  local x, y, z = Osi.GetPosition(character)
  if x and y and z then
    local otherPartyMembers = Helpers.Character:GetCharactersLinkedWith(character)
    for i, partyMember in ipairs(otherPartyMembers) do
      Helpers.Teleporting:TeleportToPosition(partyMember, x, y, z)
    end
  else
    VCWarn("Helpers.Teleporting:TeleportPartyMembersToCharacter() - Character position not found.")
  end
end

function Helpers.Teleporting:TeleportLinkedMembersToCharacter(character)
  local x, y, z = Osi.GetPosition(character)
  if x and y and z then
    Helpers.Teleporting:TeleportToPosition(character, x, y, z)
  else
    VCWarn("Helpers.Teleporting:TeleportLinkedMembersToCharacter() - Character position not found.")
  end
end
