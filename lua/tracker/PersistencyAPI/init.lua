local json = require "tracker.json"
---@class PersistencyAPI
---@field session Tracker
---@field persistence_location string
local PersistencyAPI = {}
PersistencyAPI.__index = PersistencyAPI


---@param tracker_session Tracker
---@param opts table|nil
---@return PersistencyAPI
function PersistencyAPI.create_storage(tracker_session, opts)
    local self = setmetatable({}, PersistencyAPI)
    self.session = tracker_session
    self:initialize(opts)
    return self
end

---@param opts table|nil
function PersistencyAPI:initialize(opts)
    opts = opts or {}
    self.persistence_location = opts.persistence_location or os.getenv("HOME") .. "/.config/tracker"
    self:create_persistence_folder()
end

function PersistencyAPI:create_persistence_folder()
    local dir_exists = os.execute('[ -d "' .. self.persistence_location .. '" ]')
    if dir_exists == 0 then
        print("Persistence location already exists")
        return
    end

    os.execute("mkdir " .. self.persistence_location)
    os.execute("mkdir " .. self.persistence_location .. "/data")
end

function PersistencyAPI:save_session_data_to_json_file()
    local buffers_overview = self.session.Aggregator:prepare_data_for_json_file()
    local stringified_agg = json.encode(buffers_overview)
    local file = io.open(self.persistence_location .. "/data/" .. self.session.Session.session_name .. ".json", "w") -- various modes
    if file then
        file:write(stringified_agg)
        return file:read()
    end
end

function PersistencyAPI:remove_session_file(filepath)
    local file_exists = os.execute('[ -f "' .. filepath .. '" ]')
    if file_exists ~= 0 then
        print("File does not exists")
        return
    end

    pcall(os.execute, "rm " .. filepath)
end

return PersistencyAPI
