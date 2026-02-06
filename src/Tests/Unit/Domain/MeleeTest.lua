-- MeleeTest.lua
-- Tests for MeleeVO domain object

local lu = require('luaunit')
require('src.Tests.Support.Mocks.MockEnvironment')

TestMelee = {}

-- Test constants
local ATTACK_SPEED_MAIN = 2.0
local ATTACK_SPEED_OFF = 2.5
local ATTACK_SPEED_SLOW = 1.5
local MIN_DAMAGE_MAIN = 100
local MAX_DAMAGE_MAIN = 200
local MIN_DAMAGE_OFF = 50
local MAX_DAMAGE_OFF = 100
local MIN_DAMAGE_SMALL = 30
local MAX_DAMAGE_SMALL = 60

-- Helper to create a valid DamageVO
local function createDamageVO(attack_speed, min_damage, max_damage)
    return MobStats.DamageVO:Construct(attack_speed, min_damage, max_damage)
end

-- Test: Construction with main hand only
function TestMelee:test_construct_with_main_hand_only()
    local mainHand = createDamageVO(ATTACK_SPEED_MAIN, MIN_DAMAGE_MAIN, MAX_DAMAGE_MAIN)
    local melee = MobStats.MeleeVO:Construct(mainHand, nil)

    lu.assertNotNil(melee)
    lu.assertEquals(melee:GetMainHandDamage(), mainHand)
    lu.assertNil(melee:GetOffhandDamage())
end

-- Test: Construction with main hand and offhand
function TestMelee:test_construct_with_main_hand_and_offhand()
    local mainHand = createDamageVO(ATTACK_SPEED_MAIN, MIN_DAMAGE_MAIN, MAX_DAMAGE_MAIN)
    local offhand = createDamageVO(ATTACK_SPEED_OFF, MIN_DAMAGE_OFF, MAX_DAMAGE_OFF)
    local melee = MobStats.MeleeVO:Construct(mainHand, offhand)

    lu.assertNotNil(melee)
    lu.assertEquals(melee:GetMainHandDamage(), mainHand)
    lu.assertEquals(melee:GetOffhandDamage(), offhand)
end

-- Test: Construction with nil main hand returns nil
function TestMelee:test_construct_with_nil_main_hand_returns_nil()
    local melee = MobStats.MeleeVO:Construct(nil, nil)

    lu.assertNil(melee)
end

-- Test: Construction with nil main hand but valid offhand still returns nil
function TestMelee:test_construct_with_nil_main_hand_and_valid_offhand_returns_nil()
    local offhand = createDamageVO(ATTACK_SPEED_OFF, MIN_DAMAGE_OFF, MAX_DAMAGE_OFF)
    local melee = MobStats.MeleeVO:Construct(nil, offhand)

    lu.assertNil(melee)
end

-- Test: Main hand damage values are accessible
function TestMelee:test_main_hand_damage_values_accessible()
    local mainHand = createDamageVO(ATTACK_SPEED_MAIN, MIN_DAMAGE_MAIN, MAX_DAMAGE_MAIN)
    local melee = MobStats.MeleeVO:Construct(mainHand, nil)

    lu.assertEquals(melee:GetMainHandDamage():GetAttackSpeed(), ATTACK_SPEED_MAIN)
    lu.assertEquals(melee:GetMainHandDamage():GetMinDamage(), MIN_DAMAGE_MAIN)
    lu.assertEquals(melee:GetMainHandDamage():GetMaxDamage(), MAX_DAMAGE_MAIN)
    local expected_dps = ((MIN_DAMAGE_MAIN + MAX_DAMAGE_MAIN) / 2.0) / ATTACK_SPEED_MAIN
    lu.assertEquals(melee:GetMainHandDamage():GetDPS(), expected_dps)
end

-- Test: Offhand damage values are accessible when present
function TestMelee:test_offhand_damage_values_accessible()
    local mainHand = createDamageVO(ATTACK_SPEED_MAIN, MIN_DAMAGE_MAIN, MAX_DAMAGE_MAIN)
    local offhand = createDamageVO(ATTACK_SPEED_SLOW, MIN_DAMAGE_SMALL, MAX_DAMAGE_SMALL)
    local melee = MobStats.MeleeVO:Construct(mainHand, offhand)

    lu.assertEquals(melee:GetOffhandDamage():GetAttackSpeed(), ATTACK_SPEED_SLOW)
    lu.assertEquals(melee:GetOffhandDamage():GetMinDamage(), MIN_DAMAGE_SMALL)
    lu.assertEquals(melee:GetOffhandDamage():GetMaxDamage(), MAX_DAMAGE_SMALL)
    local expected_dps = ((MIN_DAMAGE_SMALL + MAX_DAMAGE_SMALL) / 2.0) / ATTACK_SPEED_SLOW
    lu.assertEquals(melee:GetOffhandDamage():GetDPS(), expected_dps)
end

-- Note: MeleeVO does not validate types of its parameters.
-- The following tests document this behavior - invalid types are accepted
-- but will cause errors when DamageVO methods are called on them.

-- Test: String passed as main hand is accepted (no type validation)
function TestMelee:test_string_as_main_hand_accepted()
    -- MeleeVO does not validate types, so string is accepted
    local melee = MobStats.MeleeVO:Construct("not a damage vo", nil)

    lu.assertNotNil(melee)
    lu.assertEquals(melee:GetMainHandDamage(), "not a damage vo")
end

-- Test: Number passed as main hand is accepted (no type validation)
function TestMelee:test_number_as_main_hand_accepted()
    -- MeleeVO does not validate types, so number is accepted
    local melee = MobStats.MeleeVO:Construct(12345, nil)

    lu.assertNotNil(melee)
    lu.assertEquals(melee:GetMainHandDamage(), 12345)
end

-- Test: Table without DamageVO methods passed as main hand is accepted
function TestMelee:test_plain_table_as_main_hand_accepted()
    -- MeleeVO does not validate types, so plain table is accepted
    local fakeDamage = { attack_speed = 2.0, min = 100, max = 200 }
    local melee = MobStats.MeleeVO:Construct(fakeDamage, nil)

    lu.assertNotNil(melee)
    lu.assertEquals(melee:GetMainHandDamage(), fakeDamage)
end

-- Test: String passed as offhand is accepted (no type validation)
function TestMelee:test_string_as_offhand_accepted()
    local mainHand = createDamageVO(ATTACK_SPEED_MAIN, MIN_DAMAGE_MAIN, MAX_DAMAGE_MAIN)
    local melee = MobStats.MeleeVO:Construct(mainHand, "not a damage vo")

    lu.assertNotNil(melee)
    lu.assertEquals(melee:GetOffhandDamage(), "not a damage vo")
end

return TestMelee
