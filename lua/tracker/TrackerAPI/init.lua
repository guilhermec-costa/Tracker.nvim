local utils = require "tracker.utils"
local events_configs = require "tracker.default_events_config"
local notify = require "notify"

---@class Tracker
local Tracker = {}
Tracker.__index = Tracker

function Tracker.new_session(opts)
    local self = setmetatable({}, Tracker)
    self:initialize(opts)
    return self
end

function Tracker:initialize(opts)
    local defaults = self:__generate_tracker_default_values()
    self.session_id = defaults.session_id
    self.events = events_configs
    self.event_debounce_time = opts.event_debounce_time
    self.is_running = true
    self.runned_for = 0
    self.has_timer_started = false
    self.allow_notifications = opts.allow_notifications
end

---@return table<string, string>
function Tracker:__generate_tracker_default_values()
    local tracker_start_timestamp = os.time()
    local session_id = utils.generate_session_id();
    return {
        start_timestamp = tracker_start_timestamp,
        session_id = session_id
    }
end

function Tracker:get_active_events()
    local active_events = {}
    for event_name, event_metadata in pairs(self.events) do
        if event_metadata.status == 1 then
            table.insert(active_events, event_metadata)
        end
    end
    return active_events
end

function Tracker:get_inactive_events()
    local inactive_events = {}
    for event_name, event_metadata in pairs(self.events) do
        if event_metadata.status == 0 then
            table.insert(inactive_events, event_metadata)
        end
    end
    return inactive_events
end

function Tracker:start_timer(debounce)
    debounce = debounce or 5000
    local timer = vim.loop.new_timer()
    self.timer = timer
    if self.has_timer_started == false then
        notify("Tracker Timer has started")
        timer:start(100, debounce, vim.schedule_wrap(function()
            if self.is_running then
                self.runned_for = self.runned_for + (debounce / 1000)
            end
        end))
        self.has_timer_started = true
    else
        notify("Timer has already been started")
    end
end

function Tracker:reset_timer()
    if self.timer then
        self.timer:close()
        self.runned_for = 0
        self.has_timer_started = false
        self:start_timer()
        self:notify("Tracker paused has been reset")
    else
        self:notify("Any target initialized yet")
    end
end

function Tracker:pause_timer()
    self.is_running = false
    self:notify("Tracker timer has been paused")
end

function Tracker:resume_timer()
    self.is_running = true
end

function Tracker:get_session_id()
    return self.session_id
end

function Tracker:get_running_time()
    return self.runned_for
end


function Tracker:notify(message)
    if self.allow_notifications then
        notify(message)
    else
        print(message)
    end
end

return Tracker
