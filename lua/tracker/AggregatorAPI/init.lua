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
        current_table[key] = current_table[key] or 0

        if current_table[key] == nil then
            print("key \"" .. key .. "\" does not exist")
            return 0
        end

        current_table = current_table[key]
    end

    local final_key = splitted_paths[#splitted_paths] or 0
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
    local session_duration = self.Session.Session.runned_for
    local project_aggregator = self.Data.session_scoped.buffers.aggregators.project
    local filepath_aggregator = self.Data.session_scoped.buffers.aggregators.filepath
    for _, buffer in pairs(filepath_aggregator) do
        output[buffer.metadata.name] = {
            timer = {
                value = buffer.timer,
                ["%"] = utils.calculate_field_percentage(buffer.timer, session_duration)
            },
            counter = {
                value = buffer.counter,
                ["%"] = utils.calculate_field_percentage(buffer.counter, project_aggregator.counter)
            },
            keystrokes = {
                value = buffer.keystrokes,
                ["%"] = utils.calculate_field_percentage(buffer.keystrokes, project_aggregator.keystrokes)
            },
            yanked = {
                value = buffer.yanked,
                ["%"] = utils.calculate_field_percentage(buffer.yanked, project_aggregator.yanked)
            },
            saved = {
                value = buffer.saved,
                ["%"] = utils.calculate_field_percentage(buffer.saved, project_aggregator.saved)
            },
            mode_change = {
                value = buffer.mode_change.value,
                by_mode = buffer.mode_change.by_mode,
                ["%"] = utils.calculate_field_percentage(buffer.mode_change.value, project_aggregator.mode_change.value)
            },
            recorded_macros = {
                value = buffer.recorded_macros,
                ["%"] = utils.calculate_field_percentage(buffer.recorded_macros, project_aggregator.recorded_macros)
            },
            chars = buffer.chars
        }
    end

    return output
end

---@return table<string, table<string, number>>
function AggregatorAPI:overview_by_filetype()
    local session_duration = self.Session.Session.runned_for
    local project_aggregator = self.Data.session_scoped.buffers.aggregators.project
    local output = {}
    local filetype_aggregator = self.Data.session_scoped.buffers.aggregators.filetype
    for filetype, values in pairs(filetype_aggregator) do
        output[filetype] = {
            timer = {
                value = values.timer,
                ["%"] = utils.calculate_field_percentage(values.timer, session_duration)
            },
            counter = {
                value = values.counter,
                ["%"] = utils.calculate_field_percentage(values.counter, project_aggregator.counter)
            },
            keystrokes = {
                value = values.keystrokes,
                ["%"] = utils.calculate_field_percentage(values.keystrokes, project_aggregator.keystrokes)
            },
            yanked = {
                value = values.yanked,
                ["%"] = utils.calculate_field_percentage(values.yanked, project_aggregator.yanked)
            },
            saved = {
                value = values.saved,
                ["%"] = utils.calculate_field_percentage(values.saved, project_aggregator.saved)
            },
            mode_change = {
                value = values.mode_change.value,
                by_mode = values.mode_change.by_mode,
                ["%"] = utils.calculate_field_percentage(values.mode_change.value, project_aggregator.mode_change.value)
            },
            recorded_macros = {
                value = values.recorded_macros,
                ["%"] = utils.calculate_field_percentage(values.recorded_macros, project_aggregator.recorded_macros)
            },
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
    output.name = project_aggregator.name
    output.new_file = project_aggregator.new_file
    output.keystrokes = project_aggregator.keystrokes
    output.timer = self.Session.Session.runned_for
    output.counter = project_aggregator.counter
    output.recorded_macros = project_aggregator.recorded_macros
    output.buffers_deleted = project_aggregator.buffers_deleted
    output.buffers_added = project_aggregator.buffers_added
    output.yanked = project_aggregator.yanked
    output.saved = project_aggregator.saved
    output.colorscheme_change = project_aggregator.colorscheme_change
    output.mode_change = project_aggregator.mode_change

    return output
end

function AggregatorAPI:prepare_data_for_json_file()
    local output = {}

    output.session_id = self.Session.Session.session_id
    output.session_name = self.Session.Session.session_name
    output.session_duration = self.Session.Session.runned_for
    output.will_be_deleted_on = self.Session.Session.will_be_deleted_on
    output.saved_at = os.date("%c")
    output["project"] = self:project_overview()
    output["filepath"] = self:overview_by_buffer()
    output["filetype"] = self:overview_by_filetype()

    return output
end

return AggregatorAPI
