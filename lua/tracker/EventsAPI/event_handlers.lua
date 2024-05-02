---@module "event_handler"

local event_handler = {}

event_handler.handle_buf_enter = function(data)
    local bufname = vim.fn.expand("%")
    local current_buf_data = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath[bufname] or nil
    if current_buf_data == nil then
        if bufname ~= "." and bufname ~= "" then
            data.Aggregator:add_aggregator({
                aggregator_name = bufname,
                aggregator_path = "session_scoped.buffers.aggregators.filepath"
            })
            local aggregator_created = data.Aggregator.Data.session_scoped.buffers.aggregators.filepath[bufname]
            aggregator_created.counter = aggregator_created.counter + 1
        end
    else
        current_buf_data.counter = current_buf_data.counter + 1
    end
end


event_handler.handle_buf_leave = function(data)
end

event_handler.handle_text_yank = function(data)
end

return event_handler
