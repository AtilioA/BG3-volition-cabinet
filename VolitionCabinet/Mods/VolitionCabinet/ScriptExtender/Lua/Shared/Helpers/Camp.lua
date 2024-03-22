--[[
    This Helper file is for functions that are related to the camp, such as camp chest functionality.
-- ]]

---@class HelperCamp: Helper
VCHelpers.Camp = _Class:Create("HelperCamp", Helper)


--- Gets the local UUID of the camp chest template.
---@return string
function VCHelpers.Camp:GetChestTemplateUUID()
  local chestName = Osi.DB_Camp_UserCampChest:Get(nil, nil)[1][2]
  return tostring(chestName)
end
