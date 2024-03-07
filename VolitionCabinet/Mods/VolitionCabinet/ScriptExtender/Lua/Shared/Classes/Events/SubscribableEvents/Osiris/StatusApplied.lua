---@class VCStatusAppliedParams:VCEventParams
---@field Attacker EntityHandle|nil
---@field AttackerGuid Guid|nil
---@field Target EntityHandle|nil
---@field TargetGuid Guid|nil
---@field StatusId string
---@field Status EsvStatus
---@field StoryActionID integer
---@field HasAttackerAndTarget boolean
VCParams.StatusApplied = VCEventParamsBase:New()

---@vararg string
---@return boolean
function VCParams.StatusApplied:IsStatus(...)
    for _, id in pairs({ ... }) do
        if id == self.StatusId then
            return true
        end
    end
    return false
end

---@class VCEventStatusApplied: VCOsirisEventBase
---@field Subscribe fun(self:VCEventStatusApplied, callback:fun(e:VCStatusAppliedParams))
Events.Osiris.StatusApplied = VCOsirisEventBase:CreateEvent("VCEventStatusApplied",
    { OsirisEvent = "StatusApplied", OsirisArity = 4 })

---@param target Guid
---@param statusId string
---@param attacker Guid
---@param storyActionID integer
---@return VCStatusAppliedParams
function Events.Osiris.StatusApplied:CreateParams(target, statusId, attacker, storyActionID)
    local params = VCParams.StatusApplied:New {
        Attacker = Helpers.Object:GetEntity(attacker),
        Target = Helpers.Object:GetEntity(target),
        StatusId = statusId,
        Status = Helpers.Status:GetStatus(target, statusId),
        StoryActionID = storyActionID,
    }

    if params.Attacker ~= nil then
        params.AttackerGuid = Helpers.Format:Guid(attacker)
    end

    if params.Target ~= nil then
        params.TargetGuid = Helpers.Format:Guid(target)
    end

    params.HasAttackerAndTarget = params.Attacker ~= nil and params.Target ~= nil

    return params
end
