local types = {}

--- this
---@class tracker_defaults
types.tracker_defaults = {
    session_id = nil,
    start_time = nil
}

---@class event_generator
types.event_generator = {
    name = nil,
    group = nil,
    pattern = nil,
    handler = nil
}
return types
