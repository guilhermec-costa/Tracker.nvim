local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require "telescope.config".values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local previewers = require "telescope.previewers"

local telescope_integration = {}

---@param tracker_session Tracker
function telescope_integration.day_folders_picker(opts, tracker_session)
    local results = {}
    local session_files = io.popen("find " ..
        tracker_session.Session.persistor.persistence_location .. " -mindepth 1 -type d")

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
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()[1]
                vim.api.nvim_command("Telescope tracker commands")
            end)
            return true
        end
    }):find()
end

---@param opts table|nil
---@param tracker_session any
function telescope_integration.session_files_picker(opts)
    P(opts)
    local results = {}
    --[[ local session_files = io.popen("find " .. ]]
    --[[     tracker_session.Session.persistor.persistence_location .. date .. " -mindepth 1 -type f") ]]
    --[[]]
    --[[ if session_files then ]]
    --[[     for file in session_files:lines() do ]]
    --[[         if string.match(file, ".json$") then ]]
    --[[             table.insert(results, file) ]]
    --[[         end ]]
    --[[     end ]]
    --[[ end ]]
    --[[]]
    --[[ pickers.new(opts, { ]]
    --[[     prompt_title = "Session files from " .. date, ]]
    --[[     finder = finders.new_table { ]]
    --[[         results = results ]]
    --[[     }, ]]
    --[[     sorter = conf.generic_sorter(opts), ]]
    --[[     previewer = previewers.vim_buffer_cat.new({}), ]]
    --[[     attach_mappings = function(prompt_bufnr, map) ]]
    --[[         actions.select_default:replace(function() ]]
    --[[             actions.close(prompt_bufnr) ]]
    --[[             local selection = action_state.get_selected_entry()[1] ]]
    --[[             vim.api.nvim_command("Telescope tracker commands") ]]
    --[[         end) ]]
    --[[         return true ]]
    --[[     end ]]
    --[[ }):find() ]]
end

return telescope_integration
