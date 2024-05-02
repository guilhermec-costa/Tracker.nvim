local default_aggregators_config = require "tracker.AggregatorAPI.default_aggregators"
local types = require "tracker.types"
local utils = require "tracker.utils"


---@class AggregatorAPI
---@field Data table
---@field session table
local AggregatorAPI = {}
AggregatorAPI.__index = AggregatorAPI


---@return table
function AggregatorAPI.new_aggregator()
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
    if string.find(opts.aggregator_path, "/tmp", 0) then
        return
    end

    local splitted_paths = utils.split_string(opts.aggregator_path, ".")

    local current_table = self.Data
    for i = 1, #splitted_paths do
        local key = splitted_paths[i]
        current_table[key] = current_table[key] or {}
        current_table = current_table[key]
    end

    local final_key = opts.aggregator_name or ""
    current_table[final_key] = {
        counter = 0,
        timer = 0
    }
end

return AggregatorAPI
