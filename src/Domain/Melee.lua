setfenv(1, MobStats)

---@class MeleeVO
---@field _main_hand_damage DamageVO
---@field _offhand_damage DamageVO|nil
MeleeVO = {}

---@param main_hand_damage_or_nil DamageVO|nil
---@param offhand_damage_or_nil DamageVO|nil
---@return MeleeVO|nil
function MeleeVO:Construct(main_hand_damage_or_nil, offhand_damage_or_nil)
    if main_hand_damage_or_nil == nil then
        return nil
    end

    local object = new(MeleeVO)
    object._main_hand_damage = --[[---@type DamageVO]] main_hand_damage_or_nil
    object._offhand_damage = offhand_damage_or_nil
    return object
end

---@return DamageVO
function MeleeVO:GetMainHandDamage()
    return self._main_hand_damage
end

---@return DamageVO|nil
function MeleeVO:GetOffhandDamage()
    return self._offhand_damage
end
