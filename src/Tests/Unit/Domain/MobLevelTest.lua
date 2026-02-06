-- MobLevelTest.lua
-- Tests for MobLevelVO domain object

local lu = require('luaunit')
require('src.Tests.Support.Mocks.MockEnvironment')

TestMobLevel = {}

-- Test constants
local PLAYER_LEVEL_1 = 1
local PLAYER_LEVEL_10 = 10
local PLAYER_LEVEL_30 = 30
local PLAYER_LEVEL_50 = 50
local PLAYER_LEVEL_60 = 60
local MOB_LEVEL_1 = 1
local MOB_LEVEL_55 = 55
local MOB_LEVEL_60 = 60
local MOB_LEVEL_UNKNOWN = -1
local MOB_LEVEL_ZERO = 0
local MOB_LEVEL_VERY_NEGATIVE = -100
local MAX_REGULAR_LEVEL = 60
local MAX_BOSS_LEVEL = 63

-- Test: Level 1 mob
function TestMobLevel:test_level_1_mob()
    local level = MobStats.MobLevelVO:Construct(PLAYER_LEVEL_10, MOB_LEVEL_1, false, false)

    lu.assertEquals(level:GetEstimatedValue(), MOB_LEVEL_1)
    lu.assertEquals(level:CouldValueBeHigherThanEstimated(), false)
end

-- Test: Level 60 mob (max regular level)
function TestMobLevel:test_level_60_mob()
    local level = MobStats.MobLevelVO:Construct(PLAYER_LEVEL_60, MOB_LEVEL_60, false, false)

    lu.assertEquals(level:GetEstimatedValue(), MOB_LEVEL_60)
    lu.assertEquals(level:CouldValueBeHigherThanEstimated(), false)
end

-- Test: World boss shows level 63
function TestMobLevel:test_world_boss_level()
    local level = MobStats.MobLevelVO:Construct(PLAYER_LEVEL_60, MOB_LEVEL_UNKNOWN, true, true)

    lu.assertEquals(level:GetEstimatedValue(), MAX_BOSS_LEVEL)
    lu.assertEquals(level:CouldValueBeHigherThanEstimated(), false)
end

-- Test: World boss flag takes priority over skull flag
function TestMobLevel:test_world_boss_priority_over_skull()
    -- When both is_skull_mob and is_world_boss are true, world boss takes priority
    -- Should be level 63, not skull calculation (player_level + 10)
    local level = MobStats.MobLevelVO:Construct(PLAYER_LEVEL_10, MOB_LEVEL_UNKNOWN, true, true)

    lu.assertEquals(level:GetEstimatedValue(), MAX_BOSS_LEVEL)
    lu.assertEquals(level:CouldValueBeHigherThanEstimated(), false)
end

-- Test: Skull mob for low level player (level 10)
function TestMobLevel:test_skull_mob_low_level_player()
    -- Skull mob for level 10 player: min(10 + 10, 60) = 20
    -- Could be higher because 20 < 60
    local level = MobStats.MobLevelVO:Construct(PLAYER_LEVEL_10, MOB_LEVEL_UNKNOWN, true, false)

    lu.assertEquals(level:GetEstimatedValue(), PLAYER_LEVEL_10 + 10)
    lu.assertEquals(level:CouldValueBeHigherThanEstimated(), true)
end

-- Test: Skull mob for mid level player (level 30)
function TestMobLevel:test_skull_mob_mid_level_player()
    -- Skull mob for level 30 player: min(30 + 10, 60) = 40
    -- Could be higher because 40 < 60
    local level = MobStats.MobLevelVO:Construct(PLAYER_LEVEL_30, MOB_LEVEL_UNKNOWN, true, false)

    lu.assertEquals(level:GetEstimatedValue(), PLAYER_LEVEL_30 + 10)
    lu.assertEquals(level:CouldValueBeHigherThanEstimated(), true)
end

-- Test: Skull mob for level 50 player (capped at 60)
function TestMobLevel:test_skull_mob_level_50_player()
    -- Skull mob for level 50 player: min(50 + 10, 60) = 60
    -- Could NOT be higher because 60 >= 60
    local level = MobStats.MobLevelVO:Construct(PLAYER_LEVEL_50, MOB_LEVEL_UNKNOWN, true, false)

    lu.assertEquals(level:GetEstimatedValue(), MAX_REGULAR_LEVEL)
    lu.assertEquals(level:CouldValueBeHigherThanEstimated(), false)
