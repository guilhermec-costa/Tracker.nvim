---@module "event_handler"
local event_handler = {}

event_handler.handle_buf_enter = function(data)
    local bufname = vim.fn.expand("%")
    local bufext = vim.bo.filetype
    local bufnr = vim.api.nvim_get_current_buf()

    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath
    local filetype_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype

    --[[ local current_buf_data = filepath_aggregator[bufname] or nil ]]
    local current_fileext_data = filetype_aggregator[bufext] or nil

    -- filepath related
    if bufname ~= "" and bufname ~= "." then
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
    end

    -- filetype related
    if current_fileext_data == nil then
        if bufext ~= "" then
            data.Aggregator:add_aggregator({
                aggregator_name = bufext,
                aggregator_path = "session_scoped.buffers.aggregators.filetype"
            })

            local filetype_aggregator_created = data.Aggregator.Data.session_scoped.buffers.aggregators.filetype[bufext]
            filetype_aggregator_created.counter = filetype_aggregator_created.counter + 1
            filetype_aggregator.counter = filetype_aggregator.counter + 1
        end
    else
        current_fileext_data.counter = current_fileext_data.counter + 1
        filetype_aggregator.counter = filetype_aggregator.counter + 1
    end
end

event_handler.handle_buf_leave = function(data)
    local bufname = vim.fn.expand("%")
    local filepath_aggregator = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath

    if bufname ~= "" and bufname ~= "." then
        local current_buf_data = filepath_aggregator[bufname]
        if current_buf_data ~= nil then
            if current_buf_data.metadata.buf_timer_status == 1 then
                current_buf_data.__buf_timer:close()
                current_buf_data.metadata.buf_timer_status = 0
                filepath_aggregator.timer = filepath_aggregator.timer + filepath_aggregator[bufname].timer
            end
        end
    end
end

event_handler.handle_text_yank = function(data)
end

return event_handler
