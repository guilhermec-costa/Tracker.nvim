return require("telescope").register_extension {
  setup = function(ext_config, config)
  end,
  exports = {
    commands = require("tracker.commands").trigger_tracker_commands
  },
}
