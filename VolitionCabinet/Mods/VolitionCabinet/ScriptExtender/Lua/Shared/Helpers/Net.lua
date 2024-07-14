---@class HelperNet: Helper
VCHelpers.Net = _Class:Create("HelperNet", Helper)

-- Thanks to Aahz for this function
function VCHelpers.Net:PeerToUserID(u)
    -- all this for userid+1 usually smh
    return (u & 0xffff0000) | 0x0001
end

-- Returns the character that the user is controlling
function VCHelpers.Net:GetUserCharacterUUID(userId)
    for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("ClientControl")) do
        if entity.UserReservedFor.UserID == userId then
            return entity.Uuid.EntityUuid
        end
    end

    return nil
end

function VCHelpers.Net:IsUserHost(userId)
    if userId == 65537 then
        return true
    end

    local character = self:GetUserCharacter(userId)
    if Osi.GetHostCharacter() == character then
        return true
    end

    return false
end
