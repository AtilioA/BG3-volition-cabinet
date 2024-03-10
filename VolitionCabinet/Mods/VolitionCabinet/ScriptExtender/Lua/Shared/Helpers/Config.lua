-- TODO: add typedocs and more comments

---@class HelperConfig: Helper
Helpers.Config = _Class:Create("HelperConfig", Helper)

function Helpers.Config:Create()
  local cls = setmetatable({}, { __index = Helpers.Config })

  cls.folderName = nil
  cls.configFilePath = nil
  cls.defaultConfig = {}
  cls.currentConfig = {}

  return cls
end

--- Set the folder name, config file path, and default config for the Config object
---@param folderName string The name of the folder
---@param configFilePath string The file path for the config
---@param defaultConfig table The default configuration
function Helpers.Config:SetConfig(folderName, configFilePath, defaultConfig)
  self.folderName = folderName or self.folderName
  self.configFilePath = configFilePath or self.configFilePath
  self.defaultConfig = defaultConfig or self.defaultConfig
end

function Helpers.Config:GetModConfigPath(filePath)
  return self.folderName .. '/' .. filePath
end

function Helpers.Config:LoadConfig(filePath)
  local configFileContent = Ext.IO.LoadFile(self:GetModConfigPath(filePath))
  if configFileContent and configFileContent ~= "" then
    -- VCPrint(1, "Loaded config file: " .. filePath)
    return Ext.Json.Parse(configFileContent)
  else
    VCPrint(0, "File not found: " .. filePath)
    return nil
  end
end

function Helpers.Config:SaveConfig(filePath, config)
  local configFileContent = Ext.Json.Stringify(config, { Beautify = true })
  Ext.IO.SaveFile(self:GetModConfigPath(filePath), configFileContent)
end

function Helpers.Config:UpdateConfig(existingConfig, defaultConfig)
  local updated = false

  for key, newValue in pairs(defaultConfig) do
    local oldValue = existingConfig[key]


    if oldValue == nil then
      -- Add missing keys from the default config
      existingConfig[key] = newValue
      updated = true
      VCPrint(0, "Added new config option: " .. tostring(key))
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
        VCPrint(0, "Updated config structure for: " .. tostring(key))
      else
        -- ...otherwise, just replace with the new value
        existingConfig[key] = newValue
        updated = true
        VCPrint(0, "Updated config value for: " .. tostring(key))
      end
    elseif type(newValue) == "table" then
      -- Recursively update for nested tables
      if self:UpdateConfig(oldValue, newValue) then
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
      VCPrint(0, "Removed deprecated config option: " .. tostring(key))
    end
  end

  return updated
end

function Helpers.Config:LoadJSONConfig()
  local jsonConfig = self:LoadConfig(self.configFilePath)
  if not jsonConfig then
    jsonConfig = self.defaultConfig
    self:SaveConfig(self.configFilePath, jsonConfig)
    VCPrint(0, "Default config file loaded.")
  else
    if self:UpdateConfig(jsonConfig, self.defaultConfig) then
      self:SaveConfig(self.configFilePath, jsonConfig)
      VCPrint(0, "Config file updated with new options.")
    else
      -- VCPrint(1, "Config file loaded.")
    end
  end

  return jsonConfig
end

function Helpers.Config:UpdateCurrentConfig()
  self.currentConfig = self:LoadJSONConfig()
end

--- Accessor for the current configuration.
--- @return table The current configuration.
function Helpers.Config:getCfg()
  return self.currentConfig
end

function Helpers.Config:GetCurrentDebugLevel()
  if self.currentConfig then
    return tonumber(self.currentConfig.DEBUG.level)
  else
    return 0
  end
end
