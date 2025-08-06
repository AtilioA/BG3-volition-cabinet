---@class HelperTeleporting: Helper
VCHelpers.Teleporting = _Class:Create("HelperTeleporting", Helper)

--- Checks if a character is currently in dialogue
---@param character string The character to check
---@return boolean isInDialogue True if the character is in dialogue, false otherwise
function VCHelpers.Teleporting:IsCharacterInDialogue(character)
    if not character then return false end
    
    local success, inDialogue = xpcall(function()
        local entity = Ext.Entity.Get(character)
        return entity and entity.ServerCharacter and entity.ServerCharacter.Flags.InDialog or false
    end, function(err)
        VCWarn(1, "Error checking if character is in dialogue: " .. tostring(err))
        return false
    end)
    
    return success and inDialogue or false
end

--- Teleports a character and summons to the specified position.
--- It is just a wrapper for Osi.TeleportToPosition teleporting only summons + snapping to ground.
---@param character string
---@param x number
---@param y number
---@param z number
---@param vfx GUIDSTRING | nil The VFX to play when teleporting the character.
function VCHelpers.Teleporting:TeleportToPosition(character, x, y, z, vfx)
    if not character or not x or not y or not z then
        VCWarn(0, "VCHelpers.Teleporting:TeleportToPosition() - Invalid parameters provided.")
        return
    end
    
    if self:IsCharacterInDialogue(character) then
        VCDebug(1, "Skipping teleport for character in dialogue: " .. tostring(character))
        return
    end

    if vfx then
        Osi.PlayEffect(character, vfx)
        Osi.ApplyStatus(character, vfx, 1, 0, character)
    end

    Osi.TeleportToPosition(character, x, y, z, "VCTeleportToPosition_" .. character, 0, 0, 1, 0, 1)
end

--- Teleports linked/grouped party members to the specified character's position.
--- This is better than teleporting the character to itself with teleportLinkedCharacters set to true since it will not interrupt the character's current action.
---@param character string
function VCHelpers.Teleporting:TeleportLinkedPartyMembersToCharacter(character)
    local otherPartyMembers = VCHelpers.Character:GetCharactersLinkedWith(character)
    if #otherPartyMembers > 0 then
        VCHelpers.Teleporting:TeleportCharactersToCharacter(character, otherPartyMembers)
    else
        VCWarn(0, "VCHelpers.Teleporting:TeleportLinkedPartyMembersToCharacter() - No linked party members found.")
    end
end

--- Teleports a table of characters to the specified character's position.
--- This is useful for moving a group of characters to a leader's position.
---@param targetCharacter string
---@param charactersToTeleport table
---@param vfx GUIDSTRING | nil The VFX to play when teleporting the characters.
function VCHelpers.Teleporting:TeleportCharactersToCharacter(targetCharacter, charactersToTeleport, vfx)
    if not targetCharacter or #charactersToTeleport == 0 then
        return
    end
    
    -- Skip if target character is in dialogue
    if self:IsCharacterInDialogue(targetCharacter) then
        VCDebug(1, "Skipping teleport to character in dialogue: " .. tostring(targetCharacter))
        return
    end

    local x, y, z = Osi.GetPosition(targetCharacter)
    if not x or not y or not z then
        VCWarn(0, "VCHelpers.Teleporting:TeleportCharactersToCharacter() - Target character position not found.")
        return
    end

    for _, character in ipairs(charactersToTeleport) do
        VCHelpers.Teleporting:TeleportToPosition(character, x, y, z, vfx)
    end
end
