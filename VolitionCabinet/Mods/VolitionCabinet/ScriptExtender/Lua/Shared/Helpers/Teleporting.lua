---@class HelperTeleporting: Helper
Helpers.Teleporting = _Class:Create("HelperTeleporting", Helper)

-- TODO: create disjoint sets of linked characters in Helpers.Character
--- Teleports a character and linked characters to the specified position.
---@param character string
---@param x number
---@param y number
---@param z number
function Helpers.Teleporting:TeleportToPosition(character, x, y, z)
  Osi.TeleportToPosition(character, x, y, z, "TeleportToPosition_" .. character, 1, 0, 1, 0, 1)
end

--- Teleports the party members to the specified character's position.
---@param character string
function Helpers.Teleporting:TeleportPartyMembersToCharacter(character)
  local x, y, z = Osi.GetPosition(character)
  if x and y and z then
    local otherPartyMembers = Helpers.Character:GetOtherPartyMembers(character)
    for i, partyMember in ipairs(otherPartyMembers) do
      Helpers.Teleporting:TeleportToPosition(partyMember, x, y, z)
    end
  else
    VCWarn("Helpers.Teleporting:TeleportPartyMembersToCharacter() - Character position not found.")
  end
end
