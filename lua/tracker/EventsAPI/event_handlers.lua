---@module "event_handler"
local event_handler = {}
local log_date_format = "%Y/%m/%d %H:%M:%S"

---@param aggregator table
---@param key string
---@param start_value integer|nil
local function increment_key_by_aggregator(aggregator, key, start_value)
    start_value = start_value or 1
    if aggregator[key] == nil then
        aggregator[key] = start_value
    else
        aggregator[key] = aggregator[key] + 1
    end
end

---@param data Tracker
---@return nil
event_handler.handle_buf_enter = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.fn.expand("%:e")
    local bufnr = vim.api.nvim_get_current_buf()

    local project_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.project
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    if bufname == "" or bufname == "." then
        return
    end

    if filepath_aggregator[bufname] == nil then
        data.Aggregator:add_aggregator({
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
        filepath_aggregator[bufname].keystrokes = 0
        filepath_aggregator[bufname].yanked = 0
        filepath_aggregator[bufname].saved = 0
        filepath_aggregator[bufname].mode_change = {}
        filepath_aggregator[bufname].mode_change.by_mode = {}
    end

    if filetype_aggregator[bufext] == nil then
        if bufext == "" then
            return
        end

        data.Aggregator:add_aggregator({
            aggregator_name = bufext,
            aggregator_path = "session_scoped.buffers.aggregators.filetype"
        })

        filetype_aggregator[bufext].timer = 0
        filetype_aggregator[bufext].counter = 0
        filetype_aggregator[bufext].keystrokes = 0
        filetype_aggregator[bufext].yanked = 0
        filetype_aggregator[bufext].saved = 0
        filetype_aggregator[bufext].mode_change = {}
        filetype_aggregator[bufext].mode_change.by_mode = {}
    end

    filepath_aggregator[bufname].counter = filepath_aggregator[bufname].counter + 1
    project_aggregator.counter = project_aggregator.counter + 1
    filetype_aggregator[bufext].counter = filetype_aggregator[bufext].counter + 1

    local debounce = data.Session.event_debounce_time
    filepath_aggregator[bufname].__buf_timer = vim.loop.new_timer()
    filepath_aggregator[bufname].__buf_timer:start(1000, debounce, vim.schedule_wrap(function()
        filepath_aggregator[bufname].timer = filepath_aggregator[bufname].timer + (debounce / 1000)
        filetype_aggregator[bufext].timer = filetype_aggregator[bufext].timer + (debounce / 1000)
        filepath_aggregator[bufname].metadata.buf_timer_status = 1
    end))

    data.Session.persistor:create_log("Entered at new buffer named \"" ..
        bufname .. "\" on " .. tostring(os.date(log_date_format)))
end

---@param data Tracker
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

    data.Session.persistor:create_log("Left at buffer named \"" ..
        bufname .. "\" on" .. tostring(os.date(log_date_format)))
end

---@param data Tracker
---@return nil
event_handler.handle_text_yank = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.fn.expand("%:e")

    local project_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.project
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_key_by_aggregator(project_aggregator, "yanked")
    increment_key_by_aggregator(filetype_aggregator[bufext], "yanked")
    increment_key_by_aggregator(filepath_aggregator[bufname], "yanked")

    data.Session.persistor:create_log("Yanked text at buffer \"" ..
        bufname .. "\" on " .. tostring(os.date(log_date_format)))
end

---@param data Tracker
---@return nil
event_handler.handle_lost_focus = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.fn.expand("%:e")

    local project_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.project
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_key_by_aggregator(project_aggregator, "lost_focus")
    increment_key_by_aggregator(filetype_aggregator[bufext], "lost_focus")
    increment_key_by_aggregator(filepath_aggregator[bufname], "lost_focus")

    data.Session.persistor:create_log("Vim has lost focus at buffer \"" ..
        bufname .. "\" on " .. tostring(os.date(log_date_format)))
end

---@param data Tracker
---@return nil
event_handler.handle_buf_write = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.fn.expand("%:e")


    local project_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.project
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_key_by_aggregator(project_aggregator, "saved")
    increment_key_by_aggregator(filetype_aggregator[bufext], "saved")
    increment_key_by_aggregator(filepath_aggregator[bufname], "saved")

    data.Session.persistor:create_log("Vim has lost focus at buffer \"" ..
        bufname .. "\" on " .. tostring(os.date(log_date_format)))
end

---@param data Tracker
---@return nil
event_handler.handle_insert_char_pre = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.fn.expand("%:e")
    local char_typed = vim.v.char

    local project_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.project
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    if project_aggregator.chars == nil then
        project_aggregator.chars = {}
    end

    if filepath_aggregator[bufname].chars == nil then
        filepath_aggregator[bufname].chars = {}
    end

    if filetype_aggregator[bufext].chars == nil then
        filetype_aggregator[bufext].chars = {}
    end

    if project_aggregator.chars == nil then
        project_aggregator.chars = {}
    end

    increment_key_by_aggregator(project_aggregator.chars, char_typed)
    increment_key_by_aggregator(filepath_aggregator[bufname].chars, char_typed)
    increment_key_by_aggregator(filetype_aggregator[bufext].chars, char_typed)
    increment_key_by_aggregator(project_aggregator.chars, char_typed)

    increment_key_by_aggregator(project_aggregator, "keystrokes")
    increment_key_by_aggregator(filepath_aggregator[bufname], "keystrokes")
    increment_key_by_aggregator(filetype_aggregator[bufext], "keystrokes")
end

---@param data Tracker
---@return nil
event_handler.handle_buf_add = function(data)
    local bufext = vim.fn.expand("%:e")
    local project_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.project
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

    increment_key_by_aggregator(project_aggregator, "buffers_added")
    increment_key_by_aggregator(filetype_aggregator[bufext], "buffers_added")
end

---@param data Tracker
---@return nil
event_handler.handle_buf_delete = function(data)
    local bufext = vim.fn.expand("%:e")

    local project_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.project
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

    increment_key_by_aggregator(project_aggregator, "buffers_deleted")
    increment_key_by_aggregator(filetype_aggregator[bufext], "buffers_deleted")
end

---@param data Tracker
---@return nil
event_handler.handle_recorded_macro = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.fn.expand("%:e")

    local project_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.project
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_key_by_aggregator(project_aggregator, "recorded_macros")
    increment_key_by_aggregator(filepath_aggregator[bufname], "recorded_macros")
    increment_key_by_aggregator(filetype_aggregator[bufext], "recorded_macros")
    data.Session.persistor:create_log("Recorded new macro at buffer \"" ..
        bufname .. "\" on " .. tostring(os.date(log_date_format)))
end

---@param data Tracker
---@return nil
event_handler.handle_mode_change = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.fn.expand("%:e")
    local current_mode = vim.api.nvim_get_mode().mode

    local project_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.project
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    increment_key_by_aggregator(project_aggregator.mode_change, "value")
    increment_key_by_aggregator(project_aggregator.mode_change.by_mode, current_mode)

    increment_key_by_aggregator(filepath_aggregator[bufname].mode_change, "value")
    increment_key_by_aggregator(filepath_aggregator[bufname].mode_change.by_mode, current_mode)

    increment_key_by_aggregator(filetype_aggregator[bufext].mode_change, "value")
    increment_key_by_aggregator(filetype_aggregator[bufext].mode_change.by_mode, current_mode)

    data.Session.persistor:create_log("Change vim mode to \"" .. current_mode .. "\" at buffer \"" ..
        bufname .. "\" on " .. tostring(os.date(log_date_format)))
end

---@param data Tracker
event_handler.handle_bored_user = function(data)
    print("How have you even got here?")
end

---@param data Tracker
event_handler.handle_vim_enter = function(data)
    local current_directory = vim.fn.getcwd()
    local project_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.project
    project_aggregator.name = current_directory
    project_aggregator.timer = 0
    project_aggregator.counter = 0
    project_aggregator.keystrokes = 0
    project_aggregator.yanked = 0
    project_aggregator.saved = 0
    project_aggregator.colorscheme_change = 0
    project_aggregator.mode_change = {}
    project_aggregator.mode_change.by_mode = {}
end

---@param data Tracker
event_handler.handle_search_wrapper = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.fn.expand("%:e")

    local project_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.project
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype
    increment_key_by_aggregator(filepath_aggregator[bufname], "search_wrapper")
    increment_key_by_aggregator(filetype_aggregator[bufext], "search_wrapper")
    increment_key_by_aggregator(project_aggregator, "search_wrapper")
end

---@param data Tracker
event_handler.handle_vim_leave = function(data)
    data.Session.persistor:save_session_data_to_json_file()
    if data.Session.cleanup_session_files_on_session_end then
        data.Session.persistor:clear_session_files()
    end

    if data.Session.cleanup_log_files_on_session_end then
        data.Session.persistor:clear_log_files()
    end
end

---@param data Tracker
event_handler.handle_buf_new_file = function(data)
    local project_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.project
    increment_key_by_aggregator(project_aggregator, "new_file")
end

---@param data Tracker
event_handler.handle_colorscheme_change = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.fn.expand("%:e")

    local project_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.project
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype
    increment_key_by_aggregator(filepath_aggregator[bufname], "colorscheme_change")
    increment_key_by_aggregator(filetype_aggregator[bufext], "colorscheme_change")
    increment_key_by_aggregator(project_aggregator, "colorscheme_change")
end

---@param data Tracker
event_handler.handle_vim_get_focus = function(data)
    local project_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.project
    increment_key_by_aggregator(project_aggregator, "get_focus")
end

return event_handler
