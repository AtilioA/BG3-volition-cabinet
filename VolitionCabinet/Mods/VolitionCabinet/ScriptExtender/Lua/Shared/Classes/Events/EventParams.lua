---@class VCParams: MetaClass
VCParams = _Class:Create("VCParams")

---@class VCEventParams: MetaClass
---@field private ShouldStopPropagation boolean
---@field private ShouldUnsubscribe boolean
VCEventParamsBase = _Class:Create("VCEventParams", nil, {
    ShouldStopPropagation = false,
    ShouldUnsubscribe = false
})

---Creates a new class with a given name
---@private
---@generic T
---@param class `T` Name of new class
---@param initial? table Initializing table for the class
---@return T
function VCEventParamsBase:Create(class, initial)
    initial = initial or {}
    initial.ShouldStopPropagation = false
    initial.ShouldUnsubscribe = false
    return _Class:Create(class, self, initial)
end

--Stops the event from propagating to subsequent callbacks. If the event is based on an engine event, this will stop the engine event from propagating as well.
function VCEventParamsBase:StopPropagation()
    self.ShouldStopPropagation = true
end

--Flags the callback currently being executed to be unsubscribed from the event the params are being passed through.
function VCEventParamsBase:Unsubscribe()
    self.ShouldUnsubscribe = true
end
