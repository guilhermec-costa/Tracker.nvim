local default_aggregators_config = require "tracker.AggregatorAPI.default_aggregators"
local types = require "tracker.types"
local utils = require "tracker.utils"


---@class Notifier
local Notifier = {}
Notifier.__index = Notifier


---@return table
function Notifier.new()
    local self = setmetatable({}, Notifier)
    self:initialize()
    return self
end

function Notifier:initialize()
end

