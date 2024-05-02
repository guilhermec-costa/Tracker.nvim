local types = {}

types.tracker_defaults = {
    session_id = nil,
    start_time = nil
}

---@class Event_Type
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
return types
