---@class HelperTemplate: Helper
VCHelpers.Template = _Class:Create("HelperTemplate", Helper)

--- Check if a string/potential UUID has a template.
---@param str string The string to check.
---@return boolean
function VCHelpers.Template:HasTemplate(str)
    return Ext.Template.GetTemplate(str) ~= nil
end
