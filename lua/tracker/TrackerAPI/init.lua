local utils = require "tracker.utils"
local events_configs = require "tracker.default_events_config"
local notifier = require "tracker.TrackerAPI.Notifier"
local types = require "tracker.types"

---@class TrackerAPI
---@field session_id string
---@field active_project string
---@field persistor PersistencyAPI
---@field cleanup_session_files_on_session_end boolean
---@field cleanup_log_files_on_session_end boolean
---@field session_name string
---@field timer_to_save number
---@field timer_to_log number
---@field events table<string, table>
---@field event_debounce_time number
---@field logs_permission boolean
---@field is_running boolean
---@field runned_for number
---@field cleanup_session_files_frequency number
---@field cleanup_log_files_frequency number
---@field will_be_deleted_on osdate|string
---@field has_timer_started boolean
---@field allow_notifications boolean
---@field Notifier table
local TrackerAPI = {}
TrackerAPI.__index = TrackerAPI

---@param opts userconfig
---@return TrackerAPI|nil
function TrackerAPI.new_session(opts)
    local self = setmetatable({}, TrackerAPI)
    self:initialize(opts)
    return self
end

function TrackerAPI:initialize(opts)
    ---@type Notifier
    self.Notifier = notifier.new({
        title = "Tracker",
    })

    if not utils.check_table_type(opts) then
        self.Notifier:notify_error("Failed to initialize Tracker.nvim")
        self = {} ---@diagnostic disable-line: missing-fields
        return
    end

    local defaults = self:__generate_tracker_default_values()
    self.session_id = defaults.session_id
    self.session_name = defaults.session_name
    self.will_be_deleted_on = defaults.will_be_deleted_on
    self.cleanup_session_files_frequency = opts.cleanup_session_files_frequency or 2
    self.cleanup_log_files_frequency_files_frequency = opts.cleanup_log_files_frequency or 2
    self.cleanup_log_files_on_session_end = opts.cleanup_log_files_on_session_end or false
    self.cleanup_session_files_on_session_end = opts.cleanup_session_files_on_session_end or false
    self.save_session_data_frequency = opts.save_session_data_frequency or 20
    self.cleanup_session_files_frequency = opts.cleanup_session_files_frequency
    self.events = events_configs
    self.event_debounce_time = opts.timer_delay or 3000
    self.is_running = true
    self.logs_permission = opts.logs_permission or false
    self.runned_for = 0
    self.timer_to_save = 0
    self.timer_to_log = 0
    self.has_timer_started = false
    self.allow_notifications = opts.allow_notifications
    self:start_timer(self.event_debounce_time)
end

---@return tracker_defaults
function TrackerAPI:__generate_tracker_default_values()
    local tracker_start_timestamp = os.time()
    local add_to_creation_time = 7 * 24 * 60 * 60
    local session_id = utils.generate_random_uuid();
    local session_name = tostring(os.date("%Y_%m_%d_%H_%M_%S"))
    return {
        start_timestamp = tracker_start_timestamp,
        session_id = session_id,
        session_name = session_name,
        will_be_deleted_on = os.date("%c", tracker_start_timestamp + add_to_creation_time)
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
    debounce = debounce or 3000
    local timer = vim.loop.new_timer()
    self.timer = timer
    if self.has_timer_started == false then
        timer:start(1000, debounce, vim.schedule_wrap(function()
            if self.is_running then
                self.runned_for = self.runned_for + (debounce / 1000)
                self.timer_to_save = self.timer_to_save + (debounce / 1000)
                self.timer_to_log = self.timer_to_log + (debounce / 1000)
                if self.timer_to_log > 20 then
                    self.persistor:persist_logs()
                    self.persistor:clear_logs()
                    self.timer_to_log = 0
                end

                if self.timer_to_save > 180 then
                    self.persistor:save_session_data_to_json_file()
                    self.timer_to_save = 0
                end
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

---@return string
function TrackerAPI:get_tracker_ascii()
    return [[


    ████████╗██████╗░░█████╗░░█████╗░██╗░░██╗███████╗██████╗░░░░███╗░░██╗██╗░░░██╗██╗███╗░░░███╗
    ╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██║░██╔╝██╔════╝██╔══██╗░░░████╗░██║██║░░░██║██║████╗░████║
    ░░░██║░░░██████╔╝███████║██║░░╚═╝█████═╝░█████╗░░██████╔╝░░░██╔██╗██║╚██╗░██╔╝██║██╔████╔██║
    ░░░██║░░░██╔══██╗██╔══██║██║░░██╗██╔═██╗░██╔══╝░░██╔══██╗░░░██║╚████║░╚████╔╝░██║██║╚██╔╝██║
    ░░░██║░░░██║░░██║██║░░██║╚█████╔╝██║░╚██╗███████╗██║░░██║██╗██║░╚███║░░╚██╔╝░░██║██║░╚═╝░██║
    ░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝╚═╝╚═╝░░╚══╝░░░╚═╝░░░╚═╝╚═╝░░░░░╚═╝


    ]]
end

return TrackerAPI
