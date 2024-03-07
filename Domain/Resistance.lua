setfenv(1, MobStats)

---@alias ResistanceId "arcane" | "fire" | "frost" | "holy" | "nature" | "shadow"

---@class ResistanceVO
---@field _id ResistanceId
---@field _amount number
ResistanceVO = {}

---@param id ResistanceId
---@param amount number
---@return ResistanceVO
function ResistanceVO:Construct(id, amount)
    assert(type(id) == "string" and id ~= "")
    assert(type(amount) == "number" and amount >= 0)

    -- TODO сконвертировать в проценты
    -- TODO вывести шанс попадания
    -- TODO each mob/boss at higher level above you gains either +5 or +8 resistance to every spell school INCLUDING Holy

    local object = new(ResistanceVO)
    object._id = id
    object._amount = amount
    return object
end

---@return ResistanceId
function ResistanceVO:GetId()
    return self._id
end

---@return number
function ResistanceVO:GetAmount()
    return self._amount
end
