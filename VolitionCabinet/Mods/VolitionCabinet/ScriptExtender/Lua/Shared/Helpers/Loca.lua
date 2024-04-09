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
    local entity = VCHelpers.Object:GetEntity(object)
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
