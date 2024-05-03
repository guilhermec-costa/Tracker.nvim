local default_aggregators_config = require "tracker.AggregatorAPI.default_aggregators"
local types = require "tracker.types"
local utils = require "tracker.utils"


---@class PersistencyAPI
local PersistencyAPI = {}
PersistencyAPI.__index = PersistencyAPI


---@return table
function PersistencyAPI.create_storage()
    local self = setmetatable({}, PersistencyAPI)
    self:initialize()
    return self
end

function PersistencyAPI:initialize()
end

