local popup = require "plenary.popup"
local Tracker_win_id
local Tracker_win_bufnr

local ui_group = vim.api.nvim_create_augroup("Ui", { clear = true })
function _G.close_window()
    vim.api.nvim_win_close(Tracker_win_id, true)
    Tracker_win_id = nil
    Tracker_win_bufnr = nil
end

function _G.create_window(opts, files)
    local width = 70
    local height = 10
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

    Tracker_win_id = popup.create(opts, {
        title = "Dashboard Files",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
        callback = function()
            print("it works")
        end
    })
    Tracker_win_bufnr = vim.api.nvim_win_get_buf(Tracker_win_id)
    vim.api.nvim_buf_set_keymap(Tracker_win_bufnr, "n", "q", "<cmd>lua close_window()<cr>", { silent = false })
    vim.api.nvim_buf_set_keymap(Tracker_win_bufnr, "n", "<Esc>", "<cmd>lua close_window()<cr>", { silent = false })
    vim.api.nvim_buf_set_keymap(Tracker_win_bufnr, "n", "dd", "<cmd> lua delete_item()<cr>", { silent = true })

    -- big thanks to Prime here. you are chad man
    vim.cmd(
        "autocmd BufLeave <buffer> ++nested ++once silent lua close_window()"
    )
end

function _G.show_menu()
    local file_objects = require 'tracker'.Session.persistor.dashboard_files
    local opts = {}
    for filename, _ in pairs(file_objects) do
        table.insert(opts, filename)
    end
    create_window(opts)
end

function _G.delete_item()
    local bufnr = vim.api.nvim_win_get_buf(Tracker_win_id)
    local cursor_position = vim.api.nvim_win_get_cursor(Tracker_win_id)[1]
    local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local file_to_remove = buf_lines[cursor_position]
    P(file_to_remove)
end
