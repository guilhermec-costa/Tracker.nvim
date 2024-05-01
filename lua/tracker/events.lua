local types = require "tracker.types"

---@class Event_Manager
local Event_Manager = {}

function Event_Manager:activate_events(_events)
    for name, event in pairs(_events) do
        local autocmd_id = vim.api.nvim_create_autocmd(event.type, {
            pattern = event.pattern,
            group = event.group,
            callback = event.handler,
            desc = event.desc
        })
        _events[name].status = 1
        _events[name].id = autocmd_id
    end
end

function Event_Manager:deactivate_events(_events)
    if #_events == 0 then
        _events = { __name = _events}
    end
    for _, event in pairs(_events) do
        vim.api.nvim_del_autocmd(event.id)
        event.status = 0
    end
end

return Event_Manager
