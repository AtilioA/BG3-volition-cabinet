---@class VCEntityGameObjectVisualParams:VCEventParams
---@field Entity EntityHandle
---@field Visual GameObjectVisualComponent
---@field Flags integer
VCParams.EntityGameObjectVisual = VCEventParamsBase:Create("VCEntityGameObjectVisualParams")

---@class VCEventEntityGameObjectVisual: VCEntityEventBase
---@field Subscribe fun(self:VCEventEntityGameObjectVisual, callback:fun(e:VCEntityGameObjectVisualParams))
Events.Entity.GameObjectVisual = VCEntityEventBase:CreateEvent("VCEventEntityGameObjectVisual",
    { Component = "GameObjectVisual" })

---@param entity EntityHandle
---@param entityComponent string
---@param flags integer
---@return VCEntityGameObjectVisualParams
function Events.Entity.GameObjectVisual:CreateParams(entity, entityComponent, flags)
    return VCParams.EntityGameObjectVisual:New {
        Entity = entity,
        Visual = entity[entityComponent],
        Flags = flags
    }
end
