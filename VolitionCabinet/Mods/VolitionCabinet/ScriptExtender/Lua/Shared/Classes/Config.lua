-- TODO: add typedocs and more comments

---@class Config
Config = _Class:Create("Config")

function Config:Create()
  local cls = {}
  setmetatable(cls, Config)
  cls.FolderName = "DefaultFolder"
  cls.configFilePath = "default_config.json"
  cls.defaultConfig = {
    -- Default configurations
  }
  return cls
end

function Config:Init()
  -- Initialization code here, if needed
end

--- Set the folder name, config file path, and default config for the Config object
---@param folderName string The name of the folder
---@param configFilePath string The file path for the config
---@param defaultConfig table The default configuration
function Config:SetConfig(folderName, configFilePath, defaultConfig)
  self.FolderName = folderName or self.FolderName
  self.configFilePath = configFilePath or self.configFilePath
  self.defaultConfig = defaultConfig or self.defaultConfig
end

function Config:GetModPath(filePath)
  return self.FolderName .. '/' .. filePath
end

function Config:LoadConfig(filePath)
  local configFileContent = Ext.IO.LoadFile(self:GetModPath(filePath))
  if configFileContent and configFileContent ~= "" then
    Utils.DebugPrint(1, "Loaded config file: " .. filePath)
    return Ext.Json.Parse(configFileContent)
  else
    Utils.DebugPrint(1, "File not found: " .. filePath)
    return nil
  end
end

function Config:SaveConfig(filePath, config)
  local configFileContent = Ext.Json.Stringify(config, { Beautify = true })
  Ext.IO.SaveFile(self:GetModPath(filePath), configFileContent)
end

function Config:UpdateConfig(existingConfig, defaultConfig)
  local updated = false

  for key, newValue in pairs(defaultConfig) do
    local oldValue = existingConfig[key]


    if oldValue == nil then
      -- Add missing keys from the default config
      existingConfig[key] = newValue
      updated = true
      Utils.DebugPrint(1, "Added new config option:", key)
    elseif type(oldValue) ~= type(newValue) then
      -- If the type has changed...
      if type(newValue) == "table" then
        -- ...and the new type is a table, place the old value in the 'enabled' key
        existingConfig[key] = { enabled = oldValue }
        for subKey, subValue in pairs(newValue) do
          if existingConfig[key][subKey] == nil then
            existingConfig[key][subKey] = subValue
          end
        end
        updated = true
        Utils.DebugPrint(1, "Updated config structure for:", key)
      else
        -- ...otherwise, just replace with the new value
        existingConfig[key] = newValue
        updated = true
        Utils.DebugPrint(1, "Updated config value for:", key)
      end
    elseif type(newValue) == "table" then
      -- Recursively update for nested tables
      if Config.UpdateConfig(oldValue, newValue) then
        updated = true
      end
    end
  end

  -- Remove deprecated keys
  for key, _ in pairs(existingConfig) do
    if defaultConfig[key] == nil then
      -- Remove keys that are not in the default config
      existingConfig[key] = nil
      updated = true
      Utils.DebugPrint(1, "Removed deprecated config option:", key)
    end
  end

  return updated
end

function Config:LoadJSONConfig()
  local jsonConfig = self:LoadConfig(self.configFilePath)
  if not jsonConfig then
    jsonConfig = self.defaultConfig
    self:SaveConfig(self.configFilePath, jsonConfig)
    Utils.DebugPrint(1, "Default config file loaded.")
  else
    if self:UpdateConfig(jsonConfig, self.defaultConfig) then
      self:SaveConfig(self.configFilePath, jsonConfig)
      Utils.DebugPrint(1, "Config file updated with new options.")
    else
      Utils.DebugPrint(1, "Config file loaded.")
    end
  end

  return jsonConfig
end

-- TODO:
function Config:ReloadConfigCmd()
  self:LoadJSONConfig()
  Utils.DebugPrint(1, "Config reloaded.")
end

-- Reload the JSON config when executing `reload_config` on SE console
Ext.RegisterConsoleCommand('reload_config', function() Config:ReloadConfigCmd() end)
