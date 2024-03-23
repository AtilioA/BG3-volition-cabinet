---@class VCCustomEventBase:VCEvent
VCCustomEventBase = VCEvent:Create("VCCustomEventBase")

---@private
---@generic T
---@param class `T`
---@return T
function VCCustomEventBase:CreateEvent(class)
    return VCEvent.Create(self, class)
end

---@param e LuaEventBase
---@return VCEventParams
function VCCustomEventBase:CreateParams(e)
    VCDebug(1, "Empty Param creation function for %s", _Class:GetClassName(self))
end

---@private
function VCCustomEventBase:RegisterEvent()
    VCDebug(1, "Empty event registration function for %s", _Class:GetClassName(self))
end
