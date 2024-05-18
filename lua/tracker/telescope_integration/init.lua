local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require "telescope.config".values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local previewers = require "telescope.previewers"
local commands = require "tracker.commands"
local P = require "tracker.utils".P

local telescope_integration = {}

---@param opts table
function telescope_integration.day_folders_picker(opts)
    ---@type PersistencyAPI
    local persistor = require("tracker").Session.persistor

    local results = {}
    local session_files = io.popen("find " ..
        persistor.persistence_location .. " -mindepth 1 -type d")

    if session_files then
        for file in session_files:lines() do
            table.insert(results, file)
        end
    end

    pickers.new(opts, {
        prompt_title = "Days with session files",
        finder = finders.new_table {
            results = results
        },
        sorter = conf.generic_sorter(opts),
        previewer = previewers.vim_buffer_cat.new({}),
        attach_mappings = function(prompt_bufnr, map)
            map("n", "<c-p>", function()
                local selection = action_state.get_selected_entry()
                local command = string.format("ls %s", selection[1])
                local file_handler = io.popen(command)
                if file_handler ~= nil then
                    for filepath in file_handler:lines() do
                        if persistor.dashboard_files[filepath] == nil then
                            persistor.dashboard_files[filepath] = selection.index
                        end
                    end
                end
            end)
            map("i", "<c-p>", function()
                local current_entry = action_state.get_selected_entry()[1]
            end)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()[1]
                local last_folder = vim.fn.fnamemodify(selection, ':t')
                telescope_integration.session_files_picker({}, last_folder)
            end)
            return true
        end
    }):find()
end

---@param opts table|nil
function telescope_integration.session_files_picker(opts, date)
    ---@type PersistencyAPI
    local persistor = require("tracker").Session.persistor
    local function handle_mark_logic_on_selection(selection, prompt_bufnr)
        if selection ~= persistor.last_telescope_session_entry then
            actions.add_selection(prompt_bufnr)
        else
            actions.remove_selection(prompt_bufnr)
        end
    end

    date = date or vim.fn.input("Enter date (YYYY_MM_DD): ")
    local results = {}
    local session_files = io.popen("find " ..
        persistor.persistence_location .. date .. " -mindepth 1 -type f")

    if session_files then
        for file in session_files:lines() do
            if string.match(file, ".json$") then
                table.insert(results, file)
            end
        end
    end

    pickers.new(opts, {
        prompt_title = "Session files from " .. date,
        finder = finders.new_table {
            results = results,
        },
        sorter = conf.generic_sorter(opts),
        previewer = previewers.vim_buffer_cat.new({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                handle_mark_logic_on_selection(selection, prompt_bufnr)
                persistor.last_telescope_session_entry = selection[1]

                if persistor.dashboard_files[selection] == nil then
                    persistor.dashboard_files[selection[1]] = selection.index
                    return
                end

                persistor.dashboard_files[selection[1]] = nil
            end)
            return true
        end
    }):find()
end

function telescope_integration.commands_picker(opts)
    opts = opts or {}
    local results = {}
    for cmd_name, _ in pairs(commands) do
        table.insert(results, cmd_name)
    end
    pickers.new(opts, {
        prompt_title = "Tracker Commands",
        finder = finders.new_table {
            results = results
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()[1]
                commands[selection].action()
            end)
            return true
        end,
    }):find()
end

function telescope_integration.dashboard_files_picker(opts)
    ---@type PersistencyAPI
    local persistor = require("tracker").Session.persistor
    opts = opts or {}
    local results = persistor:get_formmated_dashboard_files()

    pickers.new(opts, {
        prompt_title = "Dashboard files",
        finder = finders.new_table {
            results = results
        },
        sorter = conf.generic_sorter(opts),
        previewer = previewers.vim_buffer_cat.new({}),
        attach_mappings = function(prompt_bufnr, map)
            return true
        end
    }):find()
end

return telescope_integration
