local utils = require "tracker.utils"
local events_configs = require "tracker.default_events_config"
local notifier = require "tracker.TrackerAPI.Notifier"

---@class TrackerAPI
---@field session_id string
---@field persistor PersistencyAPI
---@field session_name string
---@field events table<string, table>
---@field event_debounce_time number
---@field is_running boolean
---@field runned_for number
---@field has_timer_started boolean
---@field allow_notifications boolean
---@field Notifier table
local TrackerAPI = {}
TrackerAPI.__index = TrackerAPI

---@return TrackerAPI
function TrackerAPI.new_session(opts)
    local self = setmetatable({}, TrackerAPI)
    self:initialize(opts)
    return self
end

function TrackerAPI:initialize(opts)
    local defaults = self:__generate_tracker_default_values()
    self.session_id = defaults.session_id
    self.session_name = defaults.session_name
    self.events = events_configs
    self.event_debounce_time = opts.event_debounce_time
    self.is_running = true
    self.runned_for = 0
    self.has_timer_started = false
    self.allow_notifications = opts.allow_notifications
    self.Notifier = notifier.new({
        title = "Tracker",
    })
    self:start_timer(opts.timer_debounce)
end

function TrackerAPI:__generate_tracker_default_values()
    local tracker_start_timestamp = os.time()
    local session_id = utils.generate_random_uuid();
    local session_name = tostring(os.date("%Y_%m_%d_%H_%M_%S"))
    return {
        start_timestamp = tracker_start_timestamp,
        session_id = session_id,
        session_name = session_name
    }
end

---@return table<string, table>
function TrackerAPI:get_active_events()
    local active_events = {}
    for event_name, event_metadata in pairs(self.events) do
        if event_metadata.status == 1 then
            table.insert(active_events, { [event_name] = event_metadata })
        end
    end
    return active_events
end

function TrackerAPI:get_inactive_events()
    local inactive_events = {}
    for _, event_metadata in pairs(self.events) do
        if event_metadata.status == 0 then
            table.insert(inactive_events, event_metadata)
        end
    end
    return inactive_events
end

---@param debounce number|nil
function TrackerAPI:start_timer(debounce)
    debounce = debounce or 5000
    local timer = vim.loop.new_timer()
    self.timer = timer
    if self.has_timer_started == false then
        --self:notify("Tracker Timer has started")
        timer:start(700, debounce, vim.schedule_wrap(function()
            if self.is_running then
                self.runned_for = self.runned_for + (debounce / 1000)
                if self.runned_for > 40 then
                    self.persistor:save_session_data_to_json_file()
                end
                -- persist-frequency logic goes here
            end
        end))
        self.has_timer_started = true
    else
        self:notify("Timer has already been started", "error")
    end
end

function TrackerAPI:reset_timer()
    if self.timer then
        self.timer:close()
        self.runned_for = 0
        self.has_timer_started = false
        self:start_timer()
    else
        self:notify("Any timer initialized yet", "error")
    end
end

function TrackerAPI:pause_timer()
    self.is_running = false
    self:notify("Tracker timer has been paused", "info")
end

function TrackerAPI:resume_timer()
    self.is_running = true
end

---@alias notify_types
---| "success" # a success notificationt type
---| "info" # an info notificationt type
---| "error" # an error notificationt type
---| nil

---@param type notify_types
function TrackerAPI:notify(message, type)
    type = type or "success"
    if self.allow_notifications then
        if type == "info" then
            self.Notifier:notify_info(message)
        elseif type == "error" then
            self.Notifier:notify_error(message)
        else
            self.Notifier:notify_success(message)
        end
    else
        print(message)
    end
end

return TrackerAPI
