local utils = require "tracker.utils"
local events_configs = require "tracker.default_events_config"

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

function Tracker:start_timer()
    local timer = vim.loop.new_timer()
    self.timer = timer
    local delay = 3000
    if self.has_timer_started == false then
        timer:start(1000, delay, vim.schedule_wrap(function()
            if self.is_running then
                self.runned_for = self.runned_for + (delay / 1000)
            end
        end))
        self.has_timer_started = true
    else
        print("Timer has already started")
    end
end

function Tracker:reset()
    if self.timer then
        self.timer:close()
        self.runned_for = 0
    else print("Any target initialized yet")
    end
end


function Tracker:pause()
    self.is_running = false
end

function Tracker:resume()
    self.is_running = true
end

function Tracker:get_running_time()
    return self.runned_for
end

return Tracker
