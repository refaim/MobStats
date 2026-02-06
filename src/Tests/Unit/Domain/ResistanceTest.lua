-- ResistanceTest.lua
-- Tests for ResistanceVO domain object

local lu = require("luaunit")
require("src.Tests.Support.Mocks.MockEnvironment")

TestResistance = {}

-- Test constants
local CASTER_LEVEL_10 = 10
local CASTER_LEVEL_60 = 60
local RESISTANCE_ZERO = 0
local RESISTANCE_NEGATIVE = -50
local RESISTANCE_LOW = 50
local RESISTANCE_MEDIUM = 100
local RESISTANCE_AT_TWO_THIRDS_CAP = 200
local RESISTANCE_AT_CAP = 300
local MOB_LEVEL_40 = 40
local MOB_LEVEL_55 = 55
local MOB_LEVEL_60 = 60
local SKULL_MOB_PLAYER_LEVEL = 30
local RESISTANCE_CAP_LEVEL_60 = 300 -- max(20, 60) * 5
local RESISTANCE_CAP_LEVEL_10 = 100 -- max(20, 10) * 5
local EXPECTED_RESISTANCE_AT_CAP = 68.75
local EXPECTED_RESISTANCE_AT_TWO_THIRDS = 50
local EXPECTED_LEVEL_BASED_RESISTANCE = 6 -- 3 levels * 8 resistance = 24, 24/300 * 0.75 * 100 = 6%

local originalEnvironment

function TestResistance:setUp()
    originalEnvironment = MobStats.Environment
    MobStats.Environment = {
        IsPlayingOnTurtleWoW = function()
            return false
        end,
    }
end

function TestResistance:tearDown()
    MobStats.Environment = originalEnvironment
end

-- Helper to create MobLevelVO with a fixed known level.
-- When could_be_higher is true, creates a skull mob scenario where the
-- estimated level is (level) but could potentially be higher.
-- The skull mob is created with player_level = level - 10, so
-- estimated = min(player_level + 10, 60) = level.
local function createMobLevel(level, could_be_higher)
    local mob_level = MobStats.MobLevelVO:Construct(CASTER_LEVEL_60, level, false, false)
    if could_be_higher then
        -- Create skull mob scenario where level could be higher
        -- Player level is set to (level - 10) so estimated becomes level
        mob_level = MobStats.MobLevelVO:Construct(level - 10, -1, true, false)
    end
    return mob_level
end

-- Test: Basic construction
function TestResistance:test_construct_basic()
    local mob_level = createMobLevel(MOB_LEVEL_60, false)
    local resistance = MobStats.ResistanceVO:Construct("fire", RESISTANCE_MEDIUM, CASTER_LEVEL_60, mob_level)

    lu.assertEquals(resistance:GetId(), "fire")
end

-- Test: Zero resistance
function TestResistance:test_zero_resistance()
    local mob_level = createMobLevel(MOB_LEVEL_60, false)
    local resistance = MobStats.ResistanceVO:Construct("fire", RESISTANCE_ZERO, CASTER_LEVEL_60, mob_level)

    lu.assertEquals(resistance:GetAverageResistanceInPercents(), 0)
end

-- Test: Negative resistance is treated as zero
function TestResistance:test_negative_resistance_treated_as_zero()
    local mob_level = createMobLevel(MOB_LEVEL_60, false)
    local resistance = MobStats.ResistanceVO:Construct("fire", RESISTANCE_NEGATIVE, CASTER_LEVEL_60, mob_level)

    lu.assertEquals(resistance:GetAverageResistanceInPercents(), 0)
end

-- Test: Resistance calculation at cap
function TestResistance:test_resistance_at_cap()
    -- Cap for level 60 = max(20, 60) * 5 = 300
    -- At cap (ratio = 1): average_mitigation = 0.75 * 1 - (3/16) * max(0, 1 - 2/3)
    -- = 0.75 - (3/16) * (1/3) = 0.75 - 0.0625 = 0.6875
    -- chance = 0.6875 * 100 = 68.75
    local mob_level = createMobLevel(MOB_LEVEL_60, false)
    local resistance = MobStats.ResistanceVO:Construct("fire", RESISTANCE_AT_CAP, CASTER_LEVEL_60, mob_level)

    lu.assertAlmostEquals(resistance:GetAverageResistanceInPercents(), EXPECTED_RESISTANCE_AT_CAP, 0.01)
end

-- Test: Resistance above cap continues to increase (ratio > 1.0)
function TestResistance:test_resistance_above_cap()
    -- Cap for level 60 = 300, resistance = 450, ratio = 1.5
    -- average_mitigation = 0.75 * 1.5 - (3/16) * (1.5 - 2/3)
    -- = 1.125 - 0.1875 * 0.833... = 1.125 - 0.15625 = 0.96875
    -- chance = 96.875%
    local mob_level = createMobLevel(MOB_LEVEL_60, false)
    local resistance = MobStats.ResistanceVO:Construct("fire", 450, CASTER_LEVEL_60, mob_level)

    lu.assertAlmostEquals(resistance:GetAverageResistanceInPercents(), 96.875, 0.01)
