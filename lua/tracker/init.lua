---@module "tracker"
local utils = require "tracker.utils"
local events = require "tracker.events"
local event_handlers = require "tracker.event_handlers"
local tracker = {}

tracker.defaults = utils.generate_tracker_default_values()

local event_generator = events.Event_Generator({ name = "generator" })
local events_group = vim.api.nvim_create_augroup("Events", { clear = true })

event_generator.generate_event({
    pattern = "*",
    desc = "When entering buffer",
    type = "BufEnter",
    group = events_group,
    handler = event_handlers.handle_buf_enter
})

P(tracker)
return tracker
