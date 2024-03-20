---@class HelperLog: Helper
VCHelpers.Log = _Class:Create("HelperLog", Helper)

function VCHelpers.Log:LogGameStates()
    ---@param e EsvLuaGameStateChangedEvent|EclLuaGameStateChangedEvent
    Ext.Events.GameStateChanged:Subscribe(function(e)
        VCDebug(string.format("%s --> %s", e.FromState, e.ToState))
    end)

    local ExtenderEvents = {
        "ModuleLoadStarted",
        "SessionLoading",
        "SessionLoaded",
        "StatsLoaded",
        --"StatsStructureLoaded",
    }

    for _, event in pairs(ExtenderEvents) do
        Ext.Events[event]:Subscribe(function(e)
            VCDebug(string.format("%s fired.", event))
        end)
    end
end

Ext.RegisterConsoleCommand("ROL", function(_, osiFunction, arity)
    Ext.Osiris.RegisterListener(osiFunction, arity, "before", function(...)
        local args = Ext.DumpExport({ ... })
        VCDebug(osiFunction .. ": %s", args)
    end)
end)

Ext.RegisterConsoleCommand("REL", function(_, extenderEvent)
    Ext.Events[extenderEvent]:Subscribe(function(e)
        VCDump({ extenderEvent, { e } })
    end)
end)
