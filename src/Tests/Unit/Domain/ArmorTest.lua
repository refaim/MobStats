-- ArmorTest.lua
-- Tests for ArmorVO domain object

local lu = require("luaunit")
require("src.Tests.Support.Mocks.MockEnvironment")

TestArmor = {}

-- Test constants
local PLAYER_LEVEL_1 = 1
local PLAYER_LEVEL_60 = 60
local ARMOR_ZERO = 0
local ARMOR_LOW = 100
local ARMOR_MEDIUM = 1000
local ARMOR_VERY_HIGH = 100000

-- Test: Basic construction with valid values
function TestArmor:test_construct_with_valid_values()
    local armor = MobStats.ArmorVO:Construct(ARMOR_MEDIUM, PLAYER_LEVEL_60)

    lu.assertEquals(armor:GetAmount(), ARMOR_MEDIUM)
end

-- Test: Zero armor is valid
function TestArmor:test_construct_with_zero_armor()
    local armor = MobStats.ArmorVO:Construct(ARMOR_ZERO, PLAYER_LEVEL_60)

    lu.assertEquals(armor:GetAmount(), 0)
    lu.assertEquals(armor:GetDamageReductionInPercents(), 0)
end

-- Test: Damage reduction calculation for level 60 player
function TestArmor:test_damage_reduction_level_60()
    -- Formula: (armor / (armor + 400 + 85 * player_level)) * 100
    -- For 1000 armor, level 60: (1000 / (1000 + 400 + 85*60)) * 100
    -- = (1000 / (1000 + 400 + 5100)) * 100 = (1000 / 6500) * 100 = 15.384...
    local armor = MobStats.ArmorVO:Construct(ARMOR_MEDIUM, PLAYER_LEVEL_60)

    local expected_dr = (ARMOR_MEDIUM / (ARMOR_MEDIUM + 400 + 85 * PLAYER_LEVEL_60)) * 100
    lu.assertAlmostEquals(armor:GetDamageReductionInPercents(), expected_dr, 0.001)
end

-- Test: Damage reduction calculation for level 1 player
function TestArmor:test_damage_reduction_level_1()
    -- Formula: (armor / (armor + 400 + 85 * player_level)) * 100
    -- For 100 armor, level 1: (100 / (100 + 400 + 85*1)) * 100
    -- = (100 / (100 + 400 + 85)) * 100 = (100 / 585) * 100
    local armor = MobStats.ArmorVO:Construct(ARMOR_LOW, PLAYER_LEVEL_1)

    local expected_dr = (ARMOR_LOW / (ARMOR_LOW + 400 + 85 * PLAYER_LEVEL_1)) * 100
    lu.assertAlmostEquals(armor:GetDamageReductionInPercents(), expected_dr, 0.001)
end

-- Test: High armor approaches but never reaches 100%
function TestArmor:test_high_armor_approaches_100_percent()
    -- Formula: (armor / (armor + 400 + 85 * player_level)) * 100
    -- For 100000 armor, level 60: (100000 / (100000 + 400 + 5100)) * 100
    -- = (100000 / 105500) * 100 = 94.786...
    local armor = MobStats.ArmorVO:Construct(ARMOR_VERY_HIGH, PLAYER_LEVEL_60)

    local expected_dr = (ARMOR_VERY_HIGH / (ARMOR_VERY_HIGH + 400 + 85 * PLAYER_LEVEL_60)) * 100
    lu.assertAlmostEquals(armor:GetDamageReductionInPercents(), expected_dr, 0.001)
end

-- Test: Invalid negative armor throws error
function TestArmor:test_negative_armor_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.ArmorVO:Construct(-1, PLAYER_LEVEL_60)
    end)
end

-- Test: Invalid nil armor throws error
function TestArmor:test_nil_armor_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.ArmorVO:Construct(nil, PLAYER_LEVEL_60)
    end)
end

-- Test: Invalid zero player level throws error
function TestArmor:test_zero_player_level_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.ArmorVO:Construct(ARMOR_MEDIUM, 0)
    end)
end

-- Test: Invalid negative player level throws error
function TestArmor:test_negative_player_level_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.ArmorVO:Construct(ARMOR_MEDIUM, -1)
    end)
end

-- Test: Invalid nil player level throws error
function TestArmor:test_nil_player_level_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.ArmorVO:Construct(ARMOR_MEDIUM, nil)
    end)
end

-- Test: Non-number armor throws error
function TestArmor:test_non_number_armor_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.ArmorVO:Construct("1000", PLAYER_LEVEL_60)
    end)
end

-- Test: Non-number player level throws error
function TestArmor:test_non_number_player_level_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.ArmorVO:Construct(ARMOR_MEDIUM, "60")
    end)
end

return TestArmor