end

-- Test: Resistance calculation at 2/3 of cap
function TestResistance:test_resistance_at_two_thirds_cap()
    -- Cap for level 60 = 300
    -- At 2/3 of cap (200), ratio = 200/300 = 0.667
    -- average_mitigation = 0.75 * 0.667 - (3/16) * max(0, 0.667 - 0.667) = 0.5
    -- chance = 0.5 * 100 = 50
    local mob_level = createMobLevel(MOB_LEVEL_60, false)
    local resistance = MobStats.ResistanceVO:Construct("fire", RESISTANCE_AT_TWO_THIRDS_CAP, CASTER_LEVEL_60, mob_level)

    lu.assertAlmostEquals(resistance:GetAverageResistanceInPercents(), EXPECTED_RESISTANCE_AT_TWO_THIRDS, 0.01)
end

-- Test: Level-based resistance (target level > caster level)
function TestResistance:test_level_based_resistance()
    -- Mob level 63, caster level 60
    -- Level difference = 3, adds 3 * 8 = 24 resistance
    -- Base resistance 0 becomes 24
    -- Cap = 300, ratio = 24/300 = 0.08
    -- average_mitigation = 0.75 * 0.08 = 0.06
    -- chance = 6%
    local mob_level = MobStats.MobLevelVO:Construct(CASTER_LEVEL_60, -1, true, true) -- World boss level 63
    local resistance = MobStats.ResistanceVO:Construct("fire", RESISTANCE_ZERO, CASTER_LEVEL_60, mob_level)

    lu.assertAlmostEquals(resistance:GetAverageResistanceInPercents(), EXPECTED_LEVEL_BASED_RESISTANCE, 0.01)
end

-- Test: No level-based resistance when caster level >= target level
function TestResistance:test_no_level_based_resistance_when_equal()
    local mob_level = createMobLevel(MOB_LEVEL_60, false)
    local resistance = MobStats.ResistanceVO:Construct("fire", RESISTANCE_ZERO, CASTER_LEVEL_60, mob_level)

    lu.assertEquals(resistance:GetAverageResistanceInPercents(), 0)
end

-- Test: CouldBeHigher is true when conditions are met
function TestResistance:test_could_be_higher_true()
    -- Create mob level that could be higher (skull mob)
    local mob_level = MobStats.MobLevelVO:Construct(SKULL_MOB_PLAYER_LEVEL, -1, true, false) -- Skull, estimated 40, could be higher

    -- Resistance below cap
    local resistance = MobStats.ResistanceVO:Construct("fire", RESISTANCE_LOW, CASTER_LEVEL_60, mob_level)

    -- Should be true: chance < 68.75, amount < cap, and mob level could be higher
    lu.assertEquals(resistance:CouldBeHigher(), true)
end

-- Test: CouldBeHigher is false when at cap
function TestResistance:test_could_be_higher_false_at_cap()
    local mob_level = MobStats.MobLevelVO:Construct(SKULL_MOB_PLAYER_LEVEL, -1, true, false) -- Skull, could be higher
    local resistance = MobStats.ResistanceVO:Construct("fire", RESISTANCE_AT_CAP, CASTER_LEVEL_60, mob_level)

    -- At cap (68.75%), should be false
    lu.assertEquals(resistance:CouldBeHigher(), false)
end

-- Test: CouldBeHigher is false when mob level cannot be higher
function TestResistance:test_could_be_higher_false_when_level_fixed()
    local mob_level = createMobLevel(MOB_LEVEL_55, false) -- Fixed level
    local resistance = MobStats.ResistanceVO:Construct("fire", RESISTANCE_LOW, CASTER_LEVEL_60, mob_level)

    lu.assertEquals(resistance:CouldBeHigher(), false)
end

-- Test: Holy resistance on Turtle WoW (no level-based resistance)
function TestResistance:test_holy_resistance_turtle_wow_no_level_based()
    MobStats.Environment = {
        IsPlayingOnTurtleWoW = function()
            return true
        end,
    }

    -- Mob level 63 (world boss), caster level 60
    -- On Turtle WoW, holy should NOT add level-based resistance
    local mob_level = MobStats.MobLevelVO:Construct(CASTER_LEVEL_60, -1, true, true) -- World boss level 63
    local resistance = MobStats.ResistanceVO:Construct("holy", RESISTANCE_ZERO, CASTER_LEVEL_60, mob_level)

    -- Should be 0 because no level-based resistance for holy on Turtle WoW
    lu.assertEquals(resistance:GetAverageResistanceInPercents(), 0)
