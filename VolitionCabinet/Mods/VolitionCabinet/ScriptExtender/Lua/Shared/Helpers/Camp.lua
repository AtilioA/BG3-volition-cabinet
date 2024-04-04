-- TODO: document all this

--[[
    This Helper file is for functions that are related to the camp, mainly camp chest retrieval
-- ]]

---@class HelperCamp: Helper
VCHelpers.Camp = _Class:Create("HelperCamp", Helper)

VCHelpers.Camp.CampChestsToIndexMapping = {
    ["CONT_PlayerCampChest_A"] = 1, -- 'Player 1' (not really, but by using indices you don't need to worry)
    ["CONT_PlayerCampChest_B"] = 2, -- 'Player 2' (not really, but by using indices you don't need to worry)
    ["CONT_PlayerCampChest_C"] = 3, -- 'Player 3' (not really, but by using indices you don't need to worry)
    ["CONT_PlayerCampChest_D"] = 4, -- 'Player 4' (not really, but by using indices you don't need to worry)
}

--- Gets the player ID of the camp chest.
---@param chestName string The UUID of the camp chest.
---@return integer|nil
function VCHelpers.Camp:GetIndexFromCampChestName(chestName)
    return VCHelpers.Camp.CampChestsToIndexMapping[chestName]
end

--- Gets the local UUID of the camp chest template for Player 1.
---@return Guid|nil
function VCHelpers.Camp:GetChestTemplateUUID()
    local result = Osi.DB_Camp_UserCampChest:Get(nil, nil)
    local chestName = result and result[1] and result[1][2] or nil

    -- I don't know if I can just return 'and tostring(result[1][2])', so I'm doing it in two more steps.
    if chestName then
        return chestName
    else
        return nil
    end
end

--- Gets all active camp chest UUIDs.
---@return table campChestUUIDs A table with all active (considering userID) camp chest UUIDs.
function VCHelpers.Camp:GetAllActiveCampChestsUUIDs()
    ---@type table<number, string>
    local campChestUUIDs = {}

    local campChests = Osi.DB_Camp_UserCampChest:Get(nil, nil)
    if campChests then
        for _, chestInfo in ipairs(campChests) do
            -- _D(chestInfo)
            local playerID = chestInfo[1]
            local chestUUID = chestInfo[2]
            if playerID and chestUUID then
                campChestUUIDs[tostring(playerID)] = chestUUID
            end
        end
    end

    return campChestUUIDs
end

--- Gets all camp chest entities.
---@return table
function VCHelpers.Camp:GetAllCampChestEntities()
    return Ext.Entity.GetAllEntitiesWithComponent("CampChest")
end

--- Gets all camp chest UUIDs.
---@return table campChestUUIDs A table with all camp chest UUIDs.
function VCHelpers.Camp:GetAllCampChestUUIDs()
    ---@type table<string>
    local campChestUUIDs = {}

    local campChestEntities = VCHelpers.Camp:GetAllCampChestEntities()
    for _, entity in pairs(campChestEntities) do
        table.insert(campChestUUIDs, entity.Uuid.EntityUuid)
    end
    return campChestUUIDs
end
