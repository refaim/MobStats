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
