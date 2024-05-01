---@module "tracker"
local TrackerAPI = require "tracker.TrackerAPI"
local Event_Manager = require "tracker.events"

local Tracker = {}

function Tracker.setup(opts)
    local new_tracker = TrackerAPI.new()
    Event_Manager:activate_events(new_tracker.events)
    Tracker.TrackerSession = new_tracker
end

return Tracker
