---@class HelperCommander: Helper
VCHelpers.Commander = _Class:Create("HelperCommander", Helper)


--- Command is not case sensitive.
--- Any number of additional params can be included and will be passed back into the callback registered.
---@param command string
---@param fn function
---@vararg any
function VCHelpers.Commander:Register(command, fn)
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

if VCHelpers.Commander.IsServer then
    Ext.Events.SessionLoaded:Subscribe(function()
        local function restore()
            -- Iterate whole party
            local party = VCHelpers.Party:GetPartyMembers()
            for _, character in pairs(party) do
                VCHelpers.Resource:SetActionResource(character, "SpellSlot", "Max")
                VCHelpers.Resource:SetActionResource(character, "WarlockSpellSlot", "Max")
            end
            -- VCHelpers.Timer:LaunchRealtimeObjectTimerOneShot(_C(), 200, "VolitionCabinetRestore", function()
            --     --Apply statuses here
            -- end)
        end
        -- Ext.Events.ResetCompleted:Subscribe(restore)

        VCHelpers.Commander:Register("pe", function(guid) VCHelpers.Feedback:PlayEffect(guid) end)
        VCHelpers.Commander:Register("r", function()
            -- restore()
            Osi.RestoreParty(Osi.GetHostCharacter())
        end)
        VCHelpers.Commander:Register("RestoreResources", restore)
        VCHelpers.Commander:Register("ApplyStatus",
            function(status) Osi.ApplyStatus(Osi.GetHostCharacter(), status, -1, 1, Osi.GetHostCharacter()) end)
        VCHelpers.Commander:Register("GenTT", function(tt) VCHelpers.Inventory:GenerateTreasureTable(tt) end)
    end)
end

Ext.Events.SessionLoaded:Subscribe(function()
    VCHelpers.Commander:Register("DumpFile",
        function(guid)
            guid = guid or VCHelpers.Object:GetHostEntity().Uuid.EntityUuid; Ext.IO.SaveFile("Dump.json",
                Ext.DumpExport(Ext.Entity.Get(guid):GetAllComponents()))
        end)
end)
