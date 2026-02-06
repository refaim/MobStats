-- ApplicationServiceTest.lua
-- Integration tests for ApplicationService

local lu = require("luaunit")
require("src.Tests.Support.Mocks.MockEnvironment")

TestApplicationService = {}

-- Constants for test data
local PLAYER_LEVEL_MAX = 60
local MOB_LEVEL_REGULAR = 55
local MOB_LEVEL_SKULL = -1

local ARMOR_DEFAULT = 1000
local ARMOR_HIGH = 2000
local ARMOR_ZERO = 0

local MAIN_HAND_ATTACK_SPEED = 2.0
local MAIN_HAND_MIN_DAMAGE = 100
local MAIN_HAND_MAX_DAMAGE = 150
local OFFHAND_ATTACK_SPEED = 1.5
local OFFHAND_MIN_DAMAGE = 50
local OFFHAND_MAX_DAMAGE = 80

local ALT_MAIN_HAND_ATTACK_SPEED = 2.5
local ALT_MAIN_HAND_MIN_DAMAGE = 200
local ALT_MAIN_HAND_MAX_DAMAGE = 300

local FIRE_RESISTANCE = 100
local FROST_RESISTANCE = 50
local RESISTANCE_ZERO = 0

-- Helper to create a mock GameAPI with default values
local function createMockGameAPI()
    return {
        IsMob = function()
            return true
        end,
        GetPlayerLevel = function()
            return PLAYER_LEVEL_MAX
        end,
        GetUnitLevel = function()
            return { value = MOB_LEVEL_REGULAR, is_skull = false, is_world_boss = false }
        end,
        GetArmor = function()
            return ARMOR_DEFAULT
        end,
        GetResistances = function()
            return {
                { id = "fire", amount = FIRE_RESISTANCE },
                { id = "frost", amount = FROST_RESISTANCE },
            }
        end,
        GetMelee = function()
            return {
                main_hand = {
                    attack_speed = MAIN_HAND_ATTACK_SPEED,
                    min_damage = MAIN_HAND_MIN_DAMAGE,
                    max_damage = MAIN_HAND_MAX_DAMAGE,
                },
                offhand = nil,
            }
        end,
    }
end

-- Helper to find resistance by id
local function findResistanceById(resistances, id)
    for _, res in ipairs(resistances) do
        if res:GetId() == id then
            return res
        end
    end
    return nil
end

function TestApplicationService:setUp()
    self.originalGameAPI = MobStats.GameAPI
    self.mockGameAPI = createMockGameAPI()
    MobStats.GameAPI = self.mockGameAPI
end

function TestApplicationService:tearDown()
    MobStats.GameAPI = self.originalGameAPI
end

-- Test: Returns nil for non-mob units
function TestApplicationService:test_returns_nil_for_non_mob()
    self.mockGameAPI.IsMob = function()
        return false
    end

    local result = MobStats.ApplicationService:GetMobStats("target")

    lu.assertNil(result)
end

-- Test: Returns valid DTO for regular mob
function TestApplicationService:test_returns_dto_for_regular_mob()
    local result = MobStats.ApplicationService:GetMobStats("target")

    lu.assertNotNil(result)
end

-- Test: Armor amount is correctly passed through
function TestApplicationService:test_armor_constructed_correctly()
    self.mockGameAPI.GetArmor = function()
        return ARMOR_HIGH
    end

    local result = MobStats.ApplicationService:GetMobStats("target")

    lu.assertEquals(result.armor:GetAmount(), ARMOR_HIGH)
end

-- Test: Melee with main hand only
function TestApplicationService:test_melee_main_hand_only()
    self.mockGameAPI.GetMelee = function()
        return {
            main_hand = {
                attack_speed = ALT_MAIN_HAND_ATTACK_SPEED,
                min_damage = ALT_MAIN_HAND_MIN_DAMAGE,
                max_damage = ALT_MAIN_HAND_MAX_DAMAGE,
            },
            offhand = nil,
        }
    end

    local result = MobStats.ApplicationService:GetMobStats("target")

    lu.assertNotNil(result.melee)
    lu.assertNotNil(result.melee:GetMainHandDamage())
    lu.assertNil(result.melee:GetOffhandDamage())
    lu.assertEquals(result.melee:GetMainHandDamage():GetAttackSpeed(), ALT_MAIN_HAND_ATTACK_SPEED)
    lu.assertEquals(result.melee:GetMainHandDamage():GetMinDamage(), ALT_MAIN_HAND_MIN_DAMAGE)
    lu.assertEquals(result.melee:GetMainHandDamage():GetMaxDamage(), ALT_MAIN_HAND_MAX_DAMAGE)
