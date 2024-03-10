---@class HelperCharacter: Helper
Helpers.Character = _Class:Create("HelperCharacter", Helper)

-- Function to return all other party members
---@param characterGuid string
---@return string[] otherPartyMembers A table of guids of other party members
function Helpers.Character:GetOtherPartyMembers(characterGuid)
  local otherPartyMembers = {}
  local companions = Osi.DB_Players:Get(nil)
  for i, companion in ipairs(companions) do
    local companionGuid = Helpers.Format:Guid(tostring(companion[1]))
    if companionGuid ~= characterGuid then
      table.insert(otherPartyMembers, companionGuid)
    end
  end

  return otherPartyMembers
end

