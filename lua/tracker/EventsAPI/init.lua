local types = require "tracker.types"

---@class Event_Manager
---@field corresponding_session table
local Event_Manager = {}
Event_Manager.__index = Event_Manager


---@param opts table
---@return table
function Event_Manager.new(opts)
    local self = setmetatable({}, Event_Manager)
    self:initialize(opts)
    return self
end

---@param opts table
---@return nil
function Event_Manager:initialize(opts)
    self.corresponding_session = opts
end

---@param _events table
function Event_Manager:activate_events(_events)
    for name, event in pairs(_events) do
        local autocmd_id = vim.api.nvim_create_autocmd(event.type, {
            pattern = event.pattern,
            group = event.group,
            callback = function()
                event.handler(self.corresponding_session)
            end,
            desc = event.desc
        })
        _events[name].status = 1
        _events[name].id = autocmd_id
    end
end

function Event_Manager:deactivate_events(_events)
    if #_events == 0 then
        _events = { __name = _events }
    end
    for _, event in pairs(_events) do
        vim.api.nvim_del_autocmd(event.id)
        event.status = 0
    end
end

return Event_Manager
