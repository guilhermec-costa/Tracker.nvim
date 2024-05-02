---@module "tracker"
local TrackerAPI = require "tracker.TrackerAPI"
local EventsAPI = require "tracker.EventsAPI"
require "tracker.commands"

local Tracker = {
    Session = {},
    Data = {}
}

function Tracker.setup(opts)
    opts = opts or {}
    Tracker.Session = TrackerAPI.new(opts)
    if opts.start_timer_on_launch then
        Tracker.Session:start_timer()
    end

    -- dependency injection
    local Event_Manager = EventsAPI.new(Tracker.Session)
    Event_Manager:activate_events(Tracker.Session.events)
end

return Tracker
