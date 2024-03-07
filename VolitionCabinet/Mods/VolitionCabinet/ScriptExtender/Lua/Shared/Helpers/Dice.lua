
---@class HelperDice: Helper
Helpers.Dice = _Class:Create("HelperDice", Helper)

---@param diceAmount integer
---@param faces integer
---@param minDieValue? integer
---@param maxDieValue? integer
---@return integer
function Helpers.Dice:Roll(diceAmount, faces, minDieValue, maxDieValue)
    local total = 0
    local min = math.min(minDieValue or 1, faces)
    local max = math.min(maxDieValue or faces, faces)
    for i = 1, diceAmount do
        total = total + Ext.Math.Random(min, max)
    end
    return total
end

-- Rolls dice where the min die amount increases up to the final die value
-- The final die is guaranteed to roll the max value.
---@param diceAmount integer
---@param faces integer
---@param startingDieValue? integer
---@param endingDieValue? integer
---@return integer
function Helpers.Dice:RollUpgradingDice(diceAmount, faces, startingDieValue, endingDieValue)
    startingDieValue = startingDieValue or 1
    endingDieValue = endingDieValue or faces

    local total = 0
    local roll = 1
    while roll <= diceAmount do
        local minDie = startingDieValue + Ext.Math.Round((endingDieValue - startingDieValue) / (diceAmount - 1) * (roll - 1))
        total = total + Helpers.Dice:Roll(1, faces, minDie)
        roll = roll + 1
    end
    return total
end