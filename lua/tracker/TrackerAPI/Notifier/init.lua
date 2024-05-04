local notify = require "notify"

---@class Notifier
local Notifier = {}
Notifier.__index = Notifier


---@return table
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

---@return nil
function Notifier:notify_success(message)
    self.notifier(message)
end

function Notifier:notify_error(message)
    self.notifier(message, "error")
end

function Notifier:notify_info(message)
    self.notifier(message, "info", {
        title = self.default_notifier_title
    })
end

return Notifier
