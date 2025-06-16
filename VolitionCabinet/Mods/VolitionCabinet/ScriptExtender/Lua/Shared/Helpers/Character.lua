---@class HelperCharacter: Helper
VCHelpers.Character = _Class:Create("HelperCharacter", Helper)

-- Detect if a character is sneaking
---@param character Guid The character to check
---@return boolean isSneaking true if the character is sneaking
function VCHelpers.Character:IsSneaking(character)
  local characterEntity = Ext.Entity.Get(character)
  if not characterEntity then return false end
  
  -- REVIEW: There's probably a better way to detect sneaking
  return characterEntity.SpellModificationContainer and characterEntity.SpellModificationContainer.Modifications and
      characterEntity.SpellModificationContainer.Modifications.Shout_Hide ~= nil
end

function VCHelpers.Character:GetDisjointedLinkedCharacterSets()
  local disjointSets = {}

  -- Get the Party entity of the host character
  local hostEntity = _C()
  if not hostEntity or not hostEntity.PartyMember or not hostEntity.PartyMember.Party then
    return disjointSets -- Return empty if no party info is found
  end

  local partyEntity = hostEntity.PartyMember.Party
  if not partyEntity.PartyView or not partyEntity.PartyView.Views then
    return disjointSets -- Return empty if no party view info is found
  end

  for _, view in ipairs(partyEntity.PartyView.Views) do
    local charactersSet = {}
    for _, characterEntity in ipairs(view.Characters) do
      table.insert(charactersSet, characterEntity.Uuid.EntityUuid)
    end
    if #charactersSet > 0 then
      table.insert(disjointSets, charactersSet)
    end
  end

  return disjointSets
end

-- Function to get other party members present in the same PartyView.Views other than the character passed as argument
---@param characterGuid Guid
---@return Guid[] otherPartyMembers A table of guids of other party members
function VCHelpers.Character:GetCharactersLinkedWith(characterGuid)
  local otherPartyMembers = {}
  local partyEntity = _C().PartyMember.Party
  if not partyEntity or not partyEntity.PartyView or not partyEntity.PartyView.Views then
    return otherPartyMembers -- Return empty if no party info is found
  end

  -- Find the View (link group) that includes the characterGuid
  local targetView = nil
  for _, view in ipairs(partyEntity.PartyView.Views) do
    for _, characterEntity in ipairs(view.Characters) do
      local currentGuid = characterEntity.Uuid.EntityUuid
      if currentGuid == characterGuid then
        targetView = view
        break
      end
    end
    if targetView then break end
  end

  -- If a target View is found, iterate over its Characters to find other party members, and add them to the otherPartyMembers table. These are the characters linked with the characterGuid
  if targetView then
    for _, characterEntity in ipairs(targetView.Characters) do
      local companionGuid = characterEntity.Uuid.EntityUuid
      if companionGuid ~= characterGuid then
        table.insert(otherPartyMembers, companionGuid)
      end
    end
  end

  return otherPartyMembers
end

-- Function to check if a character is in camp
-- Alternatively, use DB_PlayerInCamp(CHARACTER) or DB_InCamp(CHARACTER), but these return some bad tables
---@param characterGuid GUIDSTRING The character to check
function VCHelpers.Character:IsCharacterInCamp(characterGuid)
  local characterEntity = Ext.Entity.Get(characterGuid)
  if not characterEntity then return false end
  
  return characterEntity.CampPresence ~= nil
end

--- Function to get the ability score of a character
---@param characterGuid Guid The character to check
---@param ability string The ability to check
function VCHelpers.Character:GetAbilityScore(characterGuid, ability)
  local characterEntity = Ext.Entity.Get(characterGuid)
  if not characterEntity then return nil end
  if not characterEntity.Stats or not characterEntity.Stats.Abilities then return nil end

  local abilityIndex = nil
  for index, value in pairs(Ext.Enums.AbilityId) do
    if type(index) == "number" and value == ability then
      abilityIndex = index + 1
      break
    end
  end

  if not abilityIndex then return nil end

  local abilityScore = characterEntity.Stats.Abilities[abilityIndex]

  if not abilityScore then return nil end

  return abilityScore
end
