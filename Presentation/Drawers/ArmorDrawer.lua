setfenv(1, MobStats)

---@class ArmorDrawer
ArmorDrawer = {}

---@param value ArmorVO
---@param tooltip TooltipInterface
function ArmorDrawer:Draw(value, tooltip)
    local integer_amount = round(value:GetAmount(), 0)

    local amount_string
    if integer_amount == 0 then
        amount_string = "None"
    else
        amount_string = format("%d (%d%% DR)", integer_amount, round(value:GetDamageReductionInPercents(), 0))
    end

    tooltip:AddValue("Armor", amount_string, false)
end
