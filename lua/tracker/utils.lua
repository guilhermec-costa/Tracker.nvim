---@module "tracker"

local utils = {}
local random = math.random

utils.generate_random_uuid = function()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

utils.generate_session_id = function()
    local current_timestamp = os.time()
    local random_uuid = utils.generate_random_uuid()
    return tostring(current_timestamp) .. '-' .. random_uuid
end


return utils
