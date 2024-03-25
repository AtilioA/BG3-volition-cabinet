--[[
    This Helper file is for functions that are related to the camp, such as camp chest functionality.
-- ]]

---@class HelperCamp: Helper
VCHelpers.Camp = _Class:Create("HelperCamp", Helper)


--- Gets the local UUID of the camp chest template.
---@return Guid|nil
function VCHelpers.Camp:GetChestTemplateUUID()
  local result = Osi.DB_Camp_UserCampChest:Get(nil, nil)
  local chestName = result and result[1] and result[1][2] or nil

  -- I don't know if I can just return 'and tostring(result[1][2])', so I'm doing it in two more steps.
  if chestName then return chestName
  else return nil end
end
