---@module "default_events_config"

local events_group = vim.api.nvim_create_augroup("Events", { clear = true })
local event_handlers = require "tracker.event_handlers"

return {
    events = {
        EnterBuffer = {
            pattern = "*",
            desc = "When enters a buffer",
            type = "BufEnter",
            group = events_group,
            handler = event_handlers.handle_buf_enter
        }
    }
}
