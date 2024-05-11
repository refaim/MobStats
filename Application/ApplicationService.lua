setfenv(1, MobStats)

---@class ApplicationService
ApplicationService = {}

---@shape MobStatsApplicationDTO
---@field armor ArmorVO
---@field melee MeleeVO|nil
---@field resistances ResistanceVO[]

---@param dto_or_nil DamageInfrastructureDTO|nil
---@return DamageVO|nil
local function make_damage_vo(dto_or_nil)
    local vo
    if dto_or_nil ~= nil then
        local dto = --[[---@type DamageInfrastructureDTO]] dto_or_nil
        vo = DamageVO:Construct(dto.attack_speed, dto.min_damage, dto.max_damage)
    end
    return vo
end

---@param unit UnitId
---@return MobStatsApplicationDTO|nil
function ApplicationService:GetMobStats(unit)
    if not GameAPI:IsMob(unit) then
        return nil
    end

    local player_level = GameAPI:GetPlayerLevel()

    local mob_level_dto = GameAPI:GetUnitLevel(unit)
    local mob_level_vo = MobLevelVO:Construct(
        player_level,
        mob_level_dto.value,
        mob_level_dto.is_skull,
        mob_level_dto.is_world_boss)

    local resistances = {}
    for _, dto in ipairs(GameAPI:GetResistances(unit)) do
        tinsert(resistances, ResistanceVO:Construct(dto.id, dto.amount, player_level, mob_level_vo))
    end

    local melee_dto = GameAPI:GetMelee(unit)
    return {
        armor = ArmorVO:Construct(GameAPI:GetArmor(unit), player_level),
        melee = MeleeVO:Construct(make_damage_vo(melee_dto.main_hand), make_damage_vo(melee_dto.offhand)),
        resistances = resistances,
    }
end
