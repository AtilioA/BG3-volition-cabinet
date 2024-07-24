---@class HelperDialog: Helper
VCHelpers.Dialog = _Class:Create("HelperDialog", Helper)

-- Returns a table with all the NPCs involved in an automated dialog instance
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

function VCHelpers.Dialog:CheckIfPartyInvolved(involvedNPCs)
    for _, npc in ipairs(involvedNPCs) do
        if Osi.IsInPartyWith(npc, Osi.GetHostCharacter()) == 1 then
            return true
        end
    end

    return false
end
