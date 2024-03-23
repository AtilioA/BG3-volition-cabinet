---@class VCOsirisEventBase:VCEvent
---@field private OsirisEvent string
---@field private OsirisArity integer
VCOsirisEventBase = VCEvent:Create("VCOsirisEventBase")

---@private
---@generic T
---@param class `T`
---@param OsirisInfo {OsirisEvent:string, OsirisArity:integer}
---@return T
function VCOsirisEventBase:CreateEvent(class, OsirisInfo)
    return VCEvent.Create(self, class, OsirisInfo)
end

---@vararg string|integer
---@return VCEventParams
function VCOsirisEventBase:CreateParams(...)
    VCDebug(1, "Empty Param creation function for %s", _Class:GetClassName(self))
end

---@private
function VCOsirisEventBase:RegisterEvent()
    if Ext.IsServer() then
        Ext.Osiris.RegisterListener(self.OsirisEvent, self.OsirisArity, "before", function(...)
            if self:HasCallback() then
                self:Throw(self:CreateParams(...))
            end
        end)
    end
end
