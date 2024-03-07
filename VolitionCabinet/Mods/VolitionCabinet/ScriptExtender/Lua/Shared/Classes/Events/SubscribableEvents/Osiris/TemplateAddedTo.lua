---@class VCTemplateAddedToParams:VCEventParams
---@field AddType string
---@field Entity EntityHandle
---@field EntityGuid Guid
---@field Holder EntityHandle
---@field HolderGuid Guid
---@field RealHolder EntityHandle
---@field Template Guid
VCParams.TemplateAddedTo = VCEventParamsBase:Create("VCTemplateAddedToParams")

---@class VCEventTemplateAddedTo: VCOsirisEventBase
---@field Subscribe fun(self:VCEventTemplateAddedTo, callback:fun(e:VCTemplateAddedToParams))
Events.Osiris.TemplateAddedTo = VCOsirisEventBase:CreateEvent("VCEventTemplateAddedTo",
    { OsirisEvent = "TemplateAddedTo", OsirisArity = 4 })

---@param template Guid
---@param object Guid
---@param holder Guid
---@param addType string
---@return VCTemplateAddedToParams
function Events.Osiris.TemplateAddedTo:CreateParams(template, object, holder, addType)
    local params = VCParams.TemplateAddedTo:New {
        Template = Helpers.Format:Guid(template),
        EntityGuid = Helpers.Format:Guid(object),
        Entity = Helpers.Object:GetEntity(object),
        RealHolder = Helpers.Inventory:GetHolder(object),
        HolderGuid = Helpers.Format:Guid(holder),
        Holder = Helpers.Object:GetEntity(holder),
        AddType = addType,
    }
    return params
end
