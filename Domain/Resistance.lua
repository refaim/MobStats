setfenv(1, MobStats)

---@alias ResistanceId "arcane" | "fire" | "frost" | "holy" | "nature" | "shadow"

---@class ResistanceVO
---@field _id ResistanceId
---@field _average_resistance_in_percents number
---@field _could_be_higher boolean
ResistanceVO = {}

---@param id ResistanceId
---@param amount number
---@param caster_level number
---@param target_level_vo MobLevelVO
---@return ResistanceVO
function ResistanceVO:Construct(id, amount, caster_level, target_level_vo)
    assert(type(id) == "string" and id ~= "")
    assert(type(amount) == "number")
    assert(type(caster_level) == "number" and caster_level > 0)

    if amount < 0 then
        amount = 0
    end

    local apply_level_based_resistance = true
    if id == "holy" and Environment:IsPlayingOnTurtleWoW() then
        apply_level_based_resistance = false -- https://forum.turtle-wow.org/viewtopic.php?p=27521
    end

    -- https://github.com/vmangos/core/blob/5e142e104c8033cd0505cf8e060f37e263f503fe/src/game/Objects/SpellCaster.cpp#L629
    local target_level = target_level_vo:GetEstimatedValue()
    if apply_level_based_resistance and target_level > caster_level then
        amount = amount + (target_level - caster_level) * 8
    end

    -- https://wowwiki-archive.fandom.com/wiki/Formulas:Magical_resistance?oldid=295639
    local cap = max(20, caster_level) * 5
    local ratio = amount / cap
    -- https://royalgiraffe.github.io/resist-guide
    local average_mitigation = 0.75 * ratio - (3/16) * max(0, ratio - 2/3)
    local chance = average_mitigation * 100
    local could_be_higher = chance < 68.75
        and amount < cap
        and target_level_vo:CouldValueBeHigherThanEstimated()

    local object = new(ResistanceVO)
    object._id = id
    object._average_resistance_in_percents = chance
    object._could_be_higher = could_be_higher
    return object
end

---@return ResistanceId
function ResistanceVO:GetId()
    return self._id
end

---@return number
function ResistanceVO:GetAverageResistanceInPercents()
    return self._average_resistance_in_percents
end

---@return boolean
function ResistanceVO:CouldBeHigher()
    return self._could_be_higher
end
