return require("telescope").register_extension {
    exports = {
        commands = require "tracker.telescope_integration".commands_picker,
        days = require "tracker.telescope_integration".day_folders_picker,
        sessions = require "tracker.telescope_integration".session_files_picker,
        dashboard_files = require "tracker.telescope_integration".dashboard_files_picker
    },
}
