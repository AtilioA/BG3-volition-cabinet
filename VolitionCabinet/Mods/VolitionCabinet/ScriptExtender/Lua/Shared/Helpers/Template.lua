---@class HelperTemplate: Helper
VCHelpers.Template = _Class:Create("HelperTemplate", Helper)

-- This table will get lazy loaded with table of template Name keys to UUID/template Id values.
VCHelpers.Template.TemplateNameToUUID = nil

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

--- Get all vanilla or modded templates based on the filename.
---@param isVanilla boolean If true, get vanilla templates; otherwise, get modded templates.
---@return table A list of template IDs.
function VCHelpers.Template:GetTemplatesByType(isVanilla)
    local function generateVanillaPatterns()
        local folderNames = { "Public", "Mods", "Shared", "SharedDev" }
        local modNames = { "GustavX", "Gustav", "GustavDev", "Shared", "SharedDev", "Honour", "HonourX", "MainUI",
        "ModBrowser" }
        local vanillaPatterns = {}

        for _, folder in ipairs(folderNames) do
            for _, mod in ipairs(modNames) do
                table.insert(vanillaPatterns, folder .. "/" .. mod)
            end
        end

        return vanillaPatterns
    end

    local function isVanillaFilename(filename)
        local vanillaPatterns = generateVanillaPatterns()

        for _, pattern in ipairs(vanillaPatterns) do
            if string.find(filename, pattern) then
                return true
            end
        end
        return false
    end

    local templates = Ext.Template.GetAllRootTemplates()
    local filteredTemplates = {}

    for templateId, templateData in pairs(templates) do
        local isVanillaFile = isVanillaFilename(templateData.FileName)
        if (isVanilla and isVanillaFile) or (not isVanilla and not isVanillaFile) then
            table.insert(filteredTemplates, templateId)
        else
            local template = Ext.Template.GetTemplate(templateId)
            VCWarn(1,
                "Skipping template: " .. templateId .. " (probably " .. (isVanilla and "not vanilla" or "vanilla") .. ")")
        end
    end
    return filteredTemplates
end

--- Get all vanilla templates.
---@return table A list of vanilla template IDs.
function VCHelpers.Template:GetAllVanillaTemplates()
    return self:GetTemplatesByType(true)
end

--- Get all modded templates.
---@return table A list of modded template IDs.
function VCHelpers.Template:GetAllModdedTemplates()
    return self:GetTemplatesByType(false)
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
    return VCHelpers.Template:CreateTemplateNameToTemplateIDTable()
end)
