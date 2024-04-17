---@class HelperTemplate: Helper
VCHelpers.Template = _Class:Create("HelperTemplate", Helper)

--- Check if a string/potential UUID has a template.
---@param str string The string to check.
---@return boolean
function VCHelpers.Template:HasTemplate(str)
    return Ext.Template.GetTemplate(str) ~= nil
end

--- Delete ALL entities whose templateID match the given template UUID.
---@param templateUUID string The UUID of the template to delete.
---@return void
function VCHelpers.Template:DeleteAllMatchingTemplates(templateUUID)
    local entities = Ext.Entity.GetAllEntitiesWithComponent("ServerItem")
    for _, entity in pairs(entities) do
        if entity and entity.ServerItem and entity.ServerItem.Template and entity.ServerItem.Template.Id == templateUUID then
            VCWarn(0, "Deleting entity: " .. entity.ServerItem.Template.Name)
            Osi.RequestDelete(entity.Uuid.EntityUuid)
        end
    end
end

--- Get all vanilla templates by checking if the filename contains "Public/Gustav" or "Mods/Gustav". This may not be accurate, but seems to work.
function VCHelpers.Template:GetAllVanillaTemplates()
    local function isVanillaFilename(filename)
        local hasPublicGustav = string.find(filename, "Public/Gustav")
        local hasPublicGustavDev = string.find(filename, "Public/GustavDev")
        local hasPublicShared = string.find(filename, "Public/Shared")
        local hasPublicSharedDev = string.find(filename, "Public/SharedDev")

        local hasModsGustav = string.find(filename, "Mods/Gustav")
        local hasModsGustavDev = string.find(filename, "Mods/GustavDev")
        local hasModsShared = string.find(filename, "Mods/Shared")
        local hasModsSharedDev = string.find(filename, "Mods/SharedDev")
        local hasPublicHonour = string.find(filename, "Public/Honour")
        local hasModsHonour = string.find(filename, "Mods/Honour")

        return hasPublicGustav or hasPublicGustavDev or hasPublicShared or hasPublicSharedDev or hasModsGustav or
            hasModsGustavDev or hasModsShared or hasModsSharedDev or hasModsHonour or hasPublicHonour
    end

    local templates = Ext.Template.GetAllRootTemplates()

    local vanillaTemplates = {}
    for templateId, templateData in pairs(templates) do
        if isVanillaFilename(templateData.FileName) then
            table.insert(vanillaTemplates, templateId)
        else
            local template = Ext.Template.GetTemplate(templateId)
            _D(VCHelpers.Loca:GetTranslatedStringFromTemplateUUID(templateId))
            VCWarn(1, "Skipping template: " .. templateId .. " (probably not vanilla)")
        end
    end
    return vanillaTemplates
end
