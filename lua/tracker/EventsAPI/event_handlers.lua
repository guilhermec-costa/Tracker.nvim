---@module "event_handler"
local event_handler = {}

local function increment_key_by_aggregator(aggregator, key, start_value)
    start_value = start_value or 1
    if aggregator[key] == nil then
        aggregator[key] = start_value
    else
        aggregator[key] = aggregator[key] + 1
    end
end

---@return nil
event_handler.handle_buf_enter = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype
    local bufnr = vim.api.nvim_get_current_buf()

    ---@type AggregatorAPI
    local Aggregator = data.Aggregator

    local buffer_aggregator = Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = Aggregator.Data.session_scoped.buffers.aggregators.filetype

    if bufname == "" or bufname == "." then
        return
    end

    if filepath_aggregator[bufname] == nil then
        Aggregator:add_aggregator({
            aggregator_name = bufname,
            aggregator_path = "session_scoped.buffers.aggregators.filepath"
        })

        filepath_aggregator[bufname].metadata = {
            name = bufname,
            filetype = bufext,
            bufnr = bufnr
        }

        filepath_aggregator[bufname].timer = 0
        filepath_aggregator[bufname].counter = 0
    end

    if filetype_aggregator[bufext] == nil then
        if bufext == "" then
            return
        end

        Aggregator:add_aggregator({
            aggregator_name = bufext,
            aggregator_path = "session_scoped.buffers.aggregators.filetype"
        })

        filetype_aggregator[bufext].timer = 0
        filetype_aggregator[bufext].counter = 0
    end

    filepath_aggregator[bufname].counter = filepath_aggregator[bufname].counter + 1
    buffer_aggregator.counter = buffer_aggregator.counter + 1
    filetype_aggregator[bufext].counter = filetype_aggregator[bufext].counter + 1

    filepath_aggregator[bufname].__buf_timer = vim.loop.new_timer()
    filepath_aggregator[bufname].__buf_timer:start(1000, 3000, vim.schedule_wrap(function()
        filepath_aggregator[bufname].timer = filepath_aggregator[bufname].timer + (3000 / 1000)
        filetype_aggregator[bufext].timer = filetype_aggregator[bufext].timer + (3000 / 1000)
        filepath_aggregator[bufname].metadata.buf_timer_status = 1
    end))
end

---@return nil
event_handler.handle_buf_leave = function(data)
    local bufname = vim.fn.expand("%")
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath

    if bufname == "" or bufname == "." then
        return
    end

    if filepath_aggregator[bufname] == nil then
        return
    end

    filepath_aggregator[bufname].__buf_timer:close()
    filepath_aggregator[bufname].metadata.buf_timer_status = 0
    filepath_aggregator.timer = filepath_aggregator.timer + filepath_aggregator[bufname].timer
end

---@return nil
event_handler.handle_text_yank = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype

    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_key_by_aggregator(buffer_aggregator, "yanked")
    increment_key_by_aggregator(filetype_aggregator[bufext], "yanked")
    increment_key_by_aggregator(filepath_aggregator[bufname], "yanked")
end

---@return nil
event_handler.handle_lost_focus = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype

    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_key_by_aggregator(buffer_aggregator, "lost_focus")
    increment_key_by_aggregator(filetype_aggregator[bufext], "lost_focus")
    increment_key_by_aggregator(filepath_aggregator[bufname], "lost_focus")
end

---@return nil
event_handler.handle_cmdline_leave = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype

    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_key_by_aggregator(buffer_aggregator, "cmd_mode")
    increment_key_by_aggregator(filetype_aggregator[bufext], "cmd_mode")
    increment_key_by_aggregator(filepath_aggregator[bufname], "cmd_mode")
end


---@return nil
event_handler.handle_insert_enter = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype

    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_key_by_aggregator(buffer_aggregator, "insert_mode")
    increment_key_by_aggregator(filetype_aggregator[bufext], "insert_mode")
    increment_key_by_aggregator(filepath_aggregator[bufname], "insert_mode")
end

---@return nil
event_handler.handle_insert_leave = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype

    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_key_by_aggregator(buffer_aggregator, "normal")
    increment_key_by_aggregator(filetype_aggregator[bufext], "normal")
    increment_key_by_aggregator(filepath_aggregator[bufname], "normal")
end

---@return nil
event_handler.handle_buf_write = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype


    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_key_by_aggregator(buffer_aggregator, "saved")
    increment_key_by_aggregator(filetype_aggregator[bufext], "saved")
    increment_key_by_aggregator(filepath_aggregator[bufname], "saved")
end

---@return nil
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

    increment_key_by_aggregator(buffer_aggregator.chars, char_typed)
    increment_key_by_aggregator(filepath_aggregator[bufname].chars, char_typed)
    increment_key_by_aggregator(filetype_aggregator[bufext].chars, char_typed)

    increment_key_by_aggregator(buffer_aggregator, "keystrokes")
    increment_key_by_aggregator(filepath_aggregator[bufname], "keystrokes")
    increment_key_by_aggregator(filetype_aggregator[bufext], "keystrokes")
end

---@return nil
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

    increment_key_by_aggregator(buffer_aggregator, "buffers_added")
    increment_key_by_aggregator(filetype_aggregator[bufext], "buffers_added")
end

---@return nil
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

    increment_key_by_aggregator(buffer_aggregator, "buffers_deleted")
    increment_key_by_aggregator(filetype_aggregator[bufext], "buffers_deleted")
end

event_handler.handle_dir_changed = function(data)
end

---@return nil
event_handler.handle_recorded_macro = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype

    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_key_by_aggregator(buffer_aggregator, "recorded_macros")
    increment_key_by_aggregator(filepath_aggregator[bufname], "recorded_macros")
    increment_key_by_aggregator(filetype_aggregator[bufext], "recorded_macros")
end

---@return nil
---@type function(data: table)
event_handler.handle_mode_change = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype

    local buffer_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_key_by_aggregator(buffer_aggregator, "mode_change")
    increment_key_by_aggregator(filepath_aggregator[bufname], "mode_change")
    increment_key_by_aggregator(filetype_aggregator[bufext], "mode_change")
end

event_handler.handle_bored_user = function(data)
    print("How have you even got here?")
end

event_handler.handle_vim_enter = function(data)
    local bufname = vim.fn.expand("%")
    data.Aggregator.add:add_aggregator({
        aggregator_name = 'Teste',
        aggregator_path = "session_scoped.buffers.aggregators.project"
    })
end

return event_handler
