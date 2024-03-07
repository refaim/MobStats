setfenv(1, MobStats)

---@alias ResistanceId "arcane" | "fire" | "frost" | "holy" | "nature" | "shadow"

---@class ResistanceVO
---@field _id ResistanceId
---@field _average_resistance_in_percents number
ResistanceVO = {}

---@param id ResistanceId
---@param amount number
---@param caster_level number
---@param target_level number
---@return ResistanceVO
function ResistanceVO:Construct(id, amount, caster_level, target_level)
    assert(type(id) == "string" and id ~= "")
    assert(type(amount) == "number")

    -- TODO add hit chance

    -- TODO support negative resistances and spell penetration: https://github.com/vmangos/core/blob/5e142e104c8033cd0505cf8e060f37e263f503fe/src/game/Objects/SpellCaster.cpp#L611
    if amount < 0 then
        amount = 0
    end

    -- https://github.com/vmangos/core/blob/5e142e104c8033cd0505cf8e060f37e263f503fe/src/game/Objects/SpellCaster.cpp#L629
    if target_level > caster_level then
        amount = amount + 8.0 * (target_level - caster_level)
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

    local object = new(ResistanceVO)
    object._id = id
    object._average_resistance_in_percents = chance
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
