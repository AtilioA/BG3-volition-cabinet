---@class HelperLoca: Helper
Helpers.Loca = _Class:Create("HelperLoca", Helper)

---@param object any
---@return string|nil
function Helpers.Loca:GetDisplayName(object)
    local name
    local entity = Helpers.Object:GetEntity(object)
    if entity ~= nil then
        if entity.DisplayName ~= nil then
            name = Ext.Loca.GetTranslatedString(entity.DisplayName.NameKey.Handle.Handle)
            if name == nil then
                name = entity.DisplayName.Name
                if (name == "" or name == nil) and self.IsServer then
                    name = Ext.Loca.GetTranslatedString(Ext.Template.GetTemplate(entity.OriginalTemplate.OriginalTemplate).DisplayName.Handle.Handle)
                end
            end
        end
    end
    return name
end

---@param object any
---@return string|nil
function Helpers.Loca:GetDisplayNameHandle(object)
    local name
    local entity = Helpers.Object:GetEntity(object)
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
function Helpers.Loca:GetTitleName(object)
    local name
    local entity = Helpers.Object:GetEntity(object)
    if entity ~= nil then
        if entity.DisplayName ~= nil then
            name = Ext.Loca.GetTranslatedString(entity.DisplayName.UnknownKey.Handle.Handle)
            if name == "" or name == nil and self.IsServer then
                name = Ext.Loca.GetTranslatedString(Ext.Template.GetTemplate(entity.OriginalTemplate.OriginalTemplate).Title.Handle.Handle)
            end
        end
    end
    return name
end

---@param object any
---@return string|nil
function Helpers.Loca:GetTitleNameHandle(object)
    local name
    local entity = Helpers.Object:GetEntity(object)
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
