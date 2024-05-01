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

function Tracker.get_active_events()
    local active_events = {}
    for event_name, event_metadata in pairs(Tracker.TrackerSession.events) do
        if event_metadata.status == 1 then
            table.insert(active_events, event_metadata)
        end
    end
    return active_events
end

function Tracker.get_inactive_events()
    local inactive_events = {}
    for event_name, event_metadata in pairs(Tracker.TrackerSession.events) do
        if event_metadata.status == 0 then
            table.insert(inactive_events, event_metadata)
        end
    end
    return inactive_events
end

return Tracker
