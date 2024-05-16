# tracker.nvim

Stay in the flow, let Tracker handle the stats 📈

---

Tracker is currently in development ⚠️,  so it still misses some important user-customization features. You can already try it, but don't use it seriously just yet.

## What is Tracker?

`tracker.nvim` is a feature-rich plugin for Neovim aimed at providing comprehensive tracking and analysis of developer activities within Neovim.
- **Detailed Tracking**: Watches a variety of events. Check [Tracker events]()
- **Data Analysis**: Uses the data collected via the events to make valuable analysis of your perfomance
- **Flexible Customization**: Customize settings to fit your workflow and individual preferences.

### Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
  'GuiC0506/Tracker.nvim',
}
```


Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
-- init.lua:
{
    'GuiC0506/Tracker.nvim',
}

-- plugins/telescope.lua:
return {
    'GuiC0506/Tracker.nvim',
    }
```

### Tracker setup 

```lua
require('tracker').setup {
    
    -- the location where Tracker will store the session data and logs
    persistence_location = "foo/bar/eg"

    -- if Tracker should store logs about the tracking process
    logs_permission = true,

    -- the frequency, in seconds, which the session data will be saved in the current session
    save_session_data_frequency = 20

    -- time, in seconds, between each timer increment
    timer_delay = 3000,
    
    -- if Tracker should delete all session files on the end of a vim session
    cleanup_session_files_on_session_end = false,

    -- if Tracker should delete all log files on the end of a vim session
    cleanup_log_files_on_session_end = true 

    -- the frequency, in days, which the session data files will be deleted
    -- the files would be deleted the next time you enter vim, and 'x' days have passed
    cleanup_session_files_frequency = 7

    -- the frequency, in days, which the log files will be deleted
    -- the files would be deleted the next time you enter vim, and 'x' days have passed
    cleanup_log_files_frequency = 7
}
```
