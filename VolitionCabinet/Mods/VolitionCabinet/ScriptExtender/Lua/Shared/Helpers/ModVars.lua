---@class HelperModVars: Helper
Helpers.ModVars = _Class:Create("HelperModVars", Helper)
Helpers.ModVars.DefaultProperties = {
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

---@param module? Guid
function Helpers.ModVars:Get(module)
    return Ext.Vars.GetModVariables(module or ModuleUUID)
end

---@param module? Guid
function Helpers.ModVars:Sync(module)
    Ext.Vars.SyncModVariables(module or ModuleUUID)
end

---@param key any
---@param module? Guid
function Helpers.ModVars:Dirty(key, module)
    Ext.Vars.DirtyModVariables(module or ModuleUUID, key)
end

---@param key string
---@param module? Guid
---@param initial? any Value to initialize variable as
---@param properties? table
function Helpers.ModVars:Register(key, module, initial, properties)
    local mod = module or ModuleUUID
    properties = properties or {}

    for k,v in pairs(self.DefaultProperties) do
        if properties[k] == nil then
            properties[k] = v
        end
    end

    if Ext.Mod.IsModLoaded(mod) then
        Ext.Vars.RegisterModVariable(mod, key, properties)
        if initial ~= nil then
            Events.Custom.VarsLoaded:Subscribe(function()
                if self.IsServer and properties.WriteableOnServer or self.IsClient and properties.WriteableOnClient then
                    local vars = self:Get(mod)
                    if vars and vars[key] == nil then
                        self:Get(mod)[key] = initial
                        self:Dirty(key, mod)
                    end
                end
            end, {Priority = 1000})
        end
    end
end