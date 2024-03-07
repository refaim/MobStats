setfenv(1, MobStats)

---@class ArmorVO
---@field _amount number
---@field _damage_reduction_in_percents number
ArmorVO = {}

---@param amount number
---@param player_level number
---@return ArmorVO
function ArmorVO:Construct(amount, player_level)
    assert(type(amount) == "number" and amount >= 0)
    assert(type(player_level) == "number" and player_level > 0)

    local object = new(ArmorVO)
    object._amount = amount
    object._damage_reduction_in_percents = (amount / (amount + 400 + 85 * player_level)) * 100
    return object
end

---@return number
function ArmorVO:GetAmount()
    return self._amount
end

---@return number
function ArmorVO:GetDamageReductionInPercents()
    return self._damage_reduction_in_percents
end
