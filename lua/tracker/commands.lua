local commands = {}

vim.api.nvim_create_user_command("TrackerPauseTimer", "lua require('tracker').TrackerSession:pause()", {})
vim.api.nvim_create_user_command("TrackerResumeTimer", "lua require('tracker').TrackerSession:resume()", {})
vim.api.nvim_create_user_command("TrackerStartTimer", "lua require('tracker').TrackerSession:start_timer()", {})

return commands
