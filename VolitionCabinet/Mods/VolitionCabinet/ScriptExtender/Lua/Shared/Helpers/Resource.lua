---@class HelperResource: Helper
---@field ActionResources table<string, Guid>
Helpers.Resource = _Class:Create("HelperResource", Helper, {
    ActionResources = {}
})

Ext.Events.SessionLoaded:Subscribe(function()
    for _, resourceGuid in pairs(Ext.StaticData.GetAll("ActionResource")) do
        local resource = Ext.StaticData.Get(resourceGuid, "ActionResource")
        Helpers.Resource.ActionResources[resource.Name] = resourceGuid
    end
end)


---@param object any
---@param resource "ActionPoint"|"BonusActionPoint"|"ReactionActionPoint"|"FocusSoulSpellCharge"|Guid|string Will accept resource guids or names
---@param amount "Max"|number
---@param subResourceId? integer Used for spell slot levels, etc.
---@param addTo? boolean Add to the current resource amount instead of overwriting
function Helpers.Resource:SetActionResource(object, resource, amount, subResourceId, addTo)
    local entity = Helpers.Object:GetEntity(object)
    if entity ~= nil then
        local res = self.ActionResources[resource] or resource
        local entityRes = entity.ActionResources.Resources[res]
        if entityRes ~= nil then
            subResourceId = subResourceId or 0
            for _, subRes in pairs(entityRes) do
                if subRes.ResourceId == subResourceId then
                    local finalAmount = amount == "Max" and subRes.MaxAmount or amount
                    if addTo then
                        subRes.Amount = Ext.Math.Clamp(subRes.Amount + finalAmount, 0, subRes.MaxAmount)
                    else
                        subRes.Amount = Ext.Math.Clamp(finalAmount, 0, subRes.MaxAmount)
                    end

                    entity:Replicate("ActionResources")
                    break
                end
            end
        end
    end
end

---@param object any
---@param resource "ActionPoint"|"BonusActionPoint"|"ReactionActionPoint"|"FocusSoulSpellCharge"|Guid|string Will accept resource guids or names
---@param subResourceId? integer Used for spell slot levels, etc.
---@return integer
function Helpers.Resource:GetActionResource(object, resource, subResourceId)
    local entity = Helpers.Object:GetEntity(object)
    if entity ~= nil then
        local res = self.ActionResources[resource] or resource
        local entityRes = entity.ActionResources.Resources[res]
        if entityRes ~= nil then
            subResourceId = subResourceId or 0
            for _, subRes in pairs(entityRes) do
                if subRes.ResourceId == subResourceId then
                    return subRes.Amount
                end
            end
        end
    end
    return 0
end
