local telescope_integration = require "telescope._extensions.integration"

return require("telescope").register_extension {
    exports = setmetatable({
        commands = telescope_integration.commands_picker,
        days = telescope_integration.day_folders_picker,
        sessions = telescope_integration.session_files_picker,
        dashboard_files = telescope_integration.dashboard_files_picker,
        logs = telescope_integration.logs_picker,
    }, {
        __index = function(_, key)
            return telescope_integration.telescope
        end
    })
}
