local utils = require "tracker.utils"
local commands = {}

local function get_session_aggregators(opts)
    local args = opts.args or nil
    local splitted_paths = utils.split_string(args, " ")
    if #splitted_paths > 0 then
        for i, arg in splitted_paths do

        end
    end
    if #splitted_paths == 1 then
        vim.api.nvim_command(
            "lua P(require('tracker').Aggregator:get_aggregators().session_scoped.buffers.aggregators['" ..
            splitted_paths[1] .. "'])")
    else
        vim.api.nvim_command(
            "lua P(require('tracker').Aggregator:get_aggregators().session_scoped.buffers.aggregators)")
    end
end

vim.api.nvim_create_user_command("TrackerPauseTimer", "lua require('tracker').Session:pause_timer()", {})
vim.api.nvim_create_user_command("TrackerResumeTimer", "lua require('tracker').Session:resume_timer()", {})
vim.api.nvim_create_user_command("TrackerStartTimer", "lua require('tracker').Session:start_timer()", {})
vim.api.nvim_create_user_command("TrackerResetTimer", "lua require('tracker').Session:reset_timer()", {})
vim.api.nvim_create_user_command("TrackerGetSessionAggregators", get_session_aggregators, { nargs = "?" })
vim.api.nvim_create_user_command("TrackerGetActiveEvents", "lua P(require('tracker').Session:get_active_events())", {})
vim.api.nvim_create_user_command("TrackerGetInactiveEvents", "lua P(require('tracker').Session:get_active_events())", {})

return commands
