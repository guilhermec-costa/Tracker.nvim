local assert = require('luassert.assert')
local describe = describe ---@diagnostic disable-line: undefined-global
local it = it ---@diagnostic disable-line: undefined-global

describe("aggregatorAPI", function()
    it("can be required", function()
        require "tracker.AggregatorAPI"
    end)

    it("can create a aggregator", function()
        local agg = require("tracker.AggregatorAPI")
        local test_table = {}
        test_table.Aggregator = agg.new_aggregator(test_table)
        test_table.Aggregator:add_aggregator({
            aggregator_name = "new_agg",
            aggregator_path = "session_scoped.buffers.aggregators.testing_aggregators"
        })

        assert.are.same({}, test_table.Aggregator.Data.session_scoped.buffers.aggregators.testing_aggregators.new_agg)
    end)

    it("can remove aggregator", function()
        local agg = require("tracker.AggregatorAPI")
        local test_table = {}
        test_table.Aggregator = agg.new_aggregator(test_table)
        test_table.Aggregator:add_aggregator({
            aggregator_name = "new_agg",
            aggregator_path = "session_scoped.buffers.aggregators.testing_aggregators"
        })

        local result_code = test_table.Aggregator:remove_aggregator(
            "session_scoped.buffers.aggregators.testing_aggregators.new_agg",
            test_table)

        assert.are.same(1, result_code)
    end)
end)
