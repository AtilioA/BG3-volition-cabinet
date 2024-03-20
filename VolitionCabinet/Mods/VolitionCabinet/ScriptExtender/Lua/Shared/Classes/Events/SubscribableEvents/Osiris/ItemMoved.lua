---@class VCItemMovedParams:VCEventParams
---@field ItemGuid Guid
---@field Item EntityHandle
---@field Template string
VCParams.ItemMoved = VCEventParamsBase:Create("VCItemMovedParams")

---@class VCEventItemMoved: VCOsirisEventBase
---@field Subscribe fun(self:VCEventItemMoved, callback:fun(e:VCItemMovedParams))
Events.Osiris.ItemMoved = VCOsirisEventBase:CreateEvent("VCEventItemMoved", { OsirisEvent = "Moved", OsirisArity = 1 })

---@param item Guid
---@param character Guid
---@return VCItemMovedParams
function Events.Osiris.ItemMoved:CreateParams(item, character)
    local params = VCParams.ItemMoved:New {
        Item = VCHelpers.Object:GetItem(item),
        ItemGuid = VCHelpers.Format:Guid(item),
        Template = VCHelpers.Object:GetTemplate(item)
    }
    return params
end
