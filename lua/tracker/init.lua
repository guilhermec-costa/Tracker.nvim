---@module "tracker"
local TrackerAPI = require "tracker.TrackerAPI"
local EventsAPI = require "tracker.EventsAPI"
require "tracker.commands"

local Tracker = {}

function Tracker.setup(opts)
    opts = opts or {}
    Tracker.TrackerSession = TrackerAPI.new(opts)
    if opts.start_timer_on_launch then
        Tracker.TrackerSession:start_timer()
    end

    -- dependency injection
    local Event_Manager = EventsAPI.new(Tracker.TrackerSession)
    Event_Manager:activate_events(Tracker.TrackerSession.events)
end

return Tracker
