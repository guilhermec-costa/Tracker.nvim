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
    event_debounce_time = 3000,
    allow_notifications = false,
    logs_permission = true,
    cleanup_session_files_on_session_end = false,
    cleanup_log_files_on_session_end = false
}
```
