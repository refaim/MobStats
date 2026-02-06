setfenv(1, MobStats)

---@class DamageVO
---@field _attack_speed number
---@field _min_damage number
---@field _max_damage number
---@field _dps number
DamageVO = {}

---@param attack_speed number
---@param min_damage number
---@param max_damage number
---@return DamageVO
function DamageVO:Construct(attack_speed, min_damage, max_damage)
    assert(type(attack_speed) == "number" and attack_speed > 0)
    assert(type(min_damage) == "number" and min_damage > 0)
    assert(type(max_damage) == "number" and max_damage > 0)

    local object = new(DamageVO)
    object._attack_speed = attack_speed
    object._min_damage = min_damage
    object._max_damage = max_damage
    object._dps = ((min_damage + max_damage) / 2.0) / attack_speed
    return object
end

---@return number
function DamageVO:GetAttackSpeed()
    return self._attack_speed
end

---@return number
function DamageVO:GetMinDamage()
    return self._min_damage
end

---@return number
function DamageVO:GetMaxDamage()
    return self._max_damage
end

---@return number
function DamageVO:GetDPS()
    return self._dps
end
