---@class VCUsedItemParams:VCEventParams
---@field Character EntityHandle
---@field CharacterGuid Guid
---@field Template Guid
---@field Item EntityHandle
---@field ItemGuid Guid
VCParams.UsedItem = VCEventParamsBase:New()

---@class VCEventUsedItem: VCOsirisEventBase
---@field Subscribe fun(self:VCEventUsedItem, callback:fun(e:VCUsedItemParams))
Events.Osiris.UsedItem = VCOsirisEventBase:CreateEvent("VCEventUsedItem",
    { OsirisEvent = "TemplateUseStarted", OsirisArity = 3 })

---@param character Guid
---@param template Guid
---@param item Guid
---@return VCUsedItemParams
function Events.Osiris.UsedItem:CreateParams(character, template, item)
    return VCParams.UsedItem:New {
        Character = VCHelpers.Object:GetCharacter(character),
        CharacterGuid = VCHelpers.Format:Guid(character),
        Template = VCHelpers.Format:Guid(template),
        Item = VCHelpers.Object:GetItem(item),
        ItemGuid = VCHelpers.Format:Guid(item),
    }
end
