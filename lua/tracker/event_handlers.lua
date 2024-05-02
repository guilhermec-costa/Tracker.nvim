---@module "event_handler"

local event_handler = {}

event_handler.handle_buf_enter = function(data)
    local buffer_data = data.Data.session_scoped.buffers
    local bufname = vim.fn.expand("%")
    print(bufname)
    --[[ buffer_data.counter = buffer_data.counter + 1 ]]
end


event_handler.handle_buf_leave = function(data)
end

event_handler.handle_text_yank = function(data)
end

return event_handler
