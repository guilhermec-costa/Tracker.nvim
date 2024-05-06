local types = require "tracker.types"

---@class Event_Manager
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
    for event_name, event_cfg in pairs(_events) do
        local autocmd_id = vim.api.nvim_create_autocmd(event_cfg.type, {
            pattern = event_cfg.pattern,
            group = event_cfg.group,
            callback = function()
                pcall(event_cfg.handler, self.corresponding_session)
            end,
            desc = event_cfg.desc
        })
        _events[event_name].status = 1
        _events[event_name].id = autocmd_id
    end
end

function Event_Manager:deactivate_events(_events)
    if #_events == 0 then
        return "Error deactivating any events"
    end

    for _, event_cfg in pairs(_events) do
        vim.api.nvim_del_autocmd(event_cfg.id)
        event_cfg.status = 0
    end
end

return Event_Manager
