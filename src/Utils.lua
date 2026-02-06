setfenv(1, MobStats)

---@generic T
---@param class T
---@return T
function new(class)
    assert(type(class) == "table")

    local object = {}
    setmetatable(object, { __index = class })
    return --[[---@type T]] object
end

---@param t table
---@return number
function get_any_table_size(t)
    assert(type(t) == "table")

    local n = 0
    for _, _ in pairs(t) do
        n = n + 1
    end
    return n
end

---@param t table
---@return string
function get_first_key(t)
    assert(type(t) == "table")

    local result
    for k, _ in pairs(t) do
        result = k
        break
    end
    assert(type(result) == "string")
    return result
end
