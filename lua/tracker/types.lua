local types = {}

--- this
---@class tracker_defaults
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
return types
