---@class HelperCF: Helper
VCHelpers.CF = _Class:Create("HelperCF", Helper)

--Helper Used in https://github.com/novus213/BG3_RacialASI (https://www.nexusmods.com/baldursgate3/mods/3015)
-- if Ext.Mod.IsModLoaded(Data.Deps.Framework_GUID) then
--     Ext.Events.StatsLoaded:Subscribe(function() Mods.SubclassCompatibilityFramework.Api.ToggleDebug(true) end)
-- end

--- Add Strings Payload
---@param modGuid string mod modGuid
---@param target string Target UUID
---@param type string (Boosts ect.)
---@param strings table Strings abilities
---@return table payload
function VCHelpers.CF:addStringPayload(modGuid, target, type, strings)
    modGuid = modGuid or Data.Deps.GustavDev_GUID
    return {
        {
            modGuid = modGuid,
            FileType = "Progression",
            Target = target,
            Type = type,
            Strings = strings
        }
    }
end

--- Remove Strings Payload
---@param modGuid string mod modGuid
---@param target string Target UUID
---@param type string (Boosts ect.)
---@param strings table Strings abilities
---@return table payload
function VCHelpers.CF:removeStringPayload(modGuid, target, type, strings)
    modGuid = modGuid or Data.Deps.GustavDev_GUID
    return {
        {
            modGuid = modGuid,
            FileType = "Progression",
            Target = target,
            Type = type,
            Strings = strings
        }
    }
end

--- Remove Selector Payload
---@param modGuid string mod modGuid
---@param target string Target UUID
---@param type string (Boosts ect.)
---@param sabUUID string ListUUID
---@return table payload
function VCHelpers.CF:removeSelectorsPayload(modGuid, target, type, sabUUID)
    modGuid = modGuid or Data.Deps.GustavDev_GUID
    type = type or "SelectAbilityBonus"
    sabUUID = sabUUID or Data.Deps.AbilityList_UUID
    return {
        {
            modGuid = modGuid,
            FileType = "Progression",
            TargetUUID = target,
            Function = type,
            ListUUID = sabUUID
        }
    }
end

--- Insert Selectors Payload
---@param modGuid string mod modGuid
---@param target string Target UUID
---@param type string Function (SelectAbilityBonus ect.)
---@param sabUUID string SelectAbilityBonus UUID
---@param sabAmount table SelectAbilityBonus Amount ex. {"2","1"}
---@param sabAmounts integer SelectAbilityBonus Amounts ex. here 2
---@param BonusType string BonusType UUID
---@return table payload
function VCHelpers.CF:InsertSelectorsPayload(modGuid, target, type, sabUUID, sabAmount, sabAmounts, BonusType)
    modGuid = modGuid or Data.Deps.GustavDev_GUID
    type = type or "SelectAbilityBonus"
    if type == "SelectAbilityBonus" then
        BonusType = "AbilityBonus"
    end
    sabUUID = sabUUID or Data.Deps.AbilityList_UUID
    return {
        {
            modGuid = modGuid,
            FileType = "Progression",
            Function = type,
            Target = target,
        Params = {
            Guid = sabUUID,
            Amount = sabAmount,
            Amounts = sabAmounts,
            BonusType = BonusType
        }
        }
    }
end


--- Add SelectAbilityBonus Payload
---@param modGuid string race mod modGuid
---@param target string Target UUID
---@param type string Function (SelectAbilityBonus ect.)
---@param sabUUID string SelectAbilityBonus UUID
---@param sabAmounts integer SelectAbilityBonus Amounts
---@param BonusType string BonusType UUID
---@return table payload
function VCHelpers.CF:addSelectAbilityBonusPayload(modGuid, target, type, sabUUID, sabAmounts, BonusType)
    modGuid = modGuid or Data.Deps.GustavDev_GUID
    type = type or "SelectAbilityBonus"
    if type == "SelectAbilityBonus" then
        BonusType = "AbilityBonus"
    end
    return {
        {
            modGuid = modGuid,
            FileType = "Progression",
            Target = target,
            Function = type,
            Params = {
                Guid = sabUUID,
                BonusType = BonusType,
                Amounts = sabAmounts
            }
        }
    }
end


--- Add SelectSpells Payload
---@param modGuid string race mod modGuid
---@param target string Target UUID
---@param ssUUID string SelectAbilityBonus UUID
---@param ssAmount string addSelectSpells Amount
---@param payload table payload
---@return table payload
function VCHelpers.CF:addSelectSpellsPayload(modGuid, target, ssUUID, ssAmount, payload)
    modGuid = modGuid or Data.Deps.GustavDev_GUID
    return {
        {
            modGuid = modGuid,
            FileType = "Progression",
            Target = target,
            Function = "SelectSpells",
            Params = {
                Guid = ssUUID,
                Amount = ssAmount,
                SwapAmount = payload.SwapAmount or 0,
                SelectorId = payload.SelectorId,
                CastingAbility = payload.CastingAbility,
                ActionResource = payload.ActionResource,
                PrepareType = payload.PrepareType or "AlwaysPrepared",
                CooldownType = payload.CooldownType
            }
        }
    }
end


--- Add AddSpells Payload
---@param modGuid string race mod modGuid
---@param target string Target UUID
---@param ssUUID string SelectAbilityBonus UUID
---@param payload table payload
---@return table payload
function VCHelpers.CF:addAddSpellsPayload(modGuid, target, ssUUID, payload)
    modGuid = modGuid or Data.Deps.GustavDev_GUID
    return {
        {
            modGuid = modGuid,
            FileType = "Progression",
            Target = target,
            Function = "AddSpells",
            Params = {
                Guid = ssUUID,
                SelectorId = payload.SelectorId,
                CastingAbility = payload.CastingAbility,
                ActionResource = payload.ActionResource,
                PrepareType = payload.PrepareType or "AlwaysPrepared",
                CooldownType = payload.CooldownType
            }
        }
    }
end


--- add SelectPassives Payload
---@param modGuid string race mod modGuid
---@param target string Target UUID
---@param spUUID string SelectAbilityBonus UUID
---@param spAmount string addSelectSpells Amount
---@param selector string addSelectSpells selector
---@return table payload
function VCHelpers.CF:addSelectPassivesPayload(modGuid, target, spUUID, spAmount, selector)
    modGuid = modGuid or Data.Deps.GustavDev_GUID
    return {
        {
            modGuid = modGuid,
            FileType = "Progression",
            Target = target,
            Function = "SelectPassives",
            Params = {
                Guid = spUUID,
                Amount = spAmount,
                SelectorId = selector
            }
        }
    }
end

--- add checkSCF exist
---@return boolean
function VCHelpers.CF:checkSCF()
    if not (Mods.SubclassCompatibilityFramework and Mods.SubclassCompatibilityFramework.Api) then
        VCWarn(2, "============> ERROR: Subclass Compatibility Framework mod or its API is not available.")
        return false
    else
        return true
    end
end