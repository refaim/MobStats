setfenv(1, MobStats)

---@class MeleeDrawer
MeleeDrawer = {}

---@param vo DamageVO|nil
local function format_damage(vo)
    if vo == nil then
        return nil
    end

    return format(
        L.MELEE_FORMAT,
        round(vo:GetMinDamage(), 0),
        round(vo:GetMaxDamage(), 0),
        round(vo:GetAttackSpeed(), 2),
        round(vo:GetDPS(), 1)
    )
end

---@param value MeleeVO|nil
---@param tooltip TooltipInterface
function MeleeDrawer:Draw(value, tooltip)
    if value == nil then
        return nil
    end

    local mh_string = format_damage(value:GetMainHandDamage())
    local oh_string = format_damage(value:GetOffhandDamage())
    if mh_string ~= nil and oh_string ~= nil then
        tooltip:AddValue(L.MELEE_MH, mh_string, false)
        tooltip:AddValue(L.MELEE_OH, oh_string, false)
    elseif mh_string ~= nil then
        tooltip:AddValue(L.MELEE, mh_string, false)
    end
end
