---@module "tracker"

local utils = {}
local random = math.random

---@return string, number
utils.generate_random_uuid = function()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

utils.split_string = function(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

utils.calculate_field_percentage = function(dividing, divisor)
    dividing = dividing or 0
    divisor = divisor or 1
    local result = math.ceil(dividing / divisor * 100)
    if tostring(result) == "nan" then
        return 0
    end
    return result
end

utils.P = function(command)
    print(vim.inspect(command))
end

---@param bufnr integer
---@return integer|nil
utils.get_win_id_from_buffer = function(bufnr)
    local win_ids = vim.fn.win_findbuf(bufnr)
    if #win_ids > 0 then
        return win_ids[1]
    end
    return nil
end

utils.check_table_type = function(data)
    if type(data) ~= "table" then
        return false
    end

    return true
end

return utils
