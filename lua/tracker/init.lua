---@module "tracker"
local utils = require("tracker.utils")
local tracker = {}

tracker.defaults = utils.get_tracker_default_values()

P(tracker)
return tracker
