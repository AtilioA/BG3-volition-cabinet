---@class VCEventExtraParams:MetaClass
---@field Priority number
---@field Entity EntityHandle
VCEventExtraParams = _Class:Create("VCEventExtraParams")

---@param o any
---@return VCEventExtraParams
function VCEventExtraParams:New(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.Priority = o.Priority or 100
    return o
end
