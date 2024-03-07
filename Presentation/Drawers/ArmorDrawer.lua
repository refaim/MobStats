setfenv(1, MobStats)

---@class ArmorDrawer
ArmorDrawer = {}

---@param value ArmorVO
---@param tooltip TooltipInterface
function ArmorDrawer:Draw(value, tooltip)
    if value:GetAmount() == 0 then
        return 0
    end

    tooltip:AddValue(
        "Armor",
        format("%s (%s%% DR)",
            round(value:GetAmount(), 0),
            round(value:GetDamageReductionInPercents(), 0)),
        false)
end
