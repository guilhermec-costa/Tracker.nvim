---@module "event_handler"

local event_handler = {}

event_handler.handle_buf_enter = function ()
   print("Entered the buffer")
end


event_handler.handle_buf_leave = function()
    print("Left the buffer")
end

event_handler.handle_text_yank = function()
    print("Text was yanked")
end

return event_handler
