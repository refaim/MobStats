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

    -- TODO add hit chance

    -- TODO support negative resistances and spell penetration: https://github.com/vmangos/core/blob/5e142e104c8033cd0505cf8e060f37e263f503fe/src/game/Objects/SpellCaster.cpp#L611
    if amount < 0 then
        amount = 0
    end

    -- https://github.com/vmangos/core/blob/5e142e104c8033cd0505cf8e060f37e263f503fe/src/game/Objects/SpellCaster.cpp#L629
    local target_level = target_level_vo:GetEstimatedValue()
    if target_level > caster_level then
        amount = amount + (target_level - caster_level) * 8
    end

    -- TODO recalculate as in vmangos: https://github.com/vmangos/core/blob/5e142e104c8033cd0505cf8e060f37e263f503fe/src/game/Objects/SpellCaster.cpp#L596
    -- https://wowwiki-archive.fandom.com/wiki/Formulas:Magical_resistance?oldid=295639
    local chance = amount / (max(20, caster_level) * 5) * 100
    if chance < 0 then
        chance = 0
    end
    if chance > 75 then
        chance = 75
    end

    local could_be_higher = chance < 75 and target_level_vo:CouldBeHigher()

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
