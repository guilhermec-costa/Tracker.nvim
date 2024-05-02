---@module "tracker"
local TrackerAPI = require "tracker.TrackerAPI"
local EventsAPI = require "tracker.EventsAPI"
local AggregatorAPI = require "tracker.AggregatorAPI"
require "tracker.commands"

local Tracker = {}

function Tracker.setup(opts)
    opts = opts or {}
    Tracker.Session = TrackerAPI.new_session(opts)
    if opts.start_timer_on_launch then
        Tracker.Session:start_timer(opts.timer_debounce)
    end

    -- dependency injection
    Tracker.Aggregator = AggregatorAPI.new_aggregator(Tracker)
    local Event_Manager = EventsAPI.new(Tracker)
    Event_Manager:activate_events(Tracker.Session.events)
end

return Tracker
