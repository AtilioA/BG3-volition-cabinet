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
        Character = Helpers.Object:GetCharacter(character),
        CharacterGuid = Helpers.Format:Guid(character),
        Template = Helpers.Format:Guid(template),
        Item = Helpers.Object:GetItem(item),
        ItemGuid = Helpers.Format:Guid(item),
    }
end
