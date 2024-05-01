---@module "tracker"
local TrackerAPI = require "tracker.Tracker"
local Events = require "tracker.events"

local new_tracker = TrackerAPI:new_tracker()
local event_manager = Events.Event_Manager({ name = "generator" })
event_manager:activate_events(new_tracker.default_events.events)
return new_tracker
