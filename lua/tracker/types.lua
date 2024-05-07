local types = {}

types.tracker_defaults = {
    session_id = nil,
    start_time = nil
}

---@class event
types.event = {
    desc = nil,
    type = nil,
    group = nil,
    pattern = nil,
    handler = nil
}

---@class New_Aggregator
types.new_aggregator = {
    aggregator_name = nil,
    aggregator_path = nil
}

---@class Session_overview
types.Session_overview = {
    keystrokes = nil,
    timer = nil,
    counter = nil,
    yanked = nil,
    saved = nil,
    cmd_mode = nil,
    insert_enter = nil,
}


return types
