---@class HelperTypes: Helper
VCHelpers.Types = _Class:Create("HelperTypes", Helper, {})

--- Returns true if the given BG3SE typed object has the named property.
--- Avoids runtime crashes when accessing properties that don't exist on the stat/template type.
---@param obj any
---@param property string
---@return boolean
function VCHelpers.Types:HasProperty(obj, property)
    local valType = Ext.Types.GetValueType(obj)
    if valType == nil then return false end
    local valInfo = Ext.Types.GetTypeInfo(valType)
    if valInfo == nil then return false end
    return valInfo.Members[property] ~= nil
end

--- Safely reads a property from a BG3SE typed object.
--- Returns nil (no error) if the property does not exist on the object's type.
---@param obj any
---@param property string
---@return any
function VCHelpers.Types:SafeGet(obj, property)
    if self:HasProperty(obj, property) then
        return obj[property]
    end
    return nil
end
