---@class VCEntityHealthParams:VCEventParams
---@field Entity EntityHandle
---@field Health HealthComponent
---@field Flags integer
VCParams.EntityHealth = VCEventParamsBase:Create("VCEntityHealthParams")

---@class VCEventEntityHealth: VCEntityEventBase
---@field Subscribe fun(self:VCEventEntityHealth, callback:fun(e:VCEntityHealthParams))
Events.Entity.Health = VCEntityEventBase:CreateEvent("VCEventEntityHealth", { Component = "Health" })

---@param entity EntityHandle
---@param entityComponent string
---@param flags integer
---@return VCEntityHealthParams
function Events.Entity.Health:CreateParams(entity, entityComponent, flags)
    return VCParams.EntityHealth:New {
        Entity = entity,
        Health = entity[entityComponent],
        Flags = flags
    }
end
