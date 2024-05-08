---@class PersistencyAPI
local PersistencyAPI = {}
PersistencyAPI.__index = PersistencyAPI


---@param opts table
---@return PersistencyAPI
function PersistencyAPI.create_storage(opts)
    local self = setmetatable({}, PersistencyAPI)
    self:initialize(opts)
    return self
end

function PersistencyAPI:initialize(opts)
    self.persistence_location = opts.persistence_location or os.getenv("HOME") .. "/.config/tracker"
    self:create_persistence_folder()
end

function PersistencyAPI:create_persistence_folder()
    local dir_exists = os.execute('[ -d "' .. self.persistence_location .. '" ]')
    if dir_exists ~= 0 then
        os.execute("mkdir " .. self.persistence_location)
        os.execute("mkdir " .. self.persistence_location .. "/data")
    end
end

return PersistencyAPI
