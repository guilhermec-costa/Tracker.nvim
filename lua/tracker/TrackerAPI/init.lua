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
    self.tracker_start_time = defaults.tracker_start_time
    self.events = events_configs
    self.event_debounce_time = opts.event_debounce_time
end

---@return table<string, string>
function Tracker:__generate_tracker_default_values()
    local tracker_start_timestamp = os.time()
    local session_id = utils.generate_session_id();
    return {
        tracker_start_time = tracker_start_timestamp,
        session_id = session_id
    }
end

return Tracker
