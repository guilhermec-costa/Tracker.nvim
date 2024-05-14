return require("telescope").register_extension {
    setup = function(ext_config, config)
    end,
    exports = {
        commands = require("tracker.commands").tracker_commands_telescope_ext,
        dashboard = function()
            require "tracker".Session.persistor:session_files_picker()
        end
    },
}
