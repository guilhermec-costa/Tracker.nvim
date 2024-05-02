local commands = {}

vim.api.nvim_create_user_command("TrackerPauseTimer", "lua require('tracker').Session:pause_timer()", {})
vim.api.nvim_create_user_command("TrackerResumeTimer", "lua require('tracker').Session:resume_timer()", {})
vim.api.nvim_create_user_command("TrackerStartTimer", "lua require('tracker').Session:start_timer()", {})
vim.api.nvim_create_user_command("TrackerResetTimer", "lua require('tracker').Session:reset_timer()", {})

return commands
