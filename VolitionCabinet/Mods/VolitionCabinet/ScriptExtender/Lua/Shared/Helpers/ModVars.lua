---@class HelperModVars: Helper
VCHelpers.ModVars = _Class:Create("HelperModVars", Helper)
VCHelpers.ModVars.DefaultProperties = {
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
function VCHelpers.ModVars:Get(module)
    return Ext.Vars.GetModVariables(module or ModuleUUID)
end

---@param module? Guid
function VCHelpers.ModVars:Sync(module)
    local ModVars = Ext.Vars.GetModVariables(module or ModuleUUID)
    -- Redundant but worky :catyep:
    if ModVars then
        for varName, data in pairs(ModVars) do
            ModVars[varName] = ModVars[varName]
        end
        Ext.Vars.DirtyModVariables(module or ModuleUUID)
        Ext.Vars.SyncModVariables(module or ModuleUUID)
    end
end

---@param key any
---@param module? Guid
function VCHelpers.ModVars:Dirty(key, module)
    Ext.Vars.DirtyModVariables(module or ModuleUUID, key)
end

---@param key string
---@param module? Guid
---@param initial? any Value to initialize variable as
---@param properties? table
function VCHelpers.ModVars:Register(key, module, initial, properties)
    local mod = module or ModuleUUID
    properties = properties or {}

    for k, v in pairs(self.DefaultProperties) do
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
            end, { Priority = 1000 })
        end
    end
end


---@param modId string
---@return boolean
function VCHelpers.ModVars:isModLoaded(modId)
    return Ext.Mod.IsModLoaded(modId)
end

---@param modId string modId
---@return boolean
function VCHelpers.ModVars:isModExist(modId, depsModId)
    return Ext.Mod.IsModLoaded(depsModId) and Ext.Mod.IsModLoaded(modId) --deps.Framework_GUID
end