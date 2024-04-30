---@module "event_handler"

local event_handler = {}

event_handler.handle_buf_enter = function ()
   print("Entered the buffer")
end

return event_handler
