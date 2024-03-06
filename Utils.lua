setfenv(1, MobStats)

---@param n number
---@param decimal_places number
function round(n, decimal_places)
    local m = 10 ^ decimal_places
    n = n * m
    if n >= 0 then
        n = floor(n + 0.5)
    else
        n = ceil(n - 0.5)
    end
    return n / m
end

---@param n number|nil
function zero_to_nil(n)
    if n == 0 then
        return nil
    end
    return n
end

---@param value boolean
---@return wowboolean
function boolean_to_wowboolean(value)
    if value then
        return 1
    end
    return nil
end

---@param strings string[]
---@param glue string
---@return string
function strjoin(strings, glue)
    local result = ""
    for _, s in ipairs(strings) do
        if result == "" then
            result = s
        else
            result = result .. glue .. s
        end
    end
    return result
end

---@param value string
---@param color string
function paint(value, color)
    return color .. value .. FONT_COLOR_CODE_CLOSE
end
