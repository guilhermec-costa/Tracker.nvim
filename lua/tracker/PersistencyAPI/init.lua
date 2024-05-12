local json = require "tracker.json"
---@class PersistencyAPI
---@field session Tracker
---@field persistence_location string
---@field logs_location string
---@field accumulated_logs table
local PersistencyAPI = {}
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
    self.persistence_location = opts.persistence_location or os.getenv("HOME") .. "/.config/tracker/data/"
    self.logs_location = opts.logs_location or os.getenv("HOME") .. "/.config/tracker/logs/"
    self.accumulated_logs = {}
    self:setup_persistence_structure()
end

function PersistencyAPI:setup_persistence_structure()
    local current_date = os.date("%Y_%m_%d")
    local day_folder_exists = os.execute('[ -d "' .. self.persistence_location .. current_date .. '" ]')

    if day_folder_exists ~= 0 then
        os.execute("mkdir -p " .. self.persistence_location .. current_date)
    end
    os.execute("mkdir -p " .. self.logs_location .. current_date)
end

function PersistencyAPI:save_session_data_to_json_file()
    local current_date = os.date("%Y_%m_%d")
    local buffers_overview = self.session.Aggregator:prepare_data_for_json_file()
    local stringified_agg = json.encode(buffers_overview)
    local file = io.open(
        self.persistence_location .. current_date .. "/" .. self.session.Session.session_name .. ".json", "w")

    if file then
        file:write(stringified_agg)
        return file:read(), 1
    end
end

function PersistencyAPI:remove_session_file(filepath)
    local file_exists = os.execute('[ -f "' .. filepath .. '" ]')
    if file_exists ~= 0 then
        print("File does not exist")
        return 0
    end

    pcall(os.execute, "rm " .. filepath)
    return 1
end

function PersistencyAPI:start_cleaning_process()
    local current_date = os.date("%Y_%m_%d")
    local limit_in_days_for_session_file_to_expire = self.session.Session.cleanup_session_files_frequency
    local session_files = io.popen("find " .. self.persistence_location .. current_date .. " -type f -mtime +" ..
        tostring(limit_in_days_for_session_file_to_expire))

    if session_files ~= nil then
        for filepath in session_files:lines() do
            self:remove_session_file(filepath)
        end
    end
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
        print("File does not exist")
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
end

function PersistencyAPI:create_log(message)
    table.insert(self.accumulated_logs, tostring(message))
end

function PersistencyAPI:clear_logs()
    self.accumulated_logs = {}
end

return PersistencyAPI
