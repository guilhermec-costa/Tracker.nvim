local utils = require "tracker.utils"
local events_configs = require "tracker.default_events_config"
---@class Tracker
---@field session_id string
local Tracker = {}
Tracker.__index = Tracker

function Tracker.new(opts)
    local self = setmetatable({}, Tracker)
    self:initialize(opts)
    return self
end

function Tracker:initialize(opts)
    local defaults = self:__generate_tracker_default_values()
    self.session_id = defaults.session_id
    self.start_timestamp = defaults.start_timestamp
    self.events = events_configs
    self.event_debounce_time = opts.event_debounce_time
    self.is_running = true
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

function Tracker:start_timer()
    if self.is_running == false then
        self.is_running = true
    end

    local timer = vim.loop.new_timer()

    timer:start(1000, 3000, vim.schedule_wrap(function()
        print("Running for " .. self:get_running_time() .. "s")
    end))
end

function Tracker:pause()
    self.is_running = false
end

function Tracker:get_running_time()
    local session_start_timestamp = self.start_timestamp
    return os.time() - session_start_timestamp
end

return Tracker
