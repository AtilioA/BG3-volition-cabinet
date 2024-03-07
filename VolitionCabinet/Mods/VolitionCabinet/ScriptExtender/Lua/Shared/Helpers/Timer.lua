---@class HelperTimer: Helper
---@field RegisteredObjectTimers table<string, table<Guid, boolean>>
Helpers.Timer = _Class:Create("HelperTimer", Helper, {
    RegisteredObjectTimers = {}
})

---Use only for short durations since callback registration are lost on reload.
---@param object any
---@param time integer milliseconds
---@param timer string
---@param callback fun(object:Guid, esvObject:EsvCharacter|EsvItem, entity:EntityHandle)
---@param canRefreshTimer? boolean Whether the time should be refreshed if the timer is launched again before it finishes
function Helpers.Timer:LaunchRealtimeObjectTimerOneShot(object, time, timer, callback, canRefreshTimer)
    local objectEntity = Helpers.Object:GetCharacter(object) or Helpers.Object:GetItem(object)
    if objectEntity ~= nil then
        local objectGuid = objectEntity.Uuid.EntityUuid

        if canRefreshTimer then
            Osi.RealtimeObjectTimerCancel(objectGuid, timer)
        end

        Osi.RealtimeObjectTimerLaunch(objectGuid, timer, time)

        if not (self.RegisteredObjectTimers[timer] ~= nil and self.RegisteredObjectTimers[timer][objectGuid]) then
            self.RegisteredObjectTimers[timer] = self.RegisteredObjectTimers[timer] or {}
            self.RegisteredObjectTimers[timer][objectGuid] = true

            Events.Osiris.ObjectTimerFinished:Subscribe(function(e)
                if e.Timer == timer and e.ObjectGuid == objectGuid then
                    callback(objectGuid, Helpers.Object:GetObject(objectEntity), objectEntity)
                    self.RegisteredObjectTimers[timer][objectGuid] = nil
                    e:Unsubscribe()
                end
            end)
        end
    end
end

---@param object any
---@param time integer milliseconds
---@param timer string
---@param canRefreshTimer? boolean Whether the time should be refreshed if the timer is launched again before it finishes
function Helpers.Timer:LaunchRealtimeObjectTimer(object, time, timer, canRefreshTimer)
    local objectEntity = Helpers.Object:GetCharacter(object) or Helpers.Object:GetItem(object)
    if objectEntity ~= nil then
        local objectGuid = objectEntity.Uuid.EntityUuid

        if canRefreshTimer then
            Osi.RealtimeObjectTimerCancel(objectGuid, timer)
        end

        Osi.RealtimeObjectTimerLaunch(objectGuid, timer, time)
    end
end

---@param timer string
---@param callback fun(object:Guid, entity:EntityHandle)
function Helpers.Timer:RegisterRealtimeObjectTimerListener(timer, callback)
    Events.Osiris.ObjectTimerFinished:Subscribe(function(e)
        if e.Timer == timer then
            callback(e.ObjectGuid, e.Object)
        end
    end)
end

---Ext.OnNextTick, but variable ticks
---@param ticks integer
---@param fn function
function Helpers.Timer:OnTicks(ticks, fn)
    local ticksPassed = 0
    local eventID
    eventID = Ext.Events.Tick:Subscribe(function()
        ticksPassed = ticksPassed + 1
        if ticksPassed >= ticks then
            fn()
            Ext.Events.Tick:Unsubscribe(eventID)
        end
    end)
end

--- Due to being thrown on-tick, the callback may be performed up to a tick's worth of time after the time is completed, e.g.:
--- Register callback with 50ms delay.
--- Tick 1: 33 ms
--- Tick 2: 66 ms --> callback is performed.
---@param time integer milliseconds
---@param fn function
function Helpers.Timer:OnTime(time, fn)
    local startTime = Ext.Utils.MonotonicTime()
    local eventID
    eventID = Ext.Events.Tick:Subscribe(function()
        if Ext.Utils.MonotonicTime() - startTime >= time then
            fn()
            Ext.Events.Tick:Unsubscribe(eventID)
        end
    end)
end

--- Due to being thrown on-tick, the callback may be performed up to a tick's worth of time after the time is completed, e.g.:
--- Register callback with 50ms delay.
--- Tick 1: 33 ms
--- Tick 2: 66 ms --> callback is performed.
---@param ticks integer
---@param time integer milliseconds
---@param fn function
---@param ticksOrTime? boolean
function Helpers.Timer:OnTicksAndTime(ticks, time, fn, ticksOrTime)
    local startTime = Ext.Utils.MonotonicTime()
    local ticksPassed = 0
    local eventID
    if ticksOrTime then
        eventID = Ext.Events.Tick:Subscribe(function()
            ticksPassed = ticksPassed + 1
            if (Ext.Utils.MonotonicTime() - startTime >= time) or (ticksPassed >= ticks) then
                fn()
                Ext.Events.Tick:Unsubscribe(eventID)
            end
        end)
    else
        eventID = Ext.Events.Tick:Subscribe(function()
            ticksPassed = ticksPassed + 1
            if (Ext.Utils.MonotonicTime() - startTime >= time) and (ticksPassed >= ticks) then
                fn()
                Ext.Events.Tick:Unsubscribe(eventID)
            end
        end)
    end
end