local notify = require "notify"

---@class Notifier
local Notifier = {}
Notifier.__index = Notifier


---@return table
function Notifier.new()
    local self = setmetatable({}, Notifier)
    self:initialize()
    return self
end

---@return nil
function Notifier:initialize()
    self.notifier = notify
end

---@return nil
function Notifier:notify_success(message)
    self.notifier(message)
end

function Notifier:notify_error(message)
    self.notifier(message, "error")
end

function Notifier:notify_info(message)
    self.notifier(message, "info")
end

return Notifier
