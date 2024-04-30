local table_x = {
    keyx = "valuex",
    ["keyy"] = "valuey",
    [5] = "value5"
}

local array = { 1, 2, 3, 4, 5 }

for key, value in pairs(table_x) do
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

table.insert(table_x, 4, "churros")
table.sort(table_x)
P(table_x)
