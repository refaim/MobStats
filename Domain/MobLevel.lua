setfenv(1, MobStats)

---@class MobLevelVO
---@field _estimated_value number
---@field _could_be_higher boolean
MobLevelVO = {}

local MAX_REGULAR_LEVEL = 60
local MAX_BOSS_LEVEL = 63

---@param player_level number
---@param raw_mob_level number
---@param is_skull_mob boolean
---@param is_world_boss boolean
---@return MobLevelVO
function MobLevelVO:Construct(player_level, raw_mob_level, is_skull_mob, is_world_boss)
    assert(type(player_level) == "number" and player_level > 0)
    assert(type(raw_mob_level) == "number")
    assert(type(is_skull_mob) == "boolean")
    assert(type(is_world_boss) == "boolean")

    local could_be_higher
    local estimated_level
    if raw_mob_level > 0 then
        estimated_level = raw_mob_level
        could_be_higher = false
    elseif is_world_boss then
        estimated_level = MAX_BOSS_LEVEL
        could_be_higher = false
    elseif is_skull_mob then
        estimated_level = min(player_level + 10, MAX_REGULAR_LEVEL)
        could_be_higher = estimated_level < MAX_REGULAR_LEVEL
    end

    local object = new(MobLevelVO)
    object._estimated_value = estimated_level
    object._could_be_higher = could_be_higher
    return object
end

---@return number
function MobLevelVO:GetEstimatedValue()
    return self._estimated_value
end

function MobLevelVO:CouldValueBeHigherThanEstimated()
    return self._could_be_higher
end
