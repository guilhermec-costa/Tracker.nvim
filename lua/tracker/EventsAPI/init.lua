---@class Event_Manager
---@field corresponding_session Tracker
local Event_Manager = {}
local log_date_format = "%Y/%m/%d %H:%M:%S"
Event_Manager.__index = Event_Manager

---@param tracker_session Tracker
---@return Event_Manager
function Event_Manager.new(tracker_session)
    local self = setmetatable({}, Event_Manager)
    self:initialize(tracker_session)
    return self
end

---@param tracker_session Tracker
function Event_Manager:initialize(tracker_session)
    self.corresponding_session = tracker_session
end

---@param _events table
function Event_Manager:activate_events(_events)
    for event_name, event_cfg in pairs(_events) do
        local autocmd_id = vim.api.nvim_create_autocmd(event_cfg.type, {
            pattern = event_cfg.pattern,
            group = event_cfg.group,
            callback = function()
                pcall(event_cfg.handler, self.corresponding_session)
            end,
            desc = event_cfg.desc
        })
        _events[event_name].status = 1
        _events[event_name].id = autocmd_id
    end
    self.corresponding_session.Session.persistor:create_log("Tracker events have been initialized on " ..
        os.date(log_date_format))
end

function Event_Manager:deactivate_events(_events)
    if #_events == 0 then
        return "Error deactivating any events"
    end

    for _, event_cfg in pairs(_events) do
        vim.api.nvim_del_autocmd(event_cfg.id)
        event_cfg.status = 0
    end
end

return Event_Manager
