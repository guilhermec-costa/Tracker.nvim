---@module "tracker"

local types = require("tracker.types")
local utils = {}
local random = math.random

local tracker_defaults = types.tracker_defaults
---@return tracker_defaults
utils.generate_tracker_default_values = function()
    local tracker_start_timestamp = os.time()
    local session_id = utils.generate_session_id();
    return {
        tracker_start_time = tracker_start_timestamp,
        session_id = session_id
    }
end



utils.generate_session_id = function()
    local current_timestamp = os.time()
    local random_uuid = utils.generate_random_uuid()
    return tostring(current_timestamp) .. '-' .. random_uuid
end

---@returnrandomrandom string
utils.generate_random_uuid = function()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end


return utils
