local notify = require "notify"

---@class Notifier
---@field notifier any
local Notifier = {}
Notifier.__index = Notifier


---@return Notifier
---@param opts table
function Notifier.new(opts)
    local self = setmetatable({}, Notifier)
    self:initialize(opts)
    return self
end

---@return nil
function Notifier:initialize(opts)
    self.notifier = notify
    self.default_notifier_title = opts.title
end

---@param message string
---@return nil
function Notifier:notify_success(message)
    self.notifier(message)
end

---@param message string
function Notifier:notify_error(message)
    self.notifier(message, "error")
end

---@param message string
function Notifier:notify_info(message)
    self.notifier(message, "info", {
        title = self.default_notifier_title,
    })
end

return Notifier
