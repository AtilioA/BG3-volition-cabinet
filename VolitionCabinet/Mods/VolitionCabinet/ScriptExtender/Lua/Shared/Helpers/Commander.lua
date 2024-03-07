---@class HelperCommander: Helper
Helpers.Commander = _Class:Create("HelperCommander", Helper)


--- Command is not case sensitive.
--- Any number of additional params can be included and will be passed back into the callback registered.
---@param command string
---@param fn function
---@vararg any
function Helpers.Commander:Register(command, fn)
    Events.Extender.DoConsoleCommand:Subscribe(function(e)
        local cmdArgs = {}
        for arg in e.Command:gmatch("(%S+)") do
            table.insert(cmdArgs, tonumber(arg) or arg)
        end
        if string.lower(command) == string.lower(cmdArgs[1]) then
            fn(table.unpack(cmdArgs, 2))
        end
    end)
end

if Helpers.Commander.IsServer then
    Ext.Events.SessionLoaded:Subscribe(function()
        local function restore()
            Helpers.Resource:SetActionResource(_C(), "ActionPoint", "Max")
            Helpers.Resource:SetActionResource(_C(), "BonusActionPoint", "Max")
            Helpers.Resource:SetActionResource(_C(), "ReactionActionPoint", "Max")
            Helpers.Timer:LaunchRealtimeObjectTimerOneShot(_C(), 200, "VolitionCabinetRestore", function()
                --Apply statuses here
            end)
        end
        Ext.Events.ResetCompleted:Subscribe(restore)
        Helpers.Commander:Register("Restore", function()
            restore()
            Osi.RestoreParty(Osi.GetHostCharacter())
        end)
        Helpers.Commander:Register("RestoreResources", restore)
        Helpers.Commander:Register("ApplyStatus",
            function(status) Osi.ApplyStatus(Osi.GetHostCharacter(), status, -1, 1, Osi.GetHostCharacter()) end)
        Helpers.Commander:Register("GenTT", function(tt) Helpers.Inventory:GenerateTreasureTable(tt) end)
    end)
end

Ext.Events.SessionLoaded:Subscribe(function()
    Helpers.Commander:Register("DumpFile",
        function(guid)
            guid = guid or Helpers.Object:GetHostEntity().Uuid.EntityUuid; Ext.IO.SaveFile("Dump.json",
                Ext.DumpExport(Ext.Entity.Get(guid):GetAllComponents()))
        end)
end)
