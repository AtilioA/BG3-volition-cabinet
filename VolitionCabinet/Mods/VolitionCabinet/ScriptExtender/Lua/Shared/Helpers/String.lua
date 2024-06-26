--[[
  This file contains a set of helper functions for working with strings, such as checking if a string contains a substring, calculating the Levenshtein distance between two strings, and finding the closest match from a list of valid options to an input string, which can be used to validate user config files.
]]

---@class HelperString: Helper
VCHelpers.String = _Class:Create("HelperString", Helper)

---Check if string contains a substring (Courtesy of Fararagi although fr I was just lazy)
---@param str string the string to check
---@param substr string the substring
---@param caseSensitive? boolean
---@return boolean
function VCHelpers.String:StringContains(str, substr, caseSensitive)
  caseSensitive = caseSensitive or false
  if caseSensitive then
    return string.find(str, substr, 1, true) ~= nil
  else
    str = string.lower(str)
    substr = string.lower(substr)
    return string.find(str, substr, 1, true) ~= nil
  end
end

--- Calculate the Levenshtein distance between two strings.
--- Useful for fuzzy string matching to find the closest match, when for example a user has to input a string and you want to find the closest match from a list of valid options (e.g. config values).
function VCHelpers.String:LevenshteinDistance(str1, str2, case_sensitive)
  if not case_sensitive then
    str1 = string.lower(str1)
    str2 = string.lower(str2)
  end

  local len1 = string.len(str1)
  local len2 = string.len(str2)
  local matrix = {}
  local cost = 0

  -- Initialize the matrix
  for i = 0, len1, 1 do
    matrix[i] = { [0] = i }
  end
  for j = 0, len2, 1 do
    matrix[0][j] = j
  end

  -- Calculate distances
  for i = 1, len1, 1 do
    for j = 1, len2, 1 do
      if string.byte(str1, i) == string.byte(str2, j) then
        cost = 0
      else
        cost = 1
      end

      matrix[i][j] = math.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost)
    end
  end

  return matrix[len1][len2]
end

--- Find the closest match and distance given a list of valid options to an input string, using the Levenshtein distance.
---@param input string The user input string
---@param valid_options string[] A table of valid options to compare against
---@param case_sensitive? boolean Whether to consider case sensitivity when comparing strings
--- @return string|nil closest_match The closest matching string from the valid options.
--- @return number min_distance The Levenshtein distance between the user input and the closest match.
function VCHelpers.String:FindClosestMatch(input, valid_options, case_sensitive)
  local min_distance = math.huge -- Represents infinity, just to initialize the variable
  local closest_match = nil
  for _, option in ipairs(valid_options) do
    local distance = self:LevenshteinDistance(input, option, case_sensitive)
    if distance < min_distance then
      min_distance = distance
      closest_match = option
    end
  end
  return closest_match, min_distance
end

--- Capitalize the first letter of a string
---@param str string The string to capitalize
function VCHelpers.String:Capitalize(str)
  return str:gsub("^%l", string.upper)
end

--- Lowercase the first letter of a string
---@param str string The string to lowercase
function VCHelpers.String:Lowercase(str)
  return str:gsub("^%u", string.lower)
end

--- Replace <br> tags with newlines in a string
function VCHelpers.ReplaceBrWithNewlines(description)
    return string.gsub(description, "<br>", "\n")
end
