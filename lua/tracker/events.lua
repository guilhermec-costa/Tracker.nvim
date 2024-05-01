local events = {}
local types = require "tracker.types"

local event_type = types.event
events.Event_Manager = function(generator_config)
    return {
        config = generator_config,
        activate_events = function(self, _events)
            for _, event in pairs(_events) do
                vim.api.nvim_create_autocmd(event.type, {
                    pattern = event.pattern,
                    group = event.group,
                    callback = event.handler,
                    desc = event.desc
                })
            end
        end,
    }
end
return events
