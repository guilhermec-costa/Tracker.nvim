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
    --[[ OnEnterBufferV2 = {
        pattern = "*",
        desc = "When enters a buffer v2",
        type = "BufEnter",
        group = events_group,
        handler = event_handlers.handle_buf_enter_v2
    }, ]]
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
    --[[ LeaveBufferV2 = {
        pattern = "*",
        desc = "When leaves a buffer v2",
        type = "BufLeave",
        group = events_group,
        handler = event_handlers.handle_buf_leaveV2
    }, ]]
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
    InsertLeave = {
        pattern = "*",
        desc = "When leaves insert mode",
        type = "InsertLeave",
        group = events_group,
        handler = event_handlers.handle_insert_leave
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
    --[[ ImBored = { ]]
    --[[     pattern = "*", ]]
    --[[     desc = "Yep, you pressed the same key 42 times and were able to trigger this fucking event", ]]
    --[[     type = "UserGettingBored", ]]
    --[[     group = events_group, ]]
    --[[     handler = event_handlers.handle_bored_user ]]
    --[[ }, ]]
}