end

-- Test: Non-holy resistance on Turtle WoW still gets level-based resistance
function TestResistance:test_fire_resistance_turtle_wow_with_level_based()
    MobStats.Environment = {
        IsPlayingOnTurtleWoW = function()
            return true
        end,
    }

    local mob_level = MobStats.MobLevelVO:Construct(CASTER_LEVEL_60, -1, true, true) -- World boss level 63
    local resistance = MobStats.ResistanceVO:Construct("fire", RESISTANCE_ZERO, CASTER_LEVEL_60, mob_level)

    -- Should have level-based resistance (6%)
    lu.assertAlmostEquals(resistance:GetAverageResistanceInPercents(), EXPECTED_LEVEL_BASED_RESISTANCE, 0.01)
end

-- Test: Holy resistance on non-Turtle WoW gets level-based resistance
function TestResistance:test_holy_resistance_non_turtle_wow()
    MobStats.Environment = {
        IsPlayingOnTurtleWoW = function()
            return false
        end,
    }

    local mob_level = MobStats.MobLevelVO:Construct(CASTER_LEVEL_60, -1, true, true) -- World boss level 63
    local resistance = MobStats.ResistanceVO:Construct("holy", RESISTANCE_ZERO, CASTER_LEVEL_60, mob_level)

    -- Should have level-based resistance (6%)
    lu.assertAlmostEquals(resistance:GetAverageResistanceInPercents(), EXPECTED_LEVEL_BASED_RESISTANCE, 0.01)
end

-- Test: Low level caster (cap uses minimum of 20)
function TestResistance:test_low_level_caster_cap()
    -- Cap for level 10 = max(20, 10) * 5 = 100
    local mob_level = createMobLevel(CASTER_LEVEL_10, false)
    local resistance = MobStats.ResistanceVO:Construct("fire", RESISTANCE_CAP_LEVEL_10, CASTER_LEVEL_10, mob_level)

    -- At cap (ratio = 1): 68.75%
    lu.assertAlmostEquals(resistance:GetAverageResistanceInPercents(), EXPECTED_RESISTANCE_AT_CAP, 0.01)
end

-- Test: Invalid empty id throws error
function TestResistance:test_empty_id_throws()
    local mob_level = createMobLevel(MOB_LEVEL_60, false)
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.ResistanceVO:Construct("", RESISTANCE_MEDIUM, CASTER_LEVEL_60, mob_level)
    end)
end

-- Test: Invalid zero caster level throws error
function TestResistance:test_zero_caster_level_throws()
    local mob_level = createMobLevel(MOB_LEVEL_60, false)
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.ResistanceVO:Construct("fire", RESISTANCE_MEDIUM, 0, mob_level)
    end)
end

-- Test: Non-string id throws error
function TestResistance:test_non_string_id_throws()
    local mob_level = createMobLevel(MOB_LEVEL_60, false)
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.ResistanceVO:Construct(123, RESISTANCE_MEDIUM, CASTER_LEVEL_60, mob_level)
    end)
end

-- Test: Non-number amount throws error
function TestResistance:test_non_number_amount_throws()
    local mob_level = createMobLevel(MOB_LEVEL_60, false)
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.ResistanceVO:Construct("fire", "100", CASTER_LEVEL_60, mob_level)
    end)
end

-- Test: Non-number caster level throws error
function TestResistance:test_non_number_caster_level_throws()
    local mob_level = createMobLevel(MOB_LEVEL_60, false)
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.ResistanceVO:Construct("fire", RESISTANCE_MEDIUM, "60", mob_level)
    end)
end

-- Test: Nil id throws error
function TestResistance:test_nil_id_throws()
    local mob_level = createMobLevel(MOB_LEVEL_60, false)
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.ResistanceVO:Construct(nil, RESISTANCE_MEDIUM, CASTER_LEVEL_60, mob_level)
    end)
end

-- Test: Nil amount throws error
function TestResistance:test_nil_amount_throws()
    local mob_level = createMobLevel(MOB_LEVEL_60, false)
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.ResistanceVO:Construct("fire", nil, CASTER_LEVEL_60, mob_level)
    end)
end

-- Test: Nil caster level throws error
function TestResistance:test_nil_caster_level_throws()
    local mob_level = createMobLevel(MOB_LEVEL_60, false)
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.ResistanceVO:Construct("fire", RESISTANCE_MEDIUM, nil, mob_level)
    end)
end

-- Test: Nil mob_level causes error when accessing its methods
function TestResistance:test_nil_mob_level_throws()
    lu.assertError(function()
        MobStats.ResistanceVO:Construct("fire", RESISTANCE_MEDIUM, CASTER_LEVEL_60, nil)
    end)
end

return TestResistance
