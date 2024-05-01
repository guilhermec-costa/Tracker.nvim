local utils = require "tracker.utils"
local events_configs = require "tracker.default_events_config"
---@class Tracker
---@field session_id string
---@field tracker_start_time number
---@field default_events table<string, table>
local Tracker = {}

function Tracker.new_tracker()
    local defaults = Tracker:__generate_tracker_default_values()
    local self = setmetatable({
       session_id = defaults.session_id,
       tracker_start_time = defaults.tracker_start_time,
       default_events = events_configs
    }, Tracker)

    return self
end

function Tracker:__generate_tracker_default_values()
    local tracker_start_timestamp = os.time()
    local session_id = utils.generate_session_id();
    return {
        tracker_start_time = tracker_start_timestamp,
        session_id = session_id
    }
end

return Tracker
