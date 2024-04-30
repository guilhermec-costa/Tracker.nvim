---@param a string A random string parameter
---@param b string Another random string parameter
local fooX = function(a, b)
    print("FooX: " .. tostring(a) .. " | " .. tostring(b))
end

--- A function that takes a table as a parameter
---@param opts table table of options
---@return nil
local fooY = function(opts)
    print("FooY: " .. tostring(opts.foo) .. " | " .. tostring(opts.name))
    return nil
end

local fooZ = function(text)
    print("FooZ: " .. tostring(text))
end

fooX("churros", "CHURROS")
fooX("churros", "Teste")

-- the parenthesis can be ommtided if the function takes one string parameter, or a literal table
fooY({ foo = true, name = "Churros" })
fooY { foo = true, name = "Churros" }
fooY { name = "Churros" }

fooZ("ChurrosZ")
fooZ "ChurrosZ"