end

-- Test: Skull mob for level 60 player (capped at 60)
function TestMobLevel:test_skull_mob_level_60_player()
    -- Skull mob for level 60 player: min(60 + 10, 60) = 60
    -- Could NOT be higher because 60 >= 60
    local level = MobStats.MobLevelVO:Construct(PLAYER_LEVEL_60, MOB_LEVEL_UNKNOWN, true, false)

    lu.assertEquals(level:GetEstimatedValue(), MAX_REGULAR_LEVEL)
    lu.assertEquals(level:CouldValueBeHigherThanEstimated(), false)
end

-- Test: raw_mob_level = 0 with no skull/boss flags falls back to level 1
function TestMobLevel:test_raw_mob_level_zero_no_flags_fallback()
    local level = MobStats.MobLevelVO:Construct(PLAYER_LEVEL_60, MOB_LEVEL_ZERO, false, false)

    lu.assertEquals(level:GetEstimatedValue(), 1)
    lu.assertEquals(level:CouldValueBeHigherThanEstimated(), true)
end

-- Test: raw_mob_level = -2 with no skull/boss flags falls back to level 1
function TestMobLevel:test_raw_mob_level_negative_no_flags_fallback()
    local level = MobStats.MobLevelVO:Construct(PLAYER_LEVEL_60, -2, false, false)

    lu.assertEquals(level:GetEstimatedValue(), 1)
    lu.assertEquals(level:CouldValueBeHigherThanEstimated(), true)
end

-- Test: Very negative raw_mob_level with no flags falls back to level 1
function TestMobLevel:test_raw_mob_level_very_negative_no_flags_fallback()
    local level = MobStats.MobLevelVO:Construct(PLAYER_LEVEL_60, MOB_LEVEL_VERY_NEGATIVE, false, false)

    lu.assertEquals(level:GetEstimatedValue(), 1)
    lu.assertEquals(level:CouldValueBeHigherThanEstimated(), true)
end

-- Test: Invalid zero player level throws error
function TestMobLevel:test_zero_player_level_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.MobLevelVO:Construct(0, MOB_LEVEL_55, false, false)
    end)
end

-- Test: Invalid negative player level throws error
function TestMobLevel:test_negative_player_level_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.MobLevelVO:Construct(-1, MOB_LEVEL_55, false, false)
    end)
end

-- Test: Non-number player level throws error
function TestMobLevel:test_non_number_player_level_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.MobLevelVO:Construct("60", MOB_LEVEL_55, false, false)
    end)
end

-- Test: Non-number mob level throws error
function TestMobLevel:test_non_number_mob_level_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.MobLevelVO:Construct(PLAYER_LEVEL_60, "10", false, false)
    end)
end

-- Test: Non-boolean is_skull_mob throws error
function TestMobLevel:test_non_boolean_is_skull_mob_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.MobLevelVO:Construct(PLAYER_LEVEL_60, MOB_LEVEL_55, "false", false)
    end)
end

-- Test: Non-boolean is_world_boss throws error
function TestMobLevel:test_non_boolean_is_world_boss_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.MobLevelVO:Construct(PLAYER_LEVEL_60, MOB_LEVEL_55, false, "false")
    end)
end

-- Test: Nil player level throws error
function TestMobLevel:test_nil_player_level_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.MobLevelVO:Construct(nil, MOB_LEVEL_55, false, false)
    end)
end

-- Test: Nil mob level throws error
function TestMobLevel:test_nil_mob_level_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.MobLevelVO:Construct(PLAYER_LEVEL_60, nil, false, false)
    end)
end

-- Test: Nil is_skull_mob throws error
function TestMobLevel:test_nil_is_skull_mob_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.MobLevelVO:Construct(PLAYER_LEVEL_60, MOB_LEVEL_55, nil, false)
    end)
end

-- Test: Nil is_world_boss throws error
function TestMobLevel:test_nil_is_world_boss_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.MobLevelVO:Construct(PLAYER_LEVEL_60, MOB_LEVEL_55, false, nil)
    end)
end

return TestMobLevel
