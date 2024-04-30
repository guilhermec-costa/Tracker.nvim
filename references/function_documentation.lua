---@module "Function_documentation"
---@param a string A random string parameter
---@param b string Another random string parameter
local fooX = function(a, b)
    print("FooX: " .. tostring(a) .. " | " .. tostring(b))
end

---@class custom_type
local typed_table = {
    propx = {},
    propy = {}
}

--- A function that takes a table as a parameter
---@param opts custom_type
---@return nil
local fooY = function(opts)
    print(opts.propx .. " | " .. opts.propy)
    return nil
end

local fooZ = function(text)
    print("FooZ: " .. tostring(text))
end

---@enum
local codes = {
    success = 1,
    error = 0
}

---@enum
local enumerator = {
    Success = {
        ---@return integer
        get_code = function()
            return codes.success
        end
    },
    Failure = {
        ---@return integer
        get_code = function()
            return codes.error
        end
    }
}

fooZ "Churros"
fooY { propx = 5, propy = 10 }
local code = enumerator.Success
print(code.get_code())

