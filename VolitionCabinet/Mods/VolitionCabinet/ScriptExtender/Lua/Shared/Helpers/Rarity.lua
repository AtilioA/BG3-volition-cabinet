--[[
--- This file contains helper functions related to managing rarity for items in the game.
--- Ext.Enums.ItemDataRarity does not map from string names to numeric keys, so in this file, for example, we create a reverse mapping from rarity names to their enum numeric keys.
--]]

---@class HelperRarity: Helper
VCHelpers.Rarity = _Class:Create("HelperRarity", Helper)


VCHelpers.Rarity.RarityToEnumKey = {
    ["Common"] = 0,
    ["Unique"] = 1,
    ["Uncommon"] = 2,
    ["Rare"] = 3,
    ["Epic"] = 4,
    ["Legendary"] = 5,
    ["Divine"] = 6,
    ["Sentinel"] = 7
}

--- Get the rarity of an item
---@param item EsvItem The item to check
---@return ItemDataRarity rarity The enum string value for the rarity of the item
function VCHelpers.Rarity:GetItemRarity(object)
    local item = VCHelpers.Object:GetItem(object)

    -- Fall back to common if the item is nil or has no rarity
    if item == nil or item.Value == nil or item.Value.Rarity == nil or item.Value.Rarity < 1 then
        return "Common"
    end

    return Ext.Enums.ItemDataRarity[item.Value.Rarity]
end

---@param object any
---@param rarity ItemDataRarity The rarity to compare against (defined as an enum, e.g. "Common", etc)
---@return boolean
function VCHelpers.Rarity:IsItemRarityEqualOrLower(object, rarity)
    local itemRarity = self:GetItemRarity(object)
    local itemRarityKey = self.RarityToEnumKey[itemRarity]
    local rarityKey = self.RarityToEnumKey[rarity]

    if not itemRarityKey or not rarityKey then
        error("Rarity comparison failed: invalid rarity data")
    end

    return itemRarityKey <= rarityKey
end
