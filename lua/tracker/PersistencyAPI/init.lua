local json = require "tracker.json"

---@class PersistencyAPI
---@field session Tracker
---@field persistence_location string
---@field logs_location string
---@field accumulated_logs table
---@field last_telescope_session_entry string
---@field dashboard_files table<string,nil>
---@field selected_day_folders table
---@field logs_permission boolean
local PersistencyAPI = {}
local log_date_format = "%Y/%m/%d %H:%M:%S"
PersistencyAPI.__index = PersistencyAPI

---@param tracker_session Tracker
---@param opts table|nil
---@return PersistencyAPI
function PersistencyAPI.new_persistor(tracker_session, opts)
    local self = setmetatable({}, PersistencyAPI)
    self.session = tracker_session
    self:initialize(opts)
    return self
end

---@param opts table|nil
function PersistencyAPI:initialize(opts)
    opts = opts or {}
    if opts.persistence_location then
        self.persistence_location = opts.persistence_location .. "data/"
        self.logs_location = opts.persistence_location .. "logs/"
    else
        self.persistence_location = os.getenv("HOME") .. "/.config/tracker/data/"
        self.logs_location = os.getenv("HOME") .. "/.config/tracker/logs/"
    end

    self.logs_permission = self.session.Session.logs_permission or false
    self.accumulated_logs = {}
    self.last_telescope_session_entry = nil
    self.dashboard_files = {}
    self.selected_day_folders = {}
    self:setup_persistence_structure()
end

function PersistencyAPI:setup_persistence_structure()
    self:create_log(self.session.Session:get_tracker_ascii())
    local current_date = os.date("%Y_%m_%d")
    local day_folder_exists = os.execute('[ -d "' .. self.persistence_location .. current_date .. '" ]')

    if day_folder_exists ~= 0 then
        os.execute("mkdir -p " .. self.persistence_location .. current_date)
        self:create_log('Session persistence folder created at "' ..
            self.persistence_location .. current_date .. '" on ' .. os.date(log_date_format))
    end
    os.execute("mkdir -p " .. self.logs_location .. current_date)
    self:create_log('Logs persistence folder created at "' ..
        self.logs_location .. current_date .. '" on ' .. os.date(log_date_format))
end

function PersistencyAPI:save_session_data_to_json_file()
    local current_date = os.date("%Y_%m_%d")
    local buffers_overview = self.session.Aggregator:prepare_data_for_json_file()
    local stringified_agg = json.encode(buffers_overview)
    local file, err_message, err_number = io.open(
        self.persistence_location .. current_date .. "/" .. self.session.Session.session_name .. ".json", "w")

    if file then
        file:write(stringified_agg)
        self:create_log('Session file from Tracker session "' ..
            self.session.Session.session_name .. '" has been saved on ' .. os.date(log_date_format))
        self:persist_logs()
        self:clear_logs()
        return file:read(), 1
    end
end

function PersistencyAPI:remove_session_file(filepath)
    local file_exists = os.execute('[ -f "' .. filepath .. '" ]')
    if file_exists ~= 0 then
        self:create_log('File "' .. filepath .. '" does not exist')
        return 0
    end

    pcall(os.execute, "rm " .. filepath)
    self:create_log(filepath .. "has been deleted on " .. os.date(log_date_format))
    return 1
end

function PersistencyAPI:clear_session_files()
    local current_date = os.date("%Y_%m_%d")
    local session_files = io.popen("find " .. self.persistence_location .. current_date .. "/")
    if session_files ~= nil then
        for filepath in session_files:lines() do
            self:remove_session_file(filepath)
        end
    end
end

function PersistencyAPI:clear_log_files()
    local current_date = os.date("%Y_%m_%d")
    local session_files = io.popen("find " .. self.logs_location .. current_date .. "/")
    if session_files ~= nil then
        for filepath in session_files:lines() do
            self:remove_session_file(filepath)
        end
    end
end

function PersistencyAPI:clear_session_files_based_on_time_deletion()
    local current_date = os.date("%Y_%m_%d")
    local limit_in_days_for_session_files_to_expire = self.session.Session.cleanup_session_files_frequency or 0
    local session_files = io.popen("find " .. self.persistence_location .. current_date .. " -type f -mtime +" ..
        tostring(limit_in_days_for_session_files_to_expire))
    if session_files ~= nil then
        for filepath in session_files:lines() do
            self:remove_session_file(filepath)
        end
        self:create_log('Session files created ' ..
            tostring(limit_in_days_for_session_files_to_expire) .. '+ ago were deleted from filesystem')
    end
end

function PersistencyAPI:clear_log_files_based_on_time_deletion()
    local current_date = os.date("%Y_%m_%d")
    local limit_in_days_for_log_files_to_expire = self.session.Session.cleanup_log_files_frequency or 0
    local logs_files = io.popen("find " .. self.logs_location .. current_date .. " -type f -mtime +" ..
        tostring(limit_in_days_for_log_files_to_expire))
    if logs_files ~= nil then
        for filepath in logs_files:lines() do
            self:remove_session_file(filepath)
        end
        self:create_log('Log files created ' ..
            tostring(limit_in_days_for_log_files_to_expire) .. '+ ago were deleted from filesystem')
    end
end

function PersistencyAPI:start_cleaning_process()
    self:clear_session_files_based_on_time_deletion()
    self:clear_log_files_based_on_time_deletion()
end

---@param filepath string
---@return string|nil
function PersistencyAPI:get_session_data_from_file(filepath)
    local file = os.execute('[ -f "' .. filepath .. '" ]')
    if file ~= nil then
        local _ = io.input(filepath)
        local file_content = io.read("l")
        return file_content
    else
        self:create_log('Tryed to get data from session file of session "' ..
            self.session.Session.session_name .. '", but failed on ' .. os.date(log_date_format))
    end
end

function PersistencyAPI:persist_logs()
    local current_date = os.date("%Y_%m_%d")
    local file = io.open(
        self.logs_location .. current_date .. "/" .. self.session.Session.session_name .. "_logs.txt", "a")

    if file == nil or #self.accumulated_logs == 0 then
        return
    end

    for _, line in ipairs(self.accumulated_logs) do
        file:write(line .. "\n")
    end
    file:close()
    self:create_log('Logs from session "' ..
        self.session.Session.session_name .. '" were persisted on ' .. os.date(log_date_format))
end

---@param message string
function PersistencyAPI:create_log(message)
    if self.logs_permission then
        table.insert(self.accumulated_logs, tostring(message))
    end
end

function PersistencyAPI:clear_logs()
    self.accumulated_logs = {}
    self:create_log('Internal logs from session "' ..
        self.session.Session.session_name .. '" were cleaned on ' .. os.date(log_date_format))
end

function PersistencyAPI:get_formmated_dashboard_files()
    local formmatated_filenames = {}
    for filename, _ in pairs(self.dashboard_files) do
        table.insert(formmatated_filenames, filename)
    end
    return formmatated_filenames
end

function PersistencyAPI:clear_dashboard_files()
    self.dashboard_files = {}
    self:create_log("Dashboard files were removed from list")
    self.session.Session:notify("Dashboard files cleaned", "info")
end

return PersistencyAPI
