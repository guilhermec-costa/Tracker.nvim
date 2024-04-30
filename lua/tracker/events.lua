local events = {}
local types = require "tracker.types"

local event_type = types.event
events.Event_Generator = function(generator_config)
    return {
        config = generator_config,
        ---@param opts event 
        generate_event = function(opts)
            vim.api.nvim_create_autocmd(opts.type, {
                pattern = opts.pattern,
                group = opts.group,
                callback = opts.handler,
                desc = opts.desc
            })
        end
    }
end
return events
