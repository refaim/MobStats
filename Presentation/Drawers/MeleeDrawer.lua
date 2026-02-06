setfenv(1, MobStats)

---@class MeleeDrawer
MeleeDrawer = {}

---@param vo_or_nil DamageVO|nil
local function format_damage(vo_or_nil)
    if vo_or_nil == nil then
        return nil
    end
    local vo = --[[---@type DamageVO]] vo_or_nil

    return format(L.MELEE_FORMAT,
        round(vo:GetMinDamage(), 0),
        round(vo:GetMaxDamage(), 0),
        round(vo:GetAttackSpeed(), 2),
        round(vo:GetDPS(), 1))
end

---@param value_or_nil MeleeVO|nil
---@param tooltip TooltipInterface
function MeleeDrawer:Draw(value_or_nil, tooltip)
    if value_or_nil == nil then
        return nil
    end
    local value = --[[---@type MeleeVO]] value_or_nil

    local mh_string = format_damage(value:GetMainHandDamage())
    local oh_string = format_damage(value:GetOffhandDamage())
    if oh_string ~= nil then
        tooltip:AddValue(L.MELEE_MH, --[[---@type string]] mh_string, false)
        tooltip:AddValue(L.MELEE_OH, --[[---@type string]] oh_string, false)
    else
        tooltip:AddValue(L.MELEE, --[[---@type string]] mh_string, false)
    end
end
