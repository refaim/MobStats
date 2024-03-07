setfenv(1, MobStats)

---@class ArmorDrawer
ArmorDrawer = {}

---@param value ArmorVO
---@param tooltip TooltipInterface
function ArmorDrawer:Draw(value, tooltip)
    local amount = round(value:GetAmount(), 0)
    if amount == 0 then
        return
    end

    tooltip:AddValue(
        "Armor",
        format("%s (%s%% DR)", amount, round(value:GetDamageReductionInPercents(), 0)),
        false)
end
