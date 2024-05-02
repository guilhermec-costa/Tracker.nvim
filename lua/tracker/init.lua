---@module "tracker"
local TrackerAPI = require "tracker.TrackerAPI"
local EventsAPI = require "tracker.EventsAPI"
require "tracker.commands"

local Tracker = {
    Data = {
        session_scoped = {
            buffers = {
                aggregators = {
                    root = {
                        time = 0,
                        counter = 0
                    },
                    filetype = {
                        root = {
                            time = 0,
                            counter = 0
                        }
                    },
                    filename = {
                        root = {
                            time = 0,
                            counter = 0
                        }
                    },
                }
            }
        },
        current_day_scoped = {}
    }
}

function Tracker.setup(opts)
    opts = opts or {}
    Tracker.Session = TrackerAPI.new_session(opts)
    if opts.start_timer_on_launch then
        Tracker.Session:start_timer()
    end

    -- dependency injection
    local Event_Manager = EventsAPI.new(Tracker)
    Event_Manager:activate_events(Tracker.Session.events)
end

return Tracker
