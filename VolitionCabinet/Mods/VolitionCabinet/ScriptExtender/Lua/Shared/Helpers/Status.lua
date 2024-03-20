---@class HelperStatus: Helper
VCHelpers.Status = _Class:Create("HelperStatus", Helper)

---@param entity any
---@param statusId string
---@param onlyFirstInstance? boolean
function VCHelpers.Status:RemoveStatus(entity, statusId, onlyFirstInstance)
    local entityObj = VCHelpers.Object:GetObject(entity)
    if entityObj ~= nil then
        for _, status in ipairs(entityObj.StatusManager.Statuses) do
            if status.StatusId == statusId then
                status.RequestDelete = true
                if onlyFirstInstance then
                    break
                end
            end
        end
    end
end

---@param target Guid
---@param status string
---@param statusCause Guid
function VCHelpers.Status:RemoveStatusWithOwner(target, status, statusCause)
    local entityObj = VCHelpers.Object:GetObject(target)
    if entityObj ~= nil then
        local causeGuid = VCHelpers.Format:Guid(statusCause)
        for _, statusObj in pairs(entityObj.StatusManager.Statuses) do
            if statusObj.StatusId == status and statusObj.CauseGUID == causeGuid then
                statusObj.RequestDelete = true
            end
        end
    end
end

---@param target Guid
---@param statusCause Guid
function VCHelpers.Status:RemoveAllStatusesWithOwner(target, statusCause)
    local entityObj = VCHelpers.Object:GetObject(target)
    if entityObj ~= nil then
        local causeGuid = VCHelpers.Format:Guid(statusCause)
        for _, statusObj in pairs(entityObj.StatusManager.Statuses) do
            if statusObj.CauseGUID == causeGuid then
                statusObj.RequestDelete = true
            end
        end
    end
end

---@param entity any
---@param statusId string
---@return EsvStatus|nil
function VCHelpers.Status:GetStatus(entity, statusId)
    local esvObj = VCHelpers.Object:GetObject(entity)
    if esvObj ~= nil then
        for _, esvStatus in pairs(esvObj.StatusManager.Statuses) do
            if esvStatus.StatusId == statusId then
                return esvStatus
            end
        end
    end
end

---@param object any
---@return EsvStatus[]|nil
function VCHelpers.Status:GetStatuses(object)
    local esvObj = VCHelpers.Object:GetObject(object)
    if esvObj ~= nil then
        return esvObj.StatusManager.Statuses
    end
end

---@param entity any
---@param stackId string
---@return EsvStatus|nil
function VCHelpers.Status:GetStatusStackId(entity, stackId)
    local esvObj = VCHelpers.Object:GetObject(entity)
    if esvObj ~= nil then
        for _, esvStatus in pairs(esvObj.StatusManager.Statuses) do
            if esvStatus.StackId == stackId then
                return esvStatus
            end
        end
    end
end
