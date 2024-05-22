local TrackerAPI = require "tracker.TrackerAPI"
local EventsAPI = require "tracker.EventsAPI"
local AggregatorAPI = require "tracker.AggregatorAPI"
local PersistenceAPI = require "tracker.PersistencyAPI"
local log_date_format = "%Y/%m/%d %H:%M:%S"
local types = require "tracker.types"

require "tracker.commands"

---@class Tracker
local Tracker = {}

---@param opts userconfig
function Tracker.setup(opts)
    local userconfig = opts or {}

    ---@type TrackerAPI|nil
    Tracker.Session = TrackerAPI.new_session(userconfig)

    ---@type AggregatorAPI
    Tracker.Aggregator = AggregatorAPI.new_aggregator(Tracker)

    ---@type PersistencyAPI
    Tracker.Session.persistor = PersistenceAPI.new_persistor(Tracker, userconfig)
    Tracker.Session.persistor:create_log("TrackerAPIs have been initialized on " .. os.date(log_date_format))

    Tracker.Session.persistor:start_cleaning_process()
    Tracker.Session.persistor:create_log("Cleaning process has been finished on " .. os.date(log_date_format))


    local Event_Manager = EventsAPI.new(Tracker)
    Event_Manager:activate_events(Tracker.Session.events)
end

return Tracker
