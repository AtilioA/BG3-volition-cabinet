---@class VCShortRestedParams:VCEventParams
---@field Character CHARACTER
VCParams.ShortRested = VCEventParamsBase:Create("VCShortRestedParams")

---@class VCEventShortRested: VCOsirisEventBase
---@field Subscribe fun(self:VCEventShortRested, callback:fun(character:CHARACTER))
Events.Osiris.ShortRested = VCOsirisEventBase:CreateEvent("VCEventShortRested",
  { OsirisEvent = "ShortRested", OsirisArity = 1 })

---@param character CHARACTER
---@return VCShortRestedParams
function Events.Osiris.ShortRested:CreateParams(character)
  local params = VCParams.ShortRested:New {
    CharacterGuid = Helpers.Format:Guid(character),
    Character = Ext.Entity.Get(character),
  }
  return params
end
