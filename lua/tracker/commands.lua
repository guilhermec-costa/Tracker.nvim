local function get_inactive_events_ext()
    ---@type Tracker
    local tracker = require 'tracker'
    print(vim.inspect(tracker.Session:get_inactive_events()))
end

local function get_active_events_ext()
    ---@type Tracker
    local tracker = require 'tracker'
    print(vim.inspect(tracker.Session:get_active_events()))
end

local function save_session_data()
    ---@type Tracker
    local tracker = require 'tracker'
    tracker.Session.persistor:save_session_data_to_json_file()
end

local commands = {
    TrackerPauseTimer = { action = "lua require('tracker').Session:pause_timer()" },
    TrackerResumeTimer = { action = "lua require('tracker').Session:resume_timer()" },
    TrackerResetTimer = { action = "lua require('tracker').Session:reset_timer()" },
    TrackerGetActiveEvents = { action = get_active_events_ext },
    TrackerGetInactiveEvents = { action = get_inactive_events_ext },
    TrackerSaveSession = { action = save_session_data }
}

for cmd_name, cmd_opts in pairs(commands) do
    local extra_opts = cmd_opts.opts or {}
    vim.api.nvim_create_user_command(cmd_name, cmd_opts.action, extra_opts)
end

return commands
