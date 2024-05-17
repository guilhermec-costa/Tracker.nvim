local popup = require "plenary.popup"
local Tracker_win_id

local function close_window()
    vim.api.nvim_win_close(Tracker_win_id, true)
    Tracker_win_id = nil
end

local function create_window(opts)
    local width = 60
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
    local bufnr = vim.api.nvim_win_get_buf(Tracker_win_id)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "q", close_window, { silent = false })
end


create_window({})
