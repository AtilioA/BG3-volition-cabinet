---@class HelperStatus: Helper
Helpers.Status = _Class:Create("HelperStatus", Helper)

---@param entity any
---@param statusId string
---@param onlyFirstInstance? boolean
function Helpers.Status:RemoveStatus(entity, statusId, onlyFirstInstance)
    local entityObj = Helpers.Object:GetObject(entity)
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
function Helpers.Status:RemoveStatusWithOwner(target, status, statusCause)
    local entityObj = Helpers.Object:GetObject(target)
    if entityObj ~= nil then
        local causeGuid = Helpers.Format:Guid(statusCause)
        for _, statusObj in pairs (entityObj.StatusManager.Statuses) do
            if statusObj.StatusId == status and statusObj.CauseGUID == causeGuid then
                statusObj.RequestDelete = true
            end
        end
    end
end

---@param target Guid
---@param statusCause Guid
function Helpers.Status:RemoveAllStatusesWithOwner(target, statusCause)
    local entityObj = Helpers.Object:GetObject(target)
    if entityObj ~= nil then
        local causeGuid = Helpers.Format:Guid(statusCause)
        for _, statusObj in pairs (entityObj.StatusManager.Statuses) do
            if statusObj.CauseGUID == causeGuid then
                statusObj.RequestDelete = true
            end
        end
    end
end

---@param entity any
---@param statusId string
---@return EsvStatus|nil
function Helpers.Status:GetStatus(entity, statusId)
    local esvObj = Helpers.Object:GetObject(entity)
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
function Helpers.Status:GetStatuses(object)
    local esvObj = Helpers.Object:GetObject(object)
    if esvObj ~= nil then
        return esvObj.StatusManager.Statuses
    end
end

---@param entity any
---@param stackId string
---@return EsvStatus|nil
function Helpers.Status:GetStatusStackId(entity, stackId)
    local esvObj = Helpers.Object:GetObject(entity)
    if esvObj ~= nil then
        for _, esvStatus in pairs(esvObj.StatusManager.Statuses) do
            if esvStatus.StackId == stackId then
                return esvStatus
            end
        end
    end
end