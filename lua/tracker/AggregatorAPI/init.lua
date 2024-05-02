local default_aggregators_config = require "tracker.AggregatorAPI.default_aggregators"
local types = require "tracker.types"
local utils = require "tracker.utils"


---@class AggregatorAPI
---@field Data table
local AggregatorAPI = {}
AggregatorAPI.__index = AggregatorAPI


---@return table
function AggregatorAPI.new_aggregator(session)
    local self = setmetatable({}, AggregatorAPI)
    self.Data = {}
    self:initialize()
    return self
end

function AggregatorAPI:initialize()
    for _, agg in pairs(default_aggregators_config) do
        self:add_aggregator({
            aggregator_name = agg.aggregator_name,
            aggregator_path = agg.aggregator_path
        })
    end
end

---@param opts New_Aggregator
function AggregatorAPI:add_aggregator(opts)
    local splitted_paths = utils.split_string(opts.aggregator_path, ".")

    local current_table = self.Data
    for i = 1, #splitted_paths do
        local key = splitted_paths[i]
        current_table[key] = current_table[key] or {}
        current_table = current_table[key]
    end

    local final_key = opts.aggregator_name or ""
    current_table[final_key] = {
        root = 0,
        counter = 0
    }
end

return AggregatorAPI
