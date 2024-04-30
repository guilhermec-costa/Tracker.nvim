---@module "tracker"

local types = require("tracker.types")
local utils = {}

local tracker_defaults = types.tracker_defaults
---@return tracker_defaults
utils.get_tracker_default_values = function ()
    local tracker_start_time_timestamp = os.time()
    local session_id = tracker_start_time_timestamp
    return {
        tracker_start_time = tracker_start_time_timestamp,
        session_id = session_id
    }
end

return utils
