---@module "event_handler"

local event_handler = {}

event_handler.handle_buf_enter = function(opts)
    P(opts)
    --[[ P(vim.bo.filetype) ]]
end


event_handler.handle_buf_leave = function(opts)
    --[[ print("Left the buffer") ]]
end

event_handler.handle_text_yank = function(opts)
    --[[ print("Text was yanked") ]]
end

return event_handler
