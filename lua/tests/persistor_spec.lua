local TrackerAPI = require "tracker.TrackerAPI"
local AggregatorAPI = require "tracker.AggregatorAPI"
local PersistenceAPI = require "tracker.PersistencyAPI"
local assert = require('luassert.assert')
local describe = describe ---@diagnostic disable-line: undefined-global
local it = it ---@diagnostic disable-line: undefined-global

local opts = {}
local Tracker = {}
Tracker.Session = TrackerAPI.new_session(opts)

---@type AggregatorAPI
Tracker.Aggregator = AggregatorAPI.new_aggregator(Tracker)

---@type PersistencyAPI
Tracker.Session.persistor = PersistenceAPI.new_persistor(Tracker, {
    persistence_location = "/home/guichina/.config/tracker/test/"
})

describe("persistor", function()
    it("can save session file", function()
        local _, save_result_code = Tracker.Session.persistor:save_session_data_to_json_file()
        assert.are.same(1, save_result_code)
    end)

    it("can delete session file", function()
        local current_date = os.date("%Y_%m_%d")
        local filepath_to_delete = Tracker.Session.persistor.persistence_location ..
        current_date .. "/" .. Tracker.Session.session_name .. ".json"
        local save_result_code = Tracker.Session.persistor:remove_session_file(filepath_to_delete)
        assert.are.same(1, save_result_code)
    end)
end)
---@type TrackerAPI
