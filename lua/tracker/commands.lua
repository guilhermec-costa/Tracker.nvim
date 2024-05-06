local utils = require "tracker.utils"
local commands = {}
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local function get_session_aggregators(opts)
    local args = opts.args or nil
    local splitted_paths = utils.split_string(args, " ")
    if #splitted_paths > 0 then
        local accessors_path_string = ""
        for i, arg in ipairs(splitted_paths) do
            accessors_path_string = accessors_path_string .. "['" .. splitted_paths[i] .. "']"
        end
        local command = "lua P(require('tracker').Aggregator:get_aggregators().session_scoped.buffers.aggregators" ..
            accessors_path_string .. ")"
        local cmd_status, _ = pcall(vim.api.nvim_command, command)
    else
        local command = "lua P(require('tracker').Aggregator:get_aggregators().session_scoped.buffers.aggregators)"
        local cmd_status, _ = pcall(vim.api.nvim_command, command)
    end
end

local tracker_commands = {
    TrackerPauseTimer = { action = "lua require('tracker').Session:pause_timer()" },
    TrackerStartTimer = { action = "lua require('tracker').Session:start_timer()" },
    TrackerResumeTimer = { action = "lua require('tracker').Session:resume_timer()" },
    TrackerResetTimer = { action = "lua require('tracker').Session:reset_timer()" },
    TrackerGetSessionAggregators = { action = get_session_aggregators, opts = { nargs = "?" } },
    TrackerGetActiveEvents = { action = "lua P(require('tracker').Session:get_active_events())" },
    TrackerGetInactiveEvents = { action = "lua P(require('tracker').Session:get_inactive_events())" },
    TrackerGetBuffers = { action = "lua P(require('tracker').Aggregator:get_buffers())" },
    TrackerBuffersKeystrokes = { action = "lua P(require('tracker').Aggregator:keystrokes_by_buffer())" },
    TrackerBuffersTime = { action = "lua P(require('tracker').Aggregator:time_by_buffer())" },
    TrackerBuffersCounter = { action = "lua P(require('tracker').Aggregator:counter_by_buffer())" },
    TrackerBuffersYanks = { action = "lua P(require('tracker').Aggregator:yanks_by_buffer())" },
    TrackerBuffersOverview = { action = "lua P(require('tracker').Aggregator:overview_by_buffer())" },
    TrackerSessionOverview = { action = "lua P(require('tracker').Aggregator:session_overview())" },
}


commands.trigger_tracker_commands = function(opts)
    opts = opts or {}
    local results = {}
    for cmd_name, _ in pairs(tracker_commands) do
        table.insert(results, cmd_name)
    end
    pickers.new(opts, {
        prompt_title = "Tracker Commands",
        finder = finders.new_table {
            results = results
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.api.nvim_command(tracker_commands[selection[1]].action)
            end)
            return true
        end,
    }):find()
end



for cmd_name, action_opts in pairs(tracker_commands) do
    local extra_opts = action_opts.opts or {}
    vim.api.nvim_create_user_command(cmd_name, action_opts.action, extra_opts)
end

return commands
