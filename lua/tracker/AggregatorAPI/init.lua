local default_aggregators_config = require "tracker.AggregatorAPI.default_aggregators"
local types = require "tracker.types"
local utils = require "tracker.utils"


---@class AggregatorAPI
---@field Data table
---@field Session table
local AggregatorAPI = {}
AggregatorAPI.__index = AggregatorAPI


---@return table
function AggregatorAPI.new_aggregator(session)
    local self = setmetatable({}, AggregatorAPI)
    self.Session = session
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
    self.Data.session_scoped.buffers.aggregators.counter = 0
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
    current_table[final_key] = {}
end

function AggregatorAPI:remove_aggregator(aggregator_path)
    local splitted_paths = utils.split_string(aggregator_path, ".")
    local current_table = self.Data
    for i = 1, #splitted_paths - 1 do
        local key = splitted_paths[i]
        current_table[key] = current_table[key] or {}
        current_table = current_table[key]
    end

    local final_key = splitted_paths[#splitted_paths] or nil
    if final_key then
        current_table[final_key] = nil
    end
end

function AggregatorAPI:get_aggregators()
    return self.Data
end

function AggregatorAPI:get_buffers()
    local output = {}
    local filepath_aggregator = self.Data.session_scoped.buffers.aggregators.filepath
    for key, info in pairs(filepath_aggregator) do
        if key ~= "timer" and key ~= "counter" then
            table.insert(output, info.metadata.name)
        end
    end
    return output
end

function AggregatorAPI:__extract_information_from_buf(aggregator_key)
    local output = {}
    local filepath_aggregator = self.Data.session_scoped.buffers.aggregators.filepath
    for key, info in pairs(filepath_aggregator) do
        if key ~= "timer" and key ~= "counter" then
            output[info.metadata.name] = info[aggregator_key]
        end
    end
    return output
end

function AggregatorAPI:keystrokes_by_buffer()
    return self:__extract_information_from_buf("keystrokes")
end

function AggregatorAPI:time_by_buffer()
    return self:__extract_information_from_buf("timer")
end

function AggregatorAPI:counter_by_buffer()
    return self:__extract_information_from_buf("counter")
end

function AggregatorAPI:yanks_by_buffer()
    return self:__extract_information_from_buf("yanked")
end

function AggregatorAPI:saves_by_buffer()
    return self:__extract_information_from_buf("saved")
end

function AggregatorAPI:overview_by_buffer()
    local output = {}
    local filepath_aggregator = self.Data.session_scoped.buffers.aggregators.filepath
    for key, info in pairs(filepath_aggregator) do
        if key ~= "timer" and key ~= "counter" then
            output[info.metadata.name] = {
                timer = info.timer,
                counter = info.counter,
                keystrokes = info.keystrokes,
                yanked = info.yanked,
                saved = info.saved
            }
        end
    end

    return output
end

function AggregatorAPI:session_overview()
    local output = {}
    local buffer_aggregator = self.Data.session_scoped.buffers.aggregators
    output.keystrokes = buffer_aggregator.keystrokes
    output.timer = self.Session.Session.runned_for
    output.counter = buffer_aggregator.counter
    output.yanked = buffer_aggregator.yanked
    output.saved = buffer_aggregator.saved
    output.cmd_mode = buffer_aggregator.cmd_mode
    output.insert_enter = buffer_aggregator.insert_enter

    return output
end

return AggregatorAPI
