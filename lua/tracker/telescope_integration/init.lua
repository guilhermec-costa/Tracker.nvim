local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require "telescope.config".values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local previewers = require "telescope.previewers"
local commands = require "tracker.commands"
local utils = require "tracker.utils"

---@type PersistencyAPI
local persistor = require("tracker").Session.persistor

local telescope_integration = {}

---@param opts table
function telescope_integration.day_folders_picker(opts)
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
            local toggle_selection = function()
                local selection = action_state.get_selected_entry()

                local command = string.format("find %s -mindepth 1 -type f", selection[1])
                local file_handler = io.popen(command)
                if file_handler ~= nil then
                    local selection_in_days_folders = persistor.selected_day_folders[selection[1]]
                    if selection_in_days_folders ~= nil then
                        for filepath in file_handler:lines() do
                            persistor.dashboard_files[filepath] = nil
                        end
                        actions.remove_selection(prompt_bufnr)
                        persistor.selected_day_folders[selection[1]] = nil
                    else
                        persistor.selected_day_folders[selection[1]] = selection.index
                        for filepath in file_handler:lines() do
                            if persistor.dashboard_files[filepath] == nil then
                                persistor.dashboard_files[filepath] = selection.index
                            end
                        end
                        actions.add_selection(prompt_bufnr)
                    end
                end
            end
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()[1]
                local last_folder = vim.fn.fnamemodify(selection, ':t')
                telescope_integration.session_files_picker({}, last_folder)
            end)
            map("n", "<Tab>", toggle_selection)
            map("i", "<Tab>", toggle_selection)
            return true
        end
    }):find()
end

---@param opts table|nil
function telescope_integration.session_files_picker(opts, date)
    date = date or vim.fn.input("Enter date (YYYY_MM_DD): ")
    if date == nil or date == "" then return end

    local results = {}
    local session_files = io.popen("find " ..
        persistor.persistence_location .. date .. " -mindepth 1 -type f")

    if session_files then
        for file in session_files:lines() do
            table.insert(results, file)
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
            local toggle_selection = function()
                local selection = action_state.get_selected_entry()

                local selection_in_dashboard_files = persistor.dashboard_files[selection[1]]
                if selection_in_dashboard_files == nil then
                    persistor.dashboard_files[selection[1]] = selection.index
                    actions.add_selection(prompt_bufnr)
                else
                    persistor.dashboard_files[selection[1]] = nil
                    actions.remove_selection(prompt_bufnr)
                end

                actions.move_selection_previous(prompt_bufnr)
            end
            map("n", "<Tab>", toggle_selection)
            map("i", "<Tab>", toggle_selection)
            return true
        end
    }):find()
end

---@param opts table
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

local function generate_new_dashboard_finder()
    local results = {}
    local dashboard_files = persistor:get_formmated_dashboard_files()
    for _, file in ipairs(dashboard_files) do
        table.insert(results, file)
    end
    return finders.new_table({
        results = results,
        entry_maker = function(entry)
            return {
                value = entry,
                display = entry,
                ordinal = entry,
            }
        end,
    })
end


---@param opts table
function telescope_integration.dashboard_files_picker(opts)
    opts = opts or {}

    pickers.new(opts, {
        prompt_title = "Dashboard files",
        finder = generate_new_dashboard_finder(),
        sorter = conf.generic_sorter(opts),
        previewer = previewers.vim_buffer_cat.new({}),
        attach_mappings = function(prompt_bufnr, map)
            local delete_entry = function()
                local selection = action_state.get_selected_entry()
                if selection then
                    local current_picker = action_state.get_current_picker(prompt_bufnr)
                    persistor.dashboard_files[selection.value] = nil
                    current_picker:refresh(generate_new_dashboard_finder(), { reset_prompt = true })
                end
            end

            map("i", "dd", delete_entry)
            map("n", "dd", delete_entry)
            return true
        end,
    }):find()
end

---@param opts table
function telescope_integration.logs_picker(opts)
    local log_folders = io.popen(string.format("find %s -mindepth 1 -type d", persistor.logs_location))
    local results = {}
    if log_folders ~= nil then
        for logpath in log_folders:lines() do
            table.insert(results, logpath)
        end
    end

    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Logs",
        finder = finders.new_table {
            results = results,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry,
                    ordinal = entry
                }
            end
        },
        previewer = previewers.vim_buffer_cat.new({})
    }):find()
end

---@param opts table
function telescope_integration.telescope(opts)
    local results = {
        "Tracker commands",
        "Tracker days",
        "Tracker sessions"
    }

    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Tracker - Telescope commands",
        finder = finders.new_table {
            results = results,
            entry_maker = function(entry)
                return {
                    value = string.lower(entry),
                    display = entry,
                    ordinal = entry
                }
            end
        },
        previewer = previewers.vim_buffer_cat.new({}),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.api.nvim_command("Telescope " .. selection.value)
            end)
            return true
        end
    }):find()
end

return telescope_integration
