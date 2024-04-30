local current_time = os.date()
local time = os.time()                       -- can be used as session id
local formmated_time_x = os.date("%Y-%m-%d") -- can be used as day id
local formmated_time_y = os.date("%D")
local consumed_time = os.clock()
print(current_time)
print(consumed_time)
print(formmated_time_x)
print(formmated_time_y)
print(time)

_G.Buffer_index = {
    initial_time = nil,
    final_time = nil,
    diff_time = nil
}

local buffer_group = vim.api.nvim_create_augroup("BufferGroup", {
    clear = true
})

vim.api.nvim_create_autocmd("BufEnter", {
    group = buffer_group,
    pattern = "*",
    callback = function()
        print("Entered in the buffer")
        Buffer_index.initial_time = os.time()
    end
})


vim.api.nvim_create_autocmd("BufLeave", {
    group = buffer_group,
    pattern = "*",
    callback = function()
        print("Left the buffer")
        Buffer_index.final_time = os.time()
        print(Buffer_index.final_time)
        Buffer_index.diff_time = Buffer_index.initial_time and Buffer_index.final_time - Buffer_index.initial_time
        --[[ print(Buffer_index.diff_time) ]]
    end
})