end

-- Test: Melee with dual wield
function TestApplicationService:test_melee_dual_wield()
    self.mockGameAPI.GetMelee = function()
        return {
            main_hand = {
                attack_speed = MAIN_HAND_ATTACK_SPEED,
                min_damage = MAIN_HAND_MIN_DAMAGE,
                max_damage = MAIN_HAND_MAX_DAMAGE,
            },
            offhand = {
                attack_speed = OFFHAND_ATTACK_SPEED,
                min_damage = OFFHAND_MIN_DAMAGE,
                max_damage = OFFHAND_MAX_DAMAGE,
            },
        }
    end

    local result = MobStats.ApplicationService:GetMobStats("target")

    lu.assertNotNil(result.melee:GetMainHandDamage())
    lu.assertNotNil(result.melee:GetOffhandDamage())

    local mainHand = result.melee:GetMainHandDamage()
    lu.assertEquals(mainHand:GetAttackSpeed(), MAIN_HAND_ATTACK_SPEED)
    lu.assertEquals(mainHand:GetMinDamage(), MAIN_HAND_MIN_DAMAGE)
    lu.assertEquals(mainHand:GetMaxDamage(), MAIN_HAND_MAX_DAMAGE)

    local offhand = result.melee:GetOffhandDamage()
    lu.assertEquals(offhand:GetAttackSpeed(), OFFHAND_ATTACK_SPEED)
    lu.assertEquals(offhand:GetMinDamage(), OFFHAND_MIN_DAMAGE)
    lu.assertEquals(offhand:GetMaxDamage(), OFFHAND_MAX_DAMAGE)
end

-- Test: Resistances are constructed with correct ids
function TestApplicationService:test_resistances_constructed()
    self.mockGameAPI.GetResistances = function()
        return {
            { id = "fire", amount = FIRE_RESISTANCE },
            { id = "frost", amount = FROST_RESISTANCE },
        }
    end

    local result = MobStats.ApplicationService:GetMobStats("target")

    lu.assertEquals(#result.resistances, 2)

    local fireRes = findResistanceById(result.resistances, "fire")
    local frostRes = findResistanceById(result.resistances, "frost")

    lu.assertNotNil(fireRes)
    lu.assertNotNil(frostRes)
end

-- Test: Skull level mob returns valid DTO
function TestApplicationService:test_skull_level_mob()
    self.mockGameAPI.GetUnitLevel = function()
        return { value = MOB_LEVEL_SKULL, is_skull = true, is_world_boss = false }
    end

    local result = MobStats.ApplicationService:GetMobStats("target")

    lu.assertNotNil(result)
    lu.assertNotNil(result.armor)
end

-- Test: World boss returns valid DTO
function TestApplicationService:test_world_boss()
    self.mockGameAPI.GetUnitLevel = function()
        return { value = MOB_LEVEL_SKULL, is_skull = true, is_world_boss = true }
    end

    local result = MobStats.ApplicationService:GetMobStats("target")

    lu.assertNotNil(result)
    lu.assertNotNil(result.armor)
end

-- Test: Mob with no melee damage (nil main_hand) returns nil melee
function TestApplicationService:test_mob_no_melee()
    self.mockGameAPI.GetMelee = function()
        return { main_hand = nil, offhand = nil }
    end

    local result = MobStats.ApplicationService:GetMobStats("target")

    lu.assertNotNil(result)
    lu.assertNil(result.melee)
end

-- Test: Zero armor is passed through
function TestApplicationService:test_zero_armor()
    self.mockGameAPI.GetArmor = function()
        return ARMOR_ZERO
    end

    local result = MobStats.ApplicationService:GetMobStats("target")

    lu.assertEquals(result.armor:GetAmount(), ARMOR_ZERO)
end

-- Test: All six resistances are passed through
function TestApplicationService:test_all_resistances_passed_through()
    self.mockGameAPI.GetResistances = function()
        return {
            { id = "fire", amount = RESISTANCE_ZERO },
            { id = "frost", amount = RESISTANCE_ZERO },
            { id = "nature", amount = RESISTANCE_ZERO },
            { id = "shadow", amount = RESISTANCE_ZERO },
            { id = "arcane", amount = RESISTANCE_ZERO },
            { id = "holy", amount = RESISTANCE_ZERO },
        }
    end

    local result = MobStats.ApplicationService:GetMobStats("target")

    lu.assertEquals(#result.resistances, 6)
end

return TestApplicationService
