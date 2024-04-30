local table_x = {
    keyx = "valuex",
    ["keyy"] = "valuey",
    [5] = "value5",
    [7] = tostring(true),
    func = P(function()
        return nil
    end)
}

local array = { 1, 2, 3, 4, 5 }

for key, value in pairs(table_x) do
    print("key: " .. key .. " | value: " .. value)
end

print('-----------------------')

for key, value in ipairs(table_x) do
    print("key: " .. key .. " | value: " .. value)
end

print('-----------------------')

for key, value in pairs(array) do
    print("key: " .. key .. " | value: " .. value * 2)
end

print('-----------------------')

for index, value in ipairs(array) do
    print("key: " .. index .. " | value: " .. value * 2)
end

for i, _ in ipairs(table_x) do
    print(i)
end

print('-----------------------')

table_x["<leader>C"] = "A keyboard"
P(table_x)

print('-----------------------')

for key in pairs(table_x) do
    print("Key: " .. key)
end

print('-----------------------')

for key, value in ipairs({ 1, 2 ,3}) do
    print("Index: " .. key)
end


table_x["Global"] = "Global"
P(table_x)
