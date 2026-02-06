setfenv(1, MobStats)

---@class ArmorDrawer
ArmorDrawer = {}

---@param value_or_nil ArmorVO|nil
---@param tooltip TooltipInterface
function ArmorDrawer:Draw(value_or_nil, tooltip)
    if value_or_nil == nil then
        return
    end
    local value = --[[---@type ArmorVO]]
        value_or_nil

    local integer_amount = round(value:GetAmount(), 0)

    local amount_string
    if integer_amount == 0 then
        amount_string = L.ARMOR_NONE
    else
        amount_string = format(L.ARMOR_FORMAT, integer_amount, round(value:GetDamageReductionInPercents(), 0))
    end

    tooltip:AddValue(L.ARMOR, amount_string, false)
end
