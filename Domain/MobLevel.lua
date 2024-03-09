setfenv(1, MobStats)

---@class MobLevelVO
---@field _estimated_value number
---@field _could_be_higher boolean
MobLevelVO = {}

---@param player_level number
---@param raw_mob_level number
---@param is_skull_mob boolean
---@return MobLevelVO
function MobLevelVO:Construct(player_level, raw_mob_level, is_skull_mob)
    assert(type(player_level) == "number" and player_level > 0)
    assert(type(raw_mob_level) == "number")
    assert(type(is_skull_mob) == "boolean")

    local could_be_higher
    local estimated_level
    if is_skull_mob then
        estimated_level = min(63, player_level + 10)
        could_be_higher = true
        assert(raw_mob_level == -1)
    else
        estimated_level = raw_mob_level
        could_be_higher = false
        assert(raw_mob_level > 0)
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

function MobLevelVO:CouldBeHigher()
    return self._could_be_higher
end
