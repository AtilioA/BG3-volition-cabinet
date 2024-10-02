---@class HelperTimer: Helper
---@field RegisteredObjectTimers table<string, table<Guid, boolean>>
VCHelpers.Timer = _Class:Create("HelperTimer", Helper, {
    RegisteredObjectTimers = {}
})

---Use only for short durations since callback registration are lost on reload.
---@param object any
---@param time integer milliseconds
---@param timer string
---@param callback fun(object:Guid, esvObject:EsvCharacter|EsvItem, entity:EntityHandle)
---@param canRefreshTimer? boolean Whether the time should be refreshed if the timer is launched again before it finishes
function VCHelpers.Timer:LaunchRealtimeObjectTimerOneShot(object, time, timer, callback, canRefreshTimer)
    local objectEntity = VCHelpers.Object:GetCharacter(object) or VCHelpers.Object:GetItem(object)
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
                    callback(objectGuid, VCHelpers.Object:GetObject(objectEntity), objectEntity)
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
function VCHelpers.Timer:LaunchRealtimeObjectTimer(object, time, timer, canRefreshTimer)
    local objectEntity = VCHelpers.Object:GetCharacter(object) or VCHelpers.Object:GetItem(object)
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
function VCHelpers.Timer:RegisterRealtimeObjectTimerListener(timer, callback)
    Events.Osiris.ObjectTimerFinished:Subscribe(function(e)
        if e.Timer == timer then
            callback(e.ObjectGuid, e.Object)
        end
    end)
end

---Ext.OnNextTick, but variable ticks
---@param ticks integer
---@param fn function
function VCHelpers.Timer:OnTicks(ticks, fn)
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
function VCHelpers.Timer:OnTime(time, fn)
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
function VCHelpers.Timer:OnTicksAndTime(ticks, time, fn, ticksOrTime)
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

--- Debounce a function call to prevent it from being called multiple times in a given time frame.
---@param time integer milliseconds
---@param func function The function to debounce.
function VCHelpers.Timer:Debounce(timeInMs, func)
    local timer = nil

    return function(...)
        local args = { ... }

        if timer then
            Ext.Timer.Cancel(timer)
        end

        timer = Ext.Timer.WaitFor(timeInMs, function()
            func(table.unpack(args))
            timer = nil
        end)
    end
end

--- Calls the callback with an interval and stops calling the callback when the totalTime is reached.
--- @param callback function The callback to call.
--- @param interval integer The interval to wait before calling the callback again.
--- @param totalTime integer The total time to call the callback.
function VCHelpers.Timer:CallWithInterval(callback, interval, totalTime)
    if totalTime <= 0 then
        return
    end

    local elapsedTime = 0

    local function invokeCallback()
        if elapsedTime >= totalTime then
            return
        end

        local stop = callback()
        if stop ~= nil or stop ~= false then
            return
        end

        elapsedTime = elapsedTime + interval
        if elapsedTime < totalTime then
            Ext.Timer.WaitFor(interval, invokeCallback)
        end
    end

    if interval > totalTime then
        interval = totalTime
    end

    invokeCallback()
end

--- Repeatedly calls the main callback at specified intervals until the condition callback returns true.
--- @param mainCallback function The primary function to execute.
--- @param intervalMs integer The time interval in milliseconds between each call of the main callback.
--- @param conditionCallback function A function that returns true to stop further execution of the main callback.
function VCHelpers.Timer:ExecuteWithIntervalUntilCondition(mainCallback, intervalMs, conditionCallback)
    local function attemptCallbackExecution()
        if conditionCallback() then
            return
        end

        if mainCallback() then
            return
        end

        Ext.Timer.WaitFor(intervalMs, attemptCallbackExecution)
    end

    attemptCallbackExecution()
end
