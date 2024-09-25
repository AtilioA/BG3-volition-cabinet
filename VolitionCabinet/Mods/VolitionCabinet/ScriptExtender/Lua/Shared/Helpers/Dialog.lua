---@class HelperDialog: Helper
VCHelpers.Dialog = _Class:Create("HelperDialog", Helper)


-- Returns a table with all the NPCs involved in an automated dialog instance
---@param instanceID integer The ID of the dialog instance
---@return GUIDSTRING[] - involvedNPCs A table of guids of NPCs involved in the dialog
function VCHelpers.Dialog:GetInvolvedNPCs(instanceID)
    local involvedNPCs = {}

    local nInvolvedNPCs = Osi.DialogGetNumberOfInvolvedNPCs(instanceID)
    for i = 1, nInvolvedNPCs do
        local npcHandle = Osi.DialogGetInvolvedNPC(instanceID, i)
        if npcHandle ~= nil and Osi.IsCharacter(npcHandle) == 1 then
            table.insert(involvedNPCs, npcHandle)
        end
    end

    return involvedNPCs
end

-- Checks if the list of NPCs contains any of the player's party members
---@param involvedNPCs GUIDSTRING[] A table of guids of NPCs involved in the dialog
---@return boolean - True if any of the NPCs are part of the player's companions (includes ones at camp)
function VCHelpers.Dialog:CheckIfPartyInvolved(involvedNPCs)
    local partyMembers = VCHelpers.Party:GetAllPartyMembers()
    if not partyMembers then return false end

    return table.hasCommonElements(involvedNPCs, partyMembers)
end
