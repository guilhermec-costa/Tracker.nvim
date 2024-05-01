---@module "tracker"
local TrackerAPI = require "tracker.TrackerAPI"
local Events = require "tracker.events"

local tracker = {}

function tracker.setup(opts)
    tracker.__index = TrackerAPI:new_tracker()
    local event_manager = Events.Event_Manager({ name = "generator" })
    event_manager:activate_events(tracker.__index.default_events.events)
end

return tracker
