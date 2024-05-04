---@module "default_events_config"

local events_group = vim.api.nvim_create_augroup("Events", { clear = true })
local event_handlers = require "tracker.EventsAPI.event_handlers"

return {
    OnEnterBuffer = {
        pattern = "*",
        desc = "When enters a buffer",
        type = "BufEnter",
        group = events_group,
        handler = event_handlers.handle_buf_enter
    },
    OnYank = {
        pattern = "*",
        desc = "When text is yanked",
        type = "TextYankPost",
        group = events_group,
        handler = event_handlers.handle_text_yank
    },
    LeaveBuffer = {
        pattern = "*",
        desc = "When leaves a buffer",
        type = "BufLeave",
        group = events_group,
        handler = event_handlers.handle_buf_leave
    },
    VimEnter = {
        pattern = "*",
        desc = "When enters vim",
        type = "VimEnter",
        group = events_group,
        handler = event_handlers.handle_vim_enter
    },
}
