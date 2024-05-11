setfenv(1, MobStats)

---@class GameAPI
GameAPI = {}

---@param n number|nil
local function zero_to_nil(n)
    if n == 0 then
        return nil
    end
    return n
end

---@return number
function GameAPI:GetPlayerLevel()
    local level = self:GetUnitLevel("player")
    assert(not level.is_skull)
    return level.value
end

---@shape UnitLevelInfrastructureDTO
---@field value number
---@field is_skull boolean
---@field is_world_boss boolean

---@param unit UnitId
---@return UnitLevelInfrastructureDTO
function GameAPI:GetUnitLevel(unit)
    local value = UnitLevel(unit)
    return {
        value = value,
        is_skull = value == -1,
        is_world_boss = UnitClassification(unit) == "worldboss",
    }
end

---@param unit UnitId
---@return boolean
function GameAPI:IsMob(unit)
    return UnitCanAttack("player", unit) == 1
       and UnitIsFriend("player", unit) == nil
       and UnitIsPlayer(unit) == nil
end

---@param unit UnitId
---@return number
function GameAPI:GetArmor(unit)
    local _, effective, _, _ = UnitResistance(unit, 0)
    return max(0, effective)
end

---@shape ResistanceInfrastructureDTO
---@field id ResistanceId
---@field amount number

---@alias ResistanceInfrastructureIndex 0|1|2|3|4|5|6

---@type table<ResistanceId, ResistanceInfrastructureIndex>
local RESISTANCE_ID_TO_INDEX = {
    holy = 1,
    fire = 2,
    nature = 3,
    frost = 4,
    shadow = 5,
    arcane = 6,
}

---@param unit UnitId
---@return ResistanceInfrastructureDTO[]
function GameAPI:GetResistances(unit)
    local result = {}
    for id, index in pairs(RESISTANCE_ID_TO_INDEX) do
        local _, effective, _, _ = UnitResistance(unit, index)
        ---@type ResistanceInfrastructureDTO
        local dto = { id = id, amount = effective }
        tinsert(result, dto)
    end
    return result
end

---@shape DamageInfrastructureDTO
---@field attack_speed number
---@field min_damage number
---@field max_damage number

---@shape MeleeInfrastructureDTO
---@field main_hand DamageInfrastructureDTO|nil
---@field offhand DamageInfrastructureDTO|nil

---@param raw_attack_speed number|nil
---@param raw_min_damage number|nil
---@param raw_max_damage number|nil
---@return DamageInfrastructureDTO|nil
local function make_damage_dto(raw_attack_speed, raw_min_damage, raw_max_damage)
    raw_attack_speed = zero_to_nil(raw_attack_speed)
    raw_min_damage = zero_to_nil(raw_min_damage)
    raw_max_damage = zero_to_nil(raw_max_damage)

    if raw_attack_speed == nil or raw_min_damage == nil or raw_max_damage == nil then
        return nil
    end

    local attack_speed = --[[---@type number]] raw_attack_speed
    local min_damage = --[[---@type number]] raw_min_damage
    local max_damage = --[[---@type number]] raw_max_damage

    return {
        attack_speed = attack_speed,
        min_damage = min_damage,
        max_damage = max_damage,
    }
end

---@param unit UnitId
---@return MeleeInfrastructureDTO
function GameAPI:GetMelee(unit)
    local main_hand_attack_speed, offhand_attack_speed = UnitAttackSpeed(unit)
    local main_hand_min_damage, main_hand_max_damage, offhand_min_damage, offhand_max_damage, _, _, _ = UnitDamage(unit)
    return {
        main_hand = make_damage_dto(main_hand_attack_speed, main_hand_min_damage, main_hand_max_damage),
        offhand = make_damage_dto(offhand_attack_speed, offhand_min_damage, offhand_max_damage),
    }
end
