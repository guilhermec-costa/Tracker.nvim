local TrackerAPI = require "tracker.TrackerAPI"
local EventsAPI = require "tracker.EventsAPI"
local AggregatorAPI = require "tracker.AggregatorAPI"
local PersistenceAPI = require "tracker.PersistencyAPI"
local log_date_format = "%Y/%m/%d %H:%M:%S"

require "tracker.commands"

---@class Tracker
local Tracker = {}

function Tracker.setup(opts)
    opts = opts or {}

    ---@type TrackerAPI|nil
    Tracker.Session = TrackerAPI.new_session(opts)

    ---@type AggregatorAPI
    Tracker.Aggregator = AggregatorAPI.new_aggregator(Tracker)

    ---@type PersistencyAPI
    Tracker.Session.persistor = PersistenceAPI.new_persistor(Tracker, opts)
    Tracker.Session.persistor:create_log("TrackerAPIs have been initialized on " .. os.date(log_date_format))

    Tracker.Session.persistor:start_cleaning_process()
    Tracker.Session.persistor:create_log("Cleaning process has been finished on " .. os.date(log_date_format))


    local Event_Manager = EventsAPI.new(Tracker)
    Event_Manager:activate_events(Tracker.Session.events)
    Tracker.Session.persistor:create_log("Tracker events have been activated on " .. os.date(log_date_format))
end

return Tracker
