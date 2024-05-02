---@module "event_handler"

local event_handler = {}

event_handler.handle_buf_enter = function(data)
    --[[ local filetype_aggregator = data.Data.session_scoped.buffers.aggregators.filetype ]]
    --[[ local bufname = vim.fn.expand("%") ]]
end


event_handler.handle_buf_leave = function(data)
end

event_handler.handle_text_yank = function(data)
end

return event_handler
