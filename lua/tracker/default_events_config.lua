---@module "default_events_config"

local events_group = vim.api.nvim_create_augroup("Events", { clear = true })
local event_handlers = require "tracker.EventsAPI.event_handlers"

---@return table<string, table<string, string>>
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
    LostFocus = {
        pattern = "*",
        desc = "When any UI interaction is made",
        type = "FocusLost",
        group = events_group,
        handler = event_handlers.handle_lost_focus
    },
    BufNewFile = {
        pattern = "*",
        desc = "When editing a new file",
        type = "BufNewFile",
        group = events_group,
        handler = event_handlers.handle_buf_new_file
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
    RecordedMacros = {
        pattern = "*",
        desc = "After recording a vim macro",
        type = "RecordingLeave",
        group = events_group,
        handler = event_handlers.handle_recorded_macro
    },
    ModeChanged = {
        pattern = "*",
        desc = "After change vim mode",
        type = "ModeChanged",
        group = events_group,
        handler = event_handlers.handle_mode_change
    },
    ColorScheme = {
        pattern = "*",
        desc = "After change colorscheme",
        type = "ColorScheme",
        group = events_group,
        handler = event_handlers.handle_colorscheme_change
    },
    SearchWrapped = {
        pattern = "*",
        desc = "After make a search",
        type = "SearchWrapped",
        group = events_group,
        handler = event_handlers.handle_search_wrapper
    },
    VimEnter = {
        pattern = "*",
        desc = "After enter vim",
        type = "VimEnter",
        group = events_group,
        handler = event_handlers.handle_vim_enter
    },
    VimLeavePre = {
        pattern = "*",
        desc = "After leave vim",
        type = "VimLeavePre",
        group = events_group,
        handler = event_handlers.handle_vim_leave
    },
    FocusGained = {
        pattern = "*",
        desc = "After nvim got focused",
        type = "VimLeave",
        group = events_group,
        handler = event_handlers.handle_vim_get_focus
    }
}
