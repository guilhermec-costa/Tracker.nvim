local TrackerAPI = require "tracker.TrackerAPI"
local EventsAPI = require "tracker.EventsAPI"
local AggregatorAPI = require "tracker.AggregatorAPI"
local PersistenceAPI = require "tracker.PersistencyAPI"

require "tracker.commands"

---@class Tracker
local Tracker = {}

function Tracker.setup(opts)
    opts = opts or {}

    ---@type TrackerAPI
    Tracker.Session = TrackerAPI.new_session(opts)

    ---@type PersistencyAPI
    Tracker.Persistence = PersistenceAPI.create_storage(Tracker)

    ---@type AggregatorAPI
    Tracker.Aggregator = AggregatorAPI.new_aggregator(Tracker)

    local Event_Manager = EventsAPI.new(Tracker)
    Event_Manager:activate_events(Tracker.Session.events)
end

return Tracker
