local events = {}
local types = require "tracker.types"

---@class Event_Manager
local Event_Manager = {}

function Event_Manager:active_events(_events)
    for name, event in pairs(_events) do
        local autocmd_id = vim.api.nvim_create_autocmd(event.type, {
            pattern = event.pattern,
            group = event.group,
            callback = event.handler,
            desc = event.desc
        })
        name[autocmd_id] = autocmd_id
    end
end

--[[ function Event_Manager:deactivate_events(_events) ]]
--[[         vim.api.(event.type, { ]]
--[[ end ]]

local event_type = types.event
events.Event_Manager = function(generator_config)
    return {
        config = generator_config,
        activate_events = function(self, _events)
        end,
    }
end
return events
