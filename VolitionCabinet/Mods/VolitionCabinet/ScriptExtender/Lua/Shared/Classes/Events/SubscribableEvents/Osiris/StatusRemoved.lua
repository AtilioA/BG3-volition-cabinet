---@class VCStatusRemovedParams:VCEventParams
---@field Attacker EntityHandle
---@field AttackerGuid Guid
---@field Target EntityHandle
---@field TargetGuid Guid
---@field StatusId string
---@field StoryID integer
---@field HasAttackerAndTarget boolean
VCParams.StatusRemoved = VCEventParamsBase:Create("VCStatusRemovedParams")

---@class VCEventStatusRemoved: VCOsirisEventBase
---@field Subscribe fun(self:VCEventStatusRemoved, callback:fun(e:VCStatusRemovedParams))
Events.Osiris.StatusRemoved = VCOsirisEventBase:CreateEvent("VCEventStatusRemoved",
    { OsirisEvent = "StatusRemoved", OsirisArity = 4 })

---Accepts any amount of statusIds as params and returns if the current status matches a statusId and the status target still exists.
---@vararg string
---@return boolean
function VCParams.StatusRemoved:IsStatus(...)
    if self.Target ~= nil then
        for _, s in ipairs({ ... }) do
            if s == self.StatusId then
                return true
            end
        end
    end
    return false
end

---@param target Guid
---@param status string
---@param causee Guid
---@param storyActionID integer
---@return VCStatusRemovedParams
function Events.Osiris.StatusRemoved:CreateParams(target, status, causee, storyActionID)
    local params = VCParams.StatusRemoved:New {
        Target = Ext.Entity.Get(target),
        TargetGuid = Helpers.Format:Guid(target),
        Attacker = Ext.Entity.Get(causee),
        AttackerGuid = Helpers.Format:Guid(causee),
        StatusId = status,
        StoryID = storyActionID,
    }
    params.HasAttackerAndTarget = params.Target ~= nil and params.Attacker ~= nil
    return params
end
