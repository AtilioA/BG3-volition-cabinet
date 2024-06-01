---@class HelperTemplate: Helper
VCHelpers.Template = _Class:Create("HelperTemplate", Helper)

VCHelpers.Template.TemplateNameToUUID = nil

--- Check if a string/potential UUID has a template.
---@param str string The string to check.
---@return boolean
function VCHelpers.Template:HasTemplate(str)
    return Ext.Template.GetTemplate(str) ~= nil
end

-- VCHelpers.Template.TemplateNameToUUID = VCHelpers.Template:GetTemplateNameToTemplateData()

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
            VCWarn(1, "Skipping template: " .. templateId .. " (probably not vanilla)")
        end
    end
    return vanillaTemplates
end

function VCHelpers.Template:GetAllModdedTemplates()
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

    local moddedTemplates = {}
    for templateId, templateData in pairs(templates) do
        if not isVanillaFilename(templateData.FileName) then
            table.insert(moddedTemplates, templateId)
        else
            local template = Ext.Template.GetTemplate(templateId)
            VCWarn(1, "Skipping template: " .. templateId .. " (probably vanilla)")
        end
    end
    return moddedTemplates
end

---@class TemplateData
---@field Id string
---@field Stats any
---@field Name string

--- Generate a table of template Name keys to UUID/template Id values.
---@return table<string, TemplateData>
function VCHelpers.Template:CreateTemplateNameToTemplateIDTable()
    local templates = Ext.Template.GetAllRootTemplates()
    local templateNameToUUID = {}
    for templateId, templateData in pairs(templates) do
        if templateData.TemplateType == 'item' then
            templateNameToUUID[templateData.Name] = {
                Id = templateId,
                Stats = templateData.Stats,
                Name = Ext.Loca.GetTranslatedString(templateData.DisplayName.Handle.Handle)
            }
        end
    end
    -- local fullFileName = 'template-name-to-uuid-' .. Ext.Utils.MonotonicTime() .. '.json'
    -- Ext.IO.SaveFile(fullFileName, Ext.DumpExport(templateNameToUUID))
    -- VCDebug(0, "Dumped template name to UUID table to " .. fullFileName)

    return templateNameToUUID
end

table.lazyLoad(VCHelpers.Template, "TemplateNameToUUID", function()
    _D("Lazy loading template name to UUID table")
    return VCHelpers.Template:CreateTemplateNameToTemplateIDTable()
end)
