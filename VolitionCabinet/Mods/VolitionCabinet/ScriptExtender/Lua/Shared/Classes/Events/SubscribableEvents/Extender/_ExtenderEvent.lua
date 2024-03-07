---@class VCExtenderEventBase:VCEvent
---@field private ExtenderEvent SubscribableEvent
VCExtenderEventBase = VCEvent:Create("VCExtenderEventBase")

---@private
---@generic T
---@param class `T`
---@param extenderInfo {ExtenderEvent:SubscribableEvent}
---@return T
function VCExtenderEventBase:CreateEvent(class, extenderInfo)
    return VCEvent.Create(self, class, extenderInfo)
end

---@param e LuaEventBase
---@return VCEventParams
function VCExtenderEventBase:CreateParams(e)
    VCDebug("Empty Param creation function for %s", _Class:GetClassName(self))
end

---@private
function VCExtenderEventBase:RegisterEvent()
    self.ExtenderEvent:Subscribe(function(e)
        if self:HasCallback() then
            self:Throw(self:CreateParams(e))
            if self.Stop then
                e:StopPropagation()
            end
        end
    end)
end
