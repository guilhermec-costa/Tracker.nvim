---@module "tracker"
local TrackerAPI = require "tracker.TrackerAPI"
local Event_Manager = require "tracker.events"
require "tracker.commands"

local Tracker = {}

function Tracker.setup(opts)
    opts = opts or {}
    local new_tracker = TrackerAPI.new(opts)
    if opts.start_timer_on_launch then
        new_tracker:start_timer()
    end
    Event_Manager:activate_events(new_tracker.events)
   Tracker.TrackerSession = new_tracker
    Event_Manager:deactivate_events(Tracker.TrackerSession.events.EnterBuffer)
end

return Tracker
