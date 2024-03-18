--[[
    Handles loading, saving, and updating configuration settings for mods.

    Dependencies: Requires Ext.IO for file operations and Ext.Json for JSON parsing and stringification. Cannot use Printer since that one relies on this module.

    Usage: This module defines a Config object that is used to manage mod configurations. It supports loading from a JSON file, saving updates back to the file, and dynamically updating configuration settings based on in-game commands.
]]

---@class HelperConfig: Helper
--- @field folderName string|nil The folder where the configuration files are located.
--- @field configFilePath string|nil The path to the configuration JSON file.
--- @field defaultConfig table The default configuration values for the mod, utilized when the configuration file is not found or when missing keys are detected.
--- @field currentConfig table The current configuration values after loading and potentially updating from a file.
--- @field onConfigReloaded table A list of callbacks to be executed when the configuration is reloaded.
Helpers.Config = _Class:Create("HelperConfig", Helper)

--- Sets basic configuration properties: folder name, config file path, and default config for the Config object
--- @param folderName string The name of the folder where the config file is stored.
--- @param configFilePath string The path to the configuration file relative to the folder.
--- @param defaultConfig table The default configuration values.
function Helpers.Config:SetConfig(folderName, configFilePath, defaultConfig)
  self.folderName = folderName or self.folderName
  self.configFilePath = configFilePath or self.configFilePath
  self.defaultConfig = defaultConfig or self.defaultConfig
end

--- Generates the full path to a configuration file, starting from the Script Extender folder.
--- @param filePath string The file name or relative path within the folderName.
--- @return string The full path to the config file.
function Helpers.Config:GetModConfigPath(filePath)
  return self.folderName .. '/' .. filePath
end

--- Loads a configuration from a file.
--- @param filePath string The file path to load the configuration from.
--- @return table|nil The loaded configuration table, or nil if loading failed.
function Helpers.Config:LoadConfig(filePath)
  local configFileContent = Ext.IO.LoadFile(self:GetModConfigPath(filePath))
  if configFileContent and configFileContent ~= "" then
    -- VCPrint(1, "Loaded config file: " .. filePath)
    local success, parsed = pcall(Ext.Json.Parse, configFileContent)
    if success then
      return parsed
    else
      VCPrint(0, "Failed to parse config file: " .. filePath .. " - Regenerating default config.")
      self:SaveConfig(self.configFilePath, self.defaultConfig)
      return self.currentConfig
    end
  else
    VCPrint(0, "File not found: " .. filePath)
    return nil
  end
end

--- Saves the given configuration to a file.
--- @param filePath string The file path to save the configuration to.
--- @param config table The configuration table to save.
function Helpers.Config:SaveConfig(filePath, config)
  local configFileContent = Ext.Json.Stringify(config, { Beautify = true })
  Ext.IO.SaveFile(self:GetModConfigPath(filePath), configFileContent)
end

--- Saves the current configuration to its file, using the object's values.
function Helpers.Config:SaveCurrentConfig()
  Ext.IO.SaveFile(self:GetModConfigPath(self.configFilePath), Ext.Json.Stringify(self.currentConfig, { Beautify = true }))
end

--- Updates an existing configuration with values from the default configuration.
--- Recursively updates nested tables and ensures key/type consistency.
--- @param existingConfig table The existing configuration to be updated.
--- @param defaultConfig table The default configuration to update or check from.
--- @return boolean updated true if the configuration was updated, false otherwise.
function Helpers.Config:UpdateConfig(existingConfig, defaultConfig)
  local updated = false

  for key, newValue in pairs(defaultConfig) do
    local oldValue = existingConfig[key]

    if oldValue == nil then
      -- Add missing keys from the default config
      existingConfig[key] = newValue
      updated = true
      VCPrint(0, "Added new config option: " .. tostring(key) .. " to " .. self.configFilePath)
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
        VCPrint(0, "Updated config structure for: " .. tostring(key) .. " (" .. self.configFilePath .. ")")
      else
        -- ...otherwise, just replace with the new value
        existingConfig[key] = newValue
        updated = true
        VCPrint(0, "Updated config value for: " .. tostring(key) .. " (" .. self.configFilePath .. ")")
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
      VCPrint(0, "Removed deprecated config option: " .. tostring(key) .. " (" .. self.configFilePath .. ")")
    end
  end

  return updated
end

--- Loads the configuration from the JSON file, updates it from the defaultConfig if necessary,
--- and saves back if changes are detected or if the file was not present.
--- @return table jsonConfig The loaded (and potentially updated) configuration.
function Helpers.Config:LoadJSONConfig()
  local jsonConfig = self:LoadConfig(self.configFilePath)
  if not jsonConfig then
    jsonConfig = self.defaultConfig
    self:SaveConfig(self.configFilePath, jsonConfig)
    VCPrint(0, "Created config file with default options." .. " (" .. self.configFilePath .. ")")
  else
    if self:UpdateConfig(jsonConfig, self.defaultConfig) then
      self:SaveConfig(self.configFilePath, jsonConfig)
      VCPrint(0, "Config file updated with new options." .. " (" .. self.configFilePath .. ")")
    else
      -- Commented out because it's too verbose and we don't have access to a proper Printer object here
      -- VCPrint(1, "Config file loaded.")
    end
  end

  return jsonConfig
end

--- Updates the currentConfig property with the configuration loaded from the file.
function Helpers.Config:UpdateCurrentConfig()
  self.currentConfig = self:LoadJSONConfig()
end

--- Accessor for the current configuration.
--- @return table The current configuration.
function Helpers.Config:getCfg()
  return self.currentConfig
end

--- Retrieves the current debug level from the configuration.
--- @return number The current debug level, with a default of 0 if not set.
function Helpers.Config:GetCurrentDebugLevel()
  if self.currentConfig then
    return tonumber(self.currentConfig.DEBUG.level) or 0
  else
    return 0
  end
end

function Helpers.Config:AddConfigReloadedCallback(callback)
  if self.onConfigReloaded == nil then
    self.onConfigReloaded = {}
  end

  table.insert(self.onConfigReloaded, callback)
end

function Helpers.Config:NotifyConfigReloaded()
  if self.onConfigReloaded == nil then
    return
  end

  for _, callback in ipairs(self.onConfigReloaded) do
    callback(self)
  end
end

function Helpers.Config:RegisterReloadConfigCommand(prefix)
  local commandName = prefix:lower() .. "_reload"
  Ext.RegisterConsoleCommand(commandName, function()
    self:UpdateCurrentConfig()
    self:NotifyConfigReloaded() -- Notify all subscribers that config has been reloaded.
  end)
end
