---@module "tracker"
local utils = require "tracker.utils"
local events = require "tracker.events"
local event_handlers = require "tracker.event_handlers"
local default_events_config = require "tracker.default_events_config"
local tracker = {}

tracker.defaults = utils.generate_tracker_default_values()
tracker.defaults.events = utils.generate_tracker_default_events(default_events_config)


P(tracker)
return tracker
