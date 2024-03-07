---@class HelperUserVars: Helper
Helpers.UserVars = _Class:Create("HelperUserVars", Helper)
Helpers.UserVars.DefaultProperties = {
    Server = true,
    Client = true,
    Persistent = true,
    SyncToServer = true,
    SyncToClient = true,
    WriteableOnServer = true,
    WriteableOnClient = true,
    SyncOnWrite = false,
    SyncOnTick = true,
    DontCache = false,
}

---@param entity any
---@param key string
---@return any|nil
function Helpers.UserVars:Get(entity, key)
    local entityObj = Helpers.Object:GetEntity(entity)
    if entityObj ~= nil then
        if key ~= nil then
            return entityObj.Vars[key]
        end
    end
end

---@param entity any
---@param key string
---@param value table|string|number|nil
function Helpers.UserVars:Set(entity, key, value)
    local entityObj = Helpers.Object:GetEntity(entity)
    if entityObj ~= nil then
        if key ~= nil then
            if type(value) == "userdata" then
                local serialized = Ext.Types.Serialize(value)
                if serialized ~= nil then
                    entityObj.Vars[key] = serialized
                end
            else
                entityObj.Vars[key] = value
            end
        end
    end
end

function Helpers.UserVars:Sync()
    Ext.Vars.SyncUserVariables()
end

---@param entity? any
---@param key? any
function Helpers.UserVars:Dirty(entity, key)
    local entityObj = Helpers.Object:GetEntity(entity)
    if entityObj then
        Ext.Vars.DirtyUserVariables(entity.Uuid.EntityUuid, key)
    end
end

---@param key string
---@param properties? table
function Helpers.UserVars:Register(key, properties)
    properties = properties or {}

    for k,v in pairs(self.DefaultProperties) do
        if properties[k] == nil then
            properties[k] = v
        end
    end

    Ext.Vars.RegisterUserVariable(key, properties)
end