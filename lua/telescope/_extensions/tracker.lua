---@type Tracker
local tracker = require "tracker"

return require("telescope").register_extension {
    setup = function(ext_config, config)
    end,
    exports = {
        commands = require "tracker.commands".tracker_commands_telescope_ext,
        day_folders = function()
            require "tracker.telescope_integration".day_folders_picker({}, tracker)
        end,
        session_files = function()
            require "tracker.telescope_integration".session_files_picker()
        end
    },
}
