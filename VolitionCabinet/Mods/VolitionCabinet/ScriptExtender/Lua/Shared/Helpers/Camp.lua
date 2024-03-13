--[[
    This Helper file is for functions that are related to the camp, such as the camp chest and sending items to it.
-- ]]

---@class HelperCamp: Helper
Helpers.Camp = _Class:Create("HelperCamp", Helper)


function Helpers.Camp:GetChestTemplateUUID()
  local chestName = Osi.DB_Camp_UserCampChest:Get(nil, nil)[1][2]
  return chestName
end