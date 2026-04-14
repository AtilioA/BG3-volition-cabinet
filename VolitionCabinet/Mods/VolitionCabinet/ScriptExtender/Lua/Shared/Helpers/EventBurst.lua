---@class VCEventBurstBatch
---@field name string
---@field count integer
---@field participants Guid[]
---@field participantSet table<Guid, boolean>
---@field payloads table[]
---@field firstParticipant Guid|nil
---@field lastParticipant Guid|nil

---@class VCEventBurstInstance
---@field name string
---@field debounceMs integer
---@field onFlush fun(batch:VCEventBurstBatch)
---@field timerId integer|nil
---@field pendingCount integer
---@field pendingParticipants Guid[]
---@field pendingParticipantSet table<Guid, boolean>
---@field pendingPayloads table[]

local EventBurstInstance = {}
EventBurstInstance.__index = EventBurstInstance

---@param self VCEventBurstInstance
function EventBurstInstance:ResetPending()
    self.pendingCount = 0
    self.pendingParticipants = {}
    self.pendingParticipantSet = {}
    self.pendingPayloads = {}
end

---@param self VCEventBurstInstance
---@return VCEventBurstBatch
function EventBurstInstance:CreateBatch()
    local participants = VCHelpers.Table:CopyArray(self.pendingParticipants)

    return {
        name = self.name,
        count = self.pendingCount,
        participants = participants,
        participantSet = VCHelpers.Table:CopyShallow(self.pendingParticipantSet),
        payloads = VCHelpers.Table:CopyArray(self.pendingPayloads),
        firstParticipant = participants[1],
        lastParticipant = participants[#participants],
    }
end

---@param self VCEventBurstInstance
function EventBurstInstance:ScheduleFlush()
    if self.timerId then
        Ext.Timer.Cancel(self.timerId)
        self.timerId = nil
    end

    self.timerId = Ext.Timer.WaitFor(self.debounceMs, function()
        self.timerId = nil
        self:FlushNow()
    end)
end

---@param self VCEventBurstInstance
---@param participantGuid Guid|nil
---@param payload table|nil
function EventBurstInstance:Push(participantGuid, payload)
    local normalizedGuid = participantGuid and VCHelpers.Format:Guid(participantGuid) or nil
    if normalizedGuid and normalizedGuid ~= "" and not self.pendingParticipantSet[normalizedGuid] then
        self.pendingParticipantSet[normalizedGuid] = true
        self.pendingParticipants[#self.pendingParticipants + 1] = normalizedGuid
    end

    if payload ~= nil then
        self.pendingPayloads[#self.pendingPayloads + 1] = payload
    end

    self.pendingCount = self.pendingCount + 1
    self:ScheduleFlush()
end

---@param self VCEventBurstInstance
function EventBurstInstance:Cancel()
    if self.timerId then
        Ext.Timer.Cancel(self.timerId)
        self.timerId = nil
    end

    self:ResetPending()
end

---@param self VCEventBurstInstance
function EventBurstInstance:FlushNow()
    if self.timerId then
        Ext.Timer.Cancel(self.timerId)
        self.timerId = nil
    end

    if self.pendingCount == 0 then
        return
    end

    local batch = self:CreateBatch()
    self:ResetPending()
    self.onFlush(batch)
end

---@class HelperEventBurst: Helper
VCHelpers.EventBurst = _Class:Create("HelperEventBurst", Helper)

---@param config {name:string|nil,debounceMs:integer|nil,onFlush:fun(batch:VCEventBurstBatch)}
---@return VCEventBurstInstance
function VCHelpers.EventBurst:Create(config)
    return setmetatable({
        name = (config and config.name) or "EventBurst",
        debounceMs = (config and config.debounceMs) or 500,
        onFlush = (config and config.onFlush) or function(_) end,
        timerId = nil,
        pendingCount = 0,
        pendingParticipants = {},
        pendingParticipantSet = {},
        pendingPayloads = {},
    }, EventBurstInstance)
end
