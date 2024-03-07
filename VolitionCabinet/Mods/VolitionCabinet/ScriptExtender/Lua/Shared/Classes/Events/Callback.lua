---@class VCEventCallback: MetaClass
---@field Callback function
---@field ExtraParams VCEventExtraParams
---@field HandlerID number
---@field Event VCEvent
---@field Stop boolean
VCEventCallback = _Class:Create("VCEventCallback")

function VCEventCallback:Unsubscribe()
    self.Event:Unsubscribe(self.HandlerID)
end
