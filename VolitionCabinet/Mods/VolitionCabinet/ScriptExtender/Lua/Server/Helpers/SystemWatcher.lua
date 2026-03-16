---@class HelperSystem: Helper
VCHelpers.System = _Class:Create("HelperSystem", Helper, {})

--- Watches all properties of an Ext.System and logs changes to the console.
--- Changes to collection-type properties also dump the full value.
---@param system ExtSystemType
function VCHelpers.System:Watch(system)
    local previousValues = {}
    Ext.Entity.OnSystemUpdate(system, function()
        local sys = Ext.System[system]
        local props = Ext.Types.GetTypeInfo(Ext.Types.GetValueType(sys)).Members
        for prop in pairs(props) do
            local value = sys[prop]
            local valueType = Ext.Types.GetBaseValueType(value)
            local isCollection = valueType == "Set" or valueType == "Map" or valueType == "Array" or valueType == "table"
            local current = isCollection and #value or value
            if previousValues[prop] ~= current then
                Ext.Log.Print(string.format("%s.%s %s --> %s", system, prop, tostring(previousValues[prop]), tostring(current)))
                previousValues[prop] = current
                if isCollection and current ~= 0 then
                    Ext.Dump(value)
                end
            end
        end
    end)
end

--- Watches a single property of an Ext.System and logs changes to the console.
--- Changes to collection-type properties also dump the full value.
---@param system ExtSystemType
---@param property string
function VCHelpers.System:WatchProperty(system, property)
    local previousValue = nil
    Ext.Entity.OnSystemUpdate(system, function()
        local sys = Ext.System[system]
        local value = sys[property]
        local valueType = Ext.Types.GetBaseValueType(value)
        local isCollection = valueType == "Set" or valueType == "Map" or valueType == "Array" or valueType == "table"
        local current = isCollection and #value or value
        if previousValue ~= current then
            Ext.Log.Print(string.format("%s.%s %s --> %s", system, property, tostring(previousValue), tostring(current)))
            previousValue = current
            if isCollection and current ~= 0 then
                Ext.Dump(value)
            end
        end
    end)
end
