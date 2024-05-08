local default_aggregators_config = require "tracker.AggregatorAPI.default_aggregators"
local utils = require "tracker.utils"

---@class AggregatorAPI
---@field Data table
---@field Session Tracker 
local AggregatorAPI = {}
AggregatorAPI.__index = AggregatorAPI

---@param session Tracker
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
    self.Data.session_scoped.buffers.aggregators.project.counter = 0
end

---@param opts New_Aggregator
function AggregatorAPI:add_aggregator(opts)
    if string.find(opts.aggregator_path, "/tmp") then
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

---@alias return_codes 1 | 0
---@return return_codes
function AggregatorAPI:remove_aggregator(aggregator_path)
    local splitted_paths = utils.split_string(aggregator_path, ".")
    local current_table = self.Data

    for i = 1, #splitted_paths - 1 do
        local key = splitted_paths[i]
        current_table[key] = current_table[key] or nil

        if current_table[key] == nil then
            print("key \"" .. key .. "\" does not exist")
            return 0
        end

        current_table = current_table[key]
    end

    local final_key = splitted_paths[#splitted_paths] or nil
    if current_table[final_key] == nil then
        print("final key \"" .. final_key .. "\" does not exist")
        return 0
    end

    if not final_key then
        return 0
    end

    current_table[final_key] = nil
    return 1
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

---@param aggregator_key string
---@return table<string, number>
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

---@return table<string, number>
function AggregatorAPI:keystrokes_by_buffer()
    return self:__extract_information_from_buf("keystrokes")
end

---@return table<string, number>
function AggregatorAPI:time_by_buffer()
    return self:__extract_information_from_buf("timer")
end

---@return table<string, number>
function AggregatorAPI:counter_by_buffer()
    return self:__extract_information_from_buf("counter")
end

---@return table<string, number>
function AggregatorAPI:yanks_by_buffer()
    return self:__extract_information_from_buf("yanked")
end

---@return table<string, number>
function AggregatorAPI:saves_by_buffer()
    return self:__extract_information_from_buf("saved")
end

---@return table<string, table<string, number>>
function AggregatorAPI:overview_by_buffer()
    local output = {}
    local filepath_aggregator = self.Data.session_scoped.buffers.aggregators.filepath
    for _, buffer in pairs(filepath_aggregator) do
        output[buffer.metadata.name] = {
            timer = buffer.timer,
            counter = buffer.counter,
            keystrokes = buffer.keystrokes,
            yanked = buffer.yanked,
            saved = buffer.saved,
            cmd_mode = buffer.cmd_mode,
            insert_mode = buffer.insert_mode,
            chars = buffer.chars
        }
    end

    return output
end

---@return table<string, table<string, number>>
function AggregatorAPI:overview_by_filetype()
    local output = {}
    local filetype_aggregator = self.Data.session_scoped.buffers.aggregators.filetype
    for filetype, values in pairs(filetype_aggregator) do
        output[filetype] = {
            timer = values.timer,
            counter = values.counter,
            keystrokes = values.keystrokes,
            yanked = values.yanked,
            saved = values.saved,
            cmd_mode = values.cmd_mode,
            insert_mode = values.insert_mode,
            chars = values.chars
        }
    end

    return output
end

---  Get every data related to the project scope. It englobes both buffer and filetype scopes
---@return Session_overview
function AggregatorAPI:project_overview()
    ---@class Session_overview
    local output = {}

    local project_aggregator = self.Data.session_scoped.buffers.aggregators.project
    output.keystrokes = project_aggregator.keystrokes
    output.timer = self.Session.Session.runned_for
    output.counter = project_aggregator.counter
    output.yanked = project_aggregator.yanked
    output.saved = project_aggregator.saved
    output.cmd_mode = project_aggregator.cmd_mode
    output.insert_enter = project_aggregator.insert_enter

    return output
end

function AggregatorAPI:prepare_data_for_json_file()
    local output = {}

    output.session_id = self.Session.Session.session_id
    output.session_name = self.Session.Session.session_name
    output.session_duration = self.Session.Session.runned_for
    output["project"] = self:project_overview()
    output["filepath"] = self:overview_by_buffer()
    output["filetype"] = self:overview_by_filetype()

    return output
end

return AggregatorAPI
