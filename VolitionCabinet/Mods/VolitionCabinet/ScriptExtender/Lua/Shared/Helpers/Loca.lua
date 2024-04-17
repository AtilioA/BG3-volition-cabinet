---@class HelperLoca: Helper
VCHelpers.Loca = _Class:Create("HelperLoca", Helper)

---@param object GUIDSTRING
---@return string|nil
function VCHelpers.Loca:GetTranslatedStringFromTemplateUUID(object)
    local template = Ext.Template.GetTemplate(object)
    if template and template.DisplayName and template.DisplayName.Handle then
        return Ext.Loca.GetTranslatedString(template.DisplayName.Handle.Handle)
    end
    return nil
end

---@param object any
---@return string|nil
function VCHelpers.Loca:GetDisplayName(object)
    local name

    local entity = object
    if type(object) == 'string' then
        entity = VCHelpers.Object:GetEntity(object)
    end

    if entity ~= nil then
        if entity.DisplayName ~= nil then
            name = Ext.Loca.GetTranslatedString(entity.DisplayName.NameKey.Handle.Handle)
            if name == nil then
                name = entity.DisplayName.Name
                if (name == "" or name == nil) and self.IsServer then
                    name = Ext.Loca.GetTranslatedString(Ext.Template.GetTemplate(entity.OriginalTemplate
                        .OriginalTemplate).DisplayName.Handle.Handle)
                end
            end
        end
    end
    return name
end

---@param object any
---@return string|nil
function VCHelpers.Loca:GetDisplayNameHandle(object)
    local name
    local entity = VCHelpers.Object:GetEntity(object)
    if entity ~= nil then
        if entity.DisplayName ~= nil then
            name = entity.DisplayName.NameKey.Handle.Handle
            if (name == "" or name == nil or name:find("^ResStr_")) and self.IsServer then
                name = Ext.Template.GetTemplate(entity.OriginalTemplate.OriginalTemplate).DisplayName.Handle.Handle
            end
        end
    end
    return name
end

---@param object any
---@return string|nil
function VCHelpers.Loca:GetTitleName(object)
    local name
    local entity = VCHelpers.Object:GetEntity(object)
    if entity ~= nil then
        if entity.DisplayName ~= nil then
            name = Ext.Loca.GetTranslatedString(entity.DisplayName.UnknownKey.Handle.Handle)
            if name == "" or name == nil and self.IsServer then
                name = Ext.Loca.GetTranslatedString(Ext.Template.GetTemplate(entity.OriginalTemplate.OriginalTemplate)
                    .Title.Handle.Handle)
            end
        end
    end
    return name
end

---@param object any
---@return string|nil
function VCHelpers.Loca:GetTitleNameHandle(object)
    local name
    local entity = VCHelpers.Object:GetEntity(object)
    if entity ~= nil then
        if entity.DisplayName ~= nil then
            name = entity.DisplayName.UnknownKey.Handle.Handle
            if (name == "" or name == nil or name:find("^ResStr_")) and self.IsServer then
                name = Ext.Template.GetTemplate(entity.OriginalTemplate.OriginalTemplate).Title.Handle.Handle
            end
        end
    end
    return name
end

-- TODO: make it more generic (replace any number of placeholders)
--- Update a localized message with dynamic content
---@param handle string The handle of the localized message to update
---@param dynamicContent string The dynamic content to replace the placeholder with
function VCHelpers.Loca:UpdateLocalizedMessage(handle, dynamicContent)
    -- Retrieve the current translated string for the given handle
    local currentMessage = Ext.Loca.GetTranslatedString(handle)

    -- Replace the placeholder [1] with the dynamic content. The g flag is for global replacement.
    local updatedMessage = string.gsub(currentMessage, "%[1%]", dynamicContent)

    -- Update the translated string with the new content, altering it during runtime. Any GetTranslatedString calls will now return this updated message.
    Ext.Loca.UpdateTranslatedString(handle, updatedMessage)
end
