local TrackerAPI = require "tracker.TrackerAPI"
local AggregatorAPI = require "tracker.AggregatorAPI"
local PersistenceAPI = require "tracker.PersistencyAPI"
local assert = require('luassert.assert')
local describe = describe ---@diagnostic disable-line: undefined-global
local it = it ---@diagnostic disable-line: undefined-global

describe("persistor", function()
    it("can save session data", function()
        local Tracker = {}
        local opts = {}
        Tracker.Session = TrackerAPI.new_session(opts)

        ---@type AggregatorAPI
        Tracker.Aggregator = AggregatorAPI.new_aggregator(Tracker)

        local _, save_result_code = PersistenceAPI.new_persistor(Tracker):save_session_data_to_json_file()
        assert.are.same(1, save_result_code)
    end)
end)
---@type TrackerAPI
