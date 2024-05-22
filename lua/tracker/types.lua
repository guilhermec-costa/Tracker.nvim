local types = {}

---@class event
types.event = {
    ---@type string
    desc = nil,
    ---@type string
    type = nil,
    ---@type integer
    group = nil,
    ---@type string
    pattern = nil,
    ---@type fun(data: Tracker)
    handler = nil
}

---@class New_Aggregator
types.new_aggregator = {
    ---@type string
    aggregator_name = nil,
    ---@type string
    aggregator_path = nil
}

---@class Session_overview
types.Session_overview = {
    ---@type integer
    keystrokes = nil,
    ---@type integer
    timer = nil,
    ---@type integer
    counter = nil,
    ---@type integer
    yanked = nil,
    ---@type integer
    saved = nil,
    ---@type integer
    cmd_mode = nil,
    ---@type integer
    insert_enter = nil,
}

---@class userconfig
types.userconfig = {
    ---@type integer
    timer_delay = nil,
    ---@type boolean
    allow_notifications = nil,
    ---@type boolean
    logs_permission = nil,
    ---@type boolean
    cleanup_session_files_on_session_end = nil,
    ---@type boolean
    cleanup_log_files_on_session_end = nil,
    --@type string
    persistence_location = nil
}

---@class tracker_defaults
types.tracker_defaults = {
    ---@type integer
    start_timestamp = nil,
    ---@type string
    session_id = nil,
    ---@type string
    session_name = nil,
    ---@type string
    will_be_deleted_on = nil
}

return types
