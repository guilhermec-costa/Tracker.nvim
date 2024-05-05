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
    CmdLineLeave = {
        pattern = "*",
        desc = "When leave cmd line mode",
        type = "CmdlineLeave",
        group = events_group,
        handler = event_handlers.handle_cmdline_leave
    },
    LostFocus = {
        pattern = "*",
        desc = "When any UI interaction is made",
        type = "FocusLost",
        group = events_group,
        handler = event_handlers.handle_lost_focus
    },
    InsertMode = {
        pattern = "*",
        desc = "When enters insert mode",
        type = "InsertEnter",
        group = events_group,
        handler = event_handlers.handle_insert_enter
    },
    BufWrite = {
        pattern = "*",
        desc = "When saves a buffer",
        type = "BufWrite",
        group = events_group,
        handler = event_handlers.handle_buf_write
    },
    InsertCharPre = {
        pattern = "*",
        desc = "Before inserting a character",
        type = "InsertCharPre",
        group = events_group,
        handler = event_handlers.handle_insert_char_pre
    },
    AddBuffer = {
        pattern = "*",
        desc = "After adding a buffer",
        type = "BufAdd",
        group = events_group,
        handler = event_handlers.handle_buf_add
    },
    DeleteBuffer = {
        pattern = "*",
        desc = "After adding a buffer",
        type = "BufDelete",
        group = events_group,
        handler = event_handlers.handle_buf_delete
    },
}
