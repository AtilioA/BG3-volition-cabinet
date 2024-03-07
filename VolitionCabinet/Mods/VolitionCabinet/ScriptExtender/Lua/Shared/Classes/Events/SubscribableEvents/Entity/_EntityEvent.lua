---@class VCEntityEventBase:VCEvent
---@field private Component string
VCEntityEventBase = VCEvent:Create("VCEntityEventBase")

---@private
---@generic T
---@param class `T`
---@param entityInfo {Component:string}
---@return T
function VCEntityEventBase:CreateEvent(class, entityInfo)
    return VCEvent.Create(self, class, entityInfo)
end

---@param entity EntityHandle
---@param entityComponent string
---@param flags integer
---@return VCEventParams
function VCEntityEventBase:CreateParams(entity, entityComponent, flags)
    VCDebug("Empty Param creation function for %s", _Class:GetClassName(self))
end

---@param e VCEventParams
function VCEntityEventBase:Throw(e, entity)
    self:ResetPropagation()
    local unsubIDs = {}
    for _, callback in ipairs(self.Callbacks) do
        if callback.ExtraParams.Entity == nil or callback.ExtraParams.Entity == entity then
            callback.Callback(e)
            if e.ShouldUnsubscribe then
                table.insert(unsubIDs, callback.HandlerID)
                e.ShouldUnsubscribe = false
            end
            if e.ShouldStopPropagation then
                self.Stop = true
                break
            end
        end
    end
    for _, handlerID in pairs(unsubIDs) do
        self:Unsubscribe(handlerID)
    end
end

---@private
function VCEntityEventBase:RegisterEvent()
    ---@param entity EntityHandle
    ---@param component string
    ---@param flags integer
    Ext.Entity.Subscribe(self.Component, function(entity, component, flags)
        if self:HasCallback() then
            self:Throw(self:CreateParams(entity, component, flags), entity)
        end
    end)
end
