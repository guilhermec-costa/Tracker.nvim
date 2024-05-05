---@module "event_handler"
local event_handler = {}

local function increment_counter(aggregator, key, start_value)
    start_value = start_value or 1
    if aggregator[key] == nil then
        aggregator[key] = start_value
    else
        aggregator[key] = aggregator[key] + 1
    end
end

event_handler.handle_buf_enter = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype
    local bufnr = vim.api.nvim_get_current_buf()

    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    --[[ local current_buf_data = filepath_aggregator[bufname] or nil ]]
    local current_fileext_data = filetype_aggregator[bufext] or nil

    -- filepath related
    if bufname == "" or bufname == "." then
        return
    end

    local current_buf_data = filepath_aggregator[bufname]
    if current_buf_data == nil then
        data.Aggregator:add_aggregator({
            aggregator_name = bufname,
            aggregator_path = "session_scoped.buffers.aggregators.filepath"
        })

        filepath_aggregator[bufname].metadata = {
            name = bufname,
            filetype = bufext,
            buf_timer_status = 1,
            bufnr = bufnr
        }

        filepath_aggregator[bufname].__buf_timer = vim.loop.new_timer()
        filepath_aggregator[bufname].__buf_timer:start(100, 3000, vim.schedule_wrap(function()
            filepath_aggregator[bufname].timer = filepath_aggregator[bufname].timer + (3000 / 1000)
            filetype_aggregator[bufext].timer = filetype_aggregator[bufext].timer + (3000 / 1000)
        end))

        local filepath_aggregator_created = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
            [bufname]
        filepath_aggregator_created.counter = filepath_aggregator_created.counter + 1
        filepath_aggregator.counter = filepath_aggregator.counter + 1
    else
        filepath_aggregator[bufname].__buf_timer = vim.loop.new_timer()
        current_buf_data.counter = current_buf_data.counter + 1
        filepath_aggregator.counter = filepath_aggregator.counter + 1
        filepath_aggregator[bufname].__buf_timer:start(100, 3000, vim.schedule_wrap(function()
            filepath_aggregator[bufname].timer = filepath_aggregator[bufname].timer + (3000 / 1000)
            filetype_aggregator[bufext].timer = filetype_aggregator[bufext].timer + (3000 / 1000)
        end))
        filepath_aggregator[bufname].metadata.buf_timer_status = 1
    end

    -- filetype related
    if current_fileext_data == nil then
        if bufext == "" then
            return
        end
        data.Aggregator:add_aggregator({
            aggregator_name = bufext,
            aggregator_path = "session_scoped.buffers.aggregators.filetype"
        })

        local filetype_aggregator_created = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype[bufext]
        filetype_aggregator_created.counter = filetype_aggregator_created.counter + 1
        filetype_aggregator.counter = filetype_aggregator.counter + 1
    else
        current_fileext_data.counter = current_fileext_data.counter + 1
        filetype_aggregator.counter = filetype_aggregator.counter + 1
    end
end

event_handler.handle_buf_leave = function(data)
    local bufname = vim.fn.expand("%")
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath

    if bufname == "" or bufname == "." then
        return
    end

    local current_buf_data = filepath_aggregator[bufname]

    if current_buf_data == nil then
        return
    end

    if current_buf_data.metadata.buf_timer_status == 1 then
        current_buf_data.__buf_timer:close()
        current_buf_data.metadata.buf_timer_status = 0
        filepath_aggregator.timer = filepath_aggregator.timer + filepath_aggregator[bufname].timer
    end
end

event_handler.handle_text_yank = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype


    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_counter(buffer_aggregator, "yanked")
    increment_counter(filetype_aggregator[bufext], "yanked")
    increment_counter(filepath_aggregator[bufname], "yanked")
end

event_handler.handle_lost_focus = function(data)
    print("herer")
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype


    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_counter(buffer_aggregator, "lost_focus")
    increment_counter(filetype_aggregator[bufext], "lost_focus")
    increment_counter(filepath_aggregator[bufname], "lost_focus")
end

event_handler.handle_cmdline_leave = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype


    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_counter(buffer_aggregator, "cmd_mode")
    increment_counter(filetype_aggregator[bufext], "cmd_mode")
    increment_counter(filepath_aggregator[bufname], "cmd_mode")
end


event_handler.handle_insert_enter = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype


    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_counter(buffer_aggregator, "insert_mode")
    increment_counter(filetype_aggregator[bufext], "insert_mode")
    increment_counter(filepath_aggregator[bufname], "insert_mode")
end

event_handler.handle_insert_leave = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype

    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_counter(buffer_aggregator, "normal")
    increment_counter(filetype_aggregator[bufext], "normal")
    increment_counter(filepath_aggregator[bufname], "normal")
end

event_handler.handle_buf_write = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype


    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_counter(buffer_aggregator, "saved")
    increment_counter(filetype_aggregator[bufext], "saved")
    increment_counter(filepath_aggregator[bufname], "saved")
end

event_handler.handle_insert_char_pre = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype
    local char_typed = vim.v.char

    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    if buffer_aggregator.chars == nil then
        buffer_aggregator.chars = {}
    end

    if filepath_aggregator[bufname].chars == nil then
        filepath_aggregator[bufname].chars = {}
    end

    if filetype_aggregator[bufext].chars == nil then
        filetype_aggregator[bufext].chars = {}
    end

    increment_counter(buffer_aggregator.chars, char_typed)
    increment_counter(buffer_aggregator, "keystrokes")
    increment_counter(filepath_aggregator[bufname].chars, char_typed)
    increment_counter(filepath_aggregator[bufname], "keystrokes")
    increment_counter(filetype_aggregator[bufext], "keystrokes")
    increment_counter(filetype_aggregator[bufext].chars, char_typed)
end

event_handler.handle_buf_add = function(data)
    local bufext = vim.bo.filetype
    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    if bufext == "" or bufext == "netrw" then
        return
    end

    if filetype_aggregator[bufext] == nil then
        data.Aggregator:add_aggregator({
            aggregator_name = bufext,
            aggregator_path = "session_scoped.buffers.aggregators.filetype"
        })
    end

    increment_counter(buffer_aggregator, "buffers_added")
    increment_counter(filetype_aggregator[bufext], "buffers_added")
end

event_handler.handle_buf_delete = function(data)
    local bufext = vim.bo.filetype
    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    if bufext == "" or bufext == "netrw" then
        return
    end

    if filetype_aggregator[bufext] == nil then
        data.Aggregator:add_aggregator({
            aggregator_name = bufext,
            aggregator_path = "session_scoped.buffers.aggregators.filetype"
        })
    end

    increment_counter(buffer_aggregator, "buffers_deleted")
    increment_counter(filetype_aggregator[bufext], "buffers_deleted")
end

event_handler.handle_dir_changed = function(data)
end

event_handler.handle_recorded_macro = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype
    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_counter(buffer_aggregator, "recorded_macros")
    increment_counter(filepath_aggregator[bufname], "recorded_macros")
    increment_counter(filetype_aggregator[bufext], "recorded_macros")
end

event_handler.handle_mode_change = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype
    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_counter(buffer_aggregator, "mode_change")
    increment_counter(filepath_aggregator[bufname], "mode_change")
    increment_counter(filetype_aggregator[bufext], "mode_change")
end

event_handler.handle_bored_user = function(data)
    print("How have you event got here?")
end

return event_handler
