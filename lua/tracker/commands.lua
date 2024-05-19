local P = require "tracker.utils".P

---@return Tracker
local function get_tracker_session()
    ---@type Tracker
    local tracker = require 'tracker'
    return tracker
end

local function get_inactive_events_ext()
    P(get_tracker_session().Session:get_inactive_events())
end

local function clear_dashboard_files()
    get_tracker_session().Session.persistor:clear_dashboard_files()
end

local function overview_by_filetype()
    P(get_tracker_session().Aggregator:overview_by_filetype())
end

local function overview_by_filepath()
    P(get_tracker_session().Aggregator:overview_by_buffer())
end

local function project_overview()
    P(get_tracker_session().Aggregator:project_overview())
end

local function get_active_events_ext()
    ---@type Tracker
    P(get_tracker_session().Session:get_active_events())
end

local function save_session_data()
    get_tracker_session().Session.persistor:save_session_data_to_json_file()
end

local function pause_timer()
    get_tracker_session().Session:pause_timer()
end

local function resume_timer()
    get_tracker_session().Session:resume_timer()
end

local function reset_timer()
    get_tracker_session().Session:reset_timer()
end

local function clear_session_files()
    get_tracker_session().Session.persistor:clear_session_files()
end

local function clear_log_files()
    get_tracker_session().Session.persistor:clear_log_files()
end

local commands = {
    TrackerPauseTimer = { action = pause_timer },
    TrackerResumeTimer = { action = resume_timer },
    TrackerResetTimer = { action = reset_timer },
    TrackerGetActiveEvents = { action = get_active_events_ext },
    TrackerSaveSession = { action = save_session_data },
    TrackerClearSessionFiles = { action = clear_session_files },
    TrackerClearLogFiles = { action = clear_log_files },
    TrackerFilepathOverview = { action = overview_by_filepath },
    TrackerFiletypeOverview = { action = overview_by_filetype },
    TrackerProjectOverview = { action = project_overview },
    TrackerClearDashboardFiles = { action = clear_dashboard_files }
}

for cmd_name, cmd_opts in pairs(commands) do
    local extra_opts = cmd_opts.opts or {}
    vim.api.nvim_create_user_command(cmd_name, cmd_opts.action, extra_opts)
end

return commands
