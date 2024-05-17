---@type Tracker
local tracker = require "tracker"

return require("telescope").register_extension {
    setup = function(ext_config, config)
    end,
    exports = {
        commands = require "tracker.telescope_integration".commands,
        days = function()
            require "tracker.telescope_integration".day_folders_picker({}, tracker)
        end,
        sessions = function()
            require "tracker.telescope_integration".session_files_picker({}, tracker)
        end
    },
}
