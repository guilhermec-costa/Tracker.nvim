local json = require "tracker.json"
---@class PersistencyAPI
---@field session Tracker
---@field persistence_location string
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
    self.persistence_location = opts.persistence_location or os.getenv("HOME") .. "/.config/tracker"
    self:setup_persistence_structure()
end

function PersistencyAPI:setup_persistence_structure()
    local dir_exists = os.execute('[ -d "' .. self.persistence_location .. '" ]')
    local current_date = os.date("%Y_%m_%d")
    if dir_exists ~= 0 then
        os.execute("mkdir " .. self.persistence_location)
        os.execute("mkdir " .. self.persistence_location .. "/data")
    end
    local day_folder_exists = os.execute('[ -d "' .. self.persistence_location .. "/data/" .. current_date .. '" ]')
    if day_folder_exists ~= 0 then
        os.execute("mkdir " .. self.persistence_location .. "/data/" .. current_date)
    end
end

function PersistencyAPI:save_session_data_to_json_file()
    local current_date = os.date("%Y_%m_%d")
    local buffers_overview = self.session.Aggregator:prepare_data_for_json_file()
    local stringified_agg = json.encode(buffers_overview)
    local file = io.open(
    self.persistence_location .. "/data/" .. current_date .. "/" .. self.session.Session.session_name .. ".json", "w")
    if file then
        file:write(stringified_agg)
        return file:read(), 1
    end
end

function PersistencyAPI:remove_session_file(filepath)
    local file_exists = os.execute('[ -f "' .. filepath .. '" ]')
    if file_exists ~= 0 then
        print("File does not exist")
        return
    end

    pcall(os.execute, "rm " .. filepath)
end

function PersistencyAPI:start_cleaning_process()
    local limit_in_days_for_session_file_to_expire = self.session.Session.cleanup_session_files_frequency
    local session_files = io.popen("find ~/.config/tracker/data/ -type f +" ..
        tostring(limit_in_days_for_session_file_to_expire))
    if session_files ~= nil then
        for filepath in session_files:lines() do
            self:remove_session_file(filepath)
        end
    end
end

return PersistencyAPI
