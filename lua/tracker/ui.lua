local popup = require "plenary.popup"
local P = require "tracker.utils".P
local Tracker_win_id
local Tracker_win_bufnr

local UI = {}

vim.keymap.set("n", "<leader>T", "<cmd> lua require('tracker.ui').toggle_menu()<CR>", { silent = true })

local function close_window()
    vim.api.nvim_win_close(Tracker_win_id, true)
    Tracker_win_id = nil
    Tracker_win_bufnr = nil
end

local function create_window(opts)
    local width = 90
    local height = 10
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

    local win_id, win = popup.create(opts, {
        title = "Dashboard Files",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
        callback = function(_, sel)
            UI.toggle_menu()
            vim.cmd("silent! e " .. sel)
        end
    })

    Tracker_win_bufnr = vim.api.nvim_win_get_buf(win_id)
    return {
        id = win_id,
        bufnr = Tracker_win_bufnr
    }
end

function UI.toggle_menu()
    if Tracker_win_id ~= nil and vim.api.nvim_win_is_valid(Tracker_win_id) == true then
        close_window()
        return
    end

    ---@type PersistencyAPI
    local persistor = require 'tracker'.Session.persistor

    local files = persistor:get_formmated_dashboard_files()
    local win = create_window(files)

    Tracker_win_id = win.id
    Tracker_win_bufnr = win.bufnr

    print(vim.api.nvim_win_is_valid(Tracker_win_id))
    vim.api.nvim_win_set_option(Tracker_win_id, "number", true)
    vim.api.nvim_buf_set_name(Tracker_win_bufnr, "tracker-dashboard-menu")

    vim.api.nvim_buf_set_keymap(Tracker_win_bufnr, "n", "q", "<cmd>lua require('tracker.ui').toggle_menu()<cr>",
        { silent = true })
    vim.api.nvim_buf_set_keymap(Tracker_win_bufnr, "n", "<Esc>", "<cmd>lua require('tracker.ui').toggle_menu()<cr>",
        { silent = true })
    vim.api.nvim_buf_set_keymap(Tracker_win_bufnr, "n", "dd", "<cmd>lua require('tracker.ui').delete_item()<cr>",
        { silent = true })
end

function UI.delete_item()
    local cursor_line_index = vim.api.nvim_win_get_cursor(Tracker_win_id)[1]
    local buf_lines = vim.api.nvim_buf_get_lines(Tracker_win_bufnr, 0, -1, false)
    local file_to_remove = buf_lines[cursor_line_index]

    table.remove(buf_lines, cursor_line_index)
    vim.api.nvim_buf_set_lines(Tracker_win_bufnr, 0, -1, false, buf_lines)

    local tracker_dashboard_files = require 'tracker'.Session.persistor.dashboard_files
    if tracker_dashboard_files[file_to_remove] ~= nil then
        tracker_dashboard_files[file_to_remove] = nil
    end
end

return UI
