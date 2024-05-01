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
        },
        LeaveBuffer = {
            pattern = "*",
            desc = "When leaves a buffer",
            type = "BufLeave",
            group = events_group,
            handler = event_handlers.handle_buf_leave
        },
        OnYank = {
            pattern = "*",
            desc = "When text is yanked",
            type = "TextYankPost",
            group = events_group,
            handler = event_handlers.handle_text_yank
        }
    }
}
