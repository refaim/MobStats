-- ResistancesDrawerTest.lua
-- Tests for ResistancesDrawer

local lu = require("luaunit")
require("src.Tests.Support.Mocks.MockEnvironment")
local MockTooltipInterface = require("src.Tests.Support.Mocks.MockTooltipInterface")

TestResistancesDrawer = {}

function TestResistancesDrawer:setUp()
    self.tooltip = MockTooltipInterface:new()
    self.drawer = MobStats.new(MobStats.ResistancesDrawer)
    -- Save original IsPlayingOnTurtleWoW function
    self.original_turtle_wow = MobStats.Environment.IsPlayingOnTurtleWoW
end

function TestResistancesDrawer:tearDown()
    self.tooltip:Clear()
    -- Restore original IsPlayingOnTurtleWoW function
    MobStats.Environment.IsPlayingOnTurtleWoW = self.original_turtle_wow
end

-- Helper to create resistance with specific percentage
-- Uses exact inverse formula from ResistanceVO:Construct
local function create_resistance(id, percent)
    local caster_level = 60
    local cap = caster_level * 5 -- 300

    -- Inverse of the resistance formula:
    -- average_mitigation = 0.75 * ratio - (3/16) * max(0, ratio - 2/3)
    -- where average_mitigation = percent / 100
    local average_mitigation = percent / 100.0

    local ratio
    if percent <= 50 then
        -- When ratio <= 2/3: average_mitigation = 0.75 * ratio
        ratio = average_mitigation / 0.75
    else
        -- When ratio > 2/3: average_mitigation = 0.75 * ratio - (3/16) * (ratio - 2/3)
        -- Simplifies to: average_mitigation = 0.5625 * ratio + 0.125
        -- Inverse: ratio = (average_mitigation - 0.125) / 0.5625
        ratio = (average_mitigation - 0.125) / 0.5625
    end

    local amount = ratio * cap
    local mob_level = MobStats.MobLevelVO:Construct(60, 60, false, false)
    return MobStats.ResistanceVO:Construct(id, amount, caster_level, mob_level)
end

-- Helper to create all six resistances with the same percentage
local function create_all_six_resistances(percent)
    return {
        create_resistance("arcane", percent),
        create_resistance("fire", percent),
        create_resistance("frost", percent),
        create_resistance("holy", percent),
        create_resistance("nature", percent),
        create_resistance("shadow", percent),
    }
end

-- Named constants for test resistance values
local LOW_RESISTANCE = 10
local LOW_MEDIUM_RESISTANCE = 20
local TYPICAL_RESISTANCE = 30
local MEDIUM_RESISTANCE = 40
local HIGH_RESISTANCE = 50

-- Test: Empty array displays "None"
function TestResistancesDrawer:test_empty_array_displays_none()
    local resistances = {}

    self.drawer:Draw(resistances, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Resistances")
    lu.assertEquals(call.value, "None")
    lu.assertEquals(call.wrap, true)
end

-- Test: Zero resistances are filtered out
function TestResistancesDrawer:test_zero_resistances_filtered()
    local resistances = {
        create_resistance("fire", 0),
        create_resistance("frost", TYPICAL_RESISTANCE),
    }

    self.drawer:Draw(resistances, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Resistances")
    lu.assertEquals(call.value, "|cff3dbdddFrost 30%|r")
    lu.assertEquals(call.wrap, true)
end

-- Test: Single resistance displays with color
function TestResistancesDrawer:test_single_resistance_with_color()
    local resistances = {
        create_resistance("fire", HIGH_RESISTANCE),
    }

    self.drawer:Draw(resistances, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Resistances")
    lu.assertEquals(call.value, "|cffdf6b6bFire 50%|r")
    lu.assertEquals(call.wrap, true)
end

-- Test: could_be_higher flag adds "+"
function TestResistancesDrawer:test_could_be_higher_adds_plus()
    -- Create a skull mob to trigger could_be_higher
    -- Skull mob at player level 40 with estimated level 50 (40+10 < 60), so could_be_higher = true
    local skull_mob_level = MobStats.MobLevelVO:Construct(40, -1, true, false)
    lu.assertTrue(skull_mob_level:CouldValueBeHigherThanEstimated(), "Mob level should be marked as could be higher")

    -- Create resistance with low enough value to trigger could_be_higher
    -- Using amount=100, caster_level=60 should give a resistance below 68.75%
    local resistance = MobStats.ResistanceVO:Construct("fire", 100, 60, skull_mob_level)

    -- Verify the resistance is marked as could_be_higher
    lu.assertTrue(resistance:CouldBeHigher(), "Resistance should be marked as could be higher")

    local resistances = { resistance }

    self.drawer:Draw(resistances, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Resistances")
    -- amount=100, cap=300, ratio=1/3, average_mitigation=0.25, percent=25
    lu.assertEquals(call.value, "|cffdf6b6bFire 25%+|r")
    lu.assertEquals(call.wrap, true)
end

-- Test: All 6 resistances with same value → "All"
function TestResistancesDrawer:test_all_six_same_compacts_to_all()
    local resistances = create_all_six_resistances(HIGH_RESISTANCE)

    self.drawer:Draw(resistances, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Resistances")
    lu.assertEquals(call.value, "|cffffffffAll 50%|r")
    lu.assertEquals(call.wrap, true)
end

-- Test: 5 same + 1 different → individual + "Other"
function TestResistancesDrawer:test_five_same_one_different_uses_other()
    local resistances = {
        create_resistance("fire", LOW_RESISTANCE),
        create_resistance("arcane", TYPICAL_RESISTANCE),
        create_resistance("frost", TYPICAL_RESISTANCE),
        create_resistance("holy", TYPICAL_RESISTANCE),
        create_resistance("nature", TYPICAL_RESISTANCE),
        create_resistance("shadow", TYPICAL_RESISTANCE),
    }

    self.drawer:Draw(resistances, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Resistances")
    lu.assertEquals(call.value, "|cffdf6b6bFire 10%|r|cffffffff, |r|cffffffffOther 30%|r")
    lu.assertEquals(call.wrap, true)
end

-- Test: Turtle WoW case - Holy 0%, others high due to level-based resistance
function TestResistancesDrawer:test_turtle_wow_holy_no_level_resistance()
    -- Enable Turtle WoW mode
    MobStats.Environment.IsPlayingOnTurtleWoW = function()
        return true
    end

    -- High level mob (63), low level caster (60)
    -- Level difference = 3, so level-based adds 3*8=24 to all resists except Holy
    local mob_level = MobStats.MobLevelVO:Construct(60, 63, false, false)

    -- Create all 6 resistances with base amount 0
    -- Non-holy will get +24 from level-based, Holy stays 0
    local resistances = {
        MobStats.ResistanceVO:Construct("arcane", 0, 60, mob_level),
        MobStats.ResistanceVO:Construct("fire", 0, 60, mob_level),
        MobStats.ResistanceVO:Construct("frost", 0, 60, mob_level),
        MobStats.ResistanceVO:Construct("holy", 0, 60, mob_level),
        MobStats.ResistanceVO:Construct("nature", 0, 60, mob_level),
        MobStats.ResistanceVO:Construct("shadow", 0, 60, mob_level),
    }

    self.drawer:Draw(resistances, self.tooltip)

    -- Should compact to "Holy 0%, Other 6%" format
    -- Holy is shown as 0%, others grouped as "Other"
    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Resistances")
    lu.assertEquals(call.value, "|cffdada4bHoly 0%|r|cffffffff, |r|cffffffffOther 6%|r")
    lu.assertEquals(call.wrap, true)
end

-- Test: 4 same + 2 different → all individual (no compactification)
function TestResistancesDrawer:test_four_same_two_different_no_compact()
    local resistances = {
        create_resistance("fire", LOW_RESISTANCE), -- different #1
        create_resistance("frost", LOW_MEDIUM_RESISTANCE), -- different #2
        create_resistance("arcane", TYPICAL_RESISTANCE), -- same #1
        create_resistance("holy", TYPICAL_RESISTANCE), -- same #2
        create_resistance("nature", TYPICAL_RESISTANCE), -- same #3
        create_resistance("shadow", TYPICAL_RESISTANCE), -- same #4
    }

    self.drawer:Draw(resistances, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Resistances")
    -- All 6 resistances shown individually in alphabetical order
    lu.assertEquals(
        call.value,
        "|cff66d5ceArcane 30%|r|cffffffff, |r|cffdf6b6bFire 10%|r|cffffffff, |r|cff3dbdddFrost 20%|r|cffffffff, |r|cffdada4bHoly 30%|r|cffffffff, |r|cff85d985Nature 30%|r|cffffffff, |r|cffcd81dcShadow 30%|r"
    )
    lu.assertEquals(call.wrap, true)
end

-- Test: Resistances are sorted alphabetically
function TestResistancesDrawer:test_alphabetical_sorting()
    local resistances = {
        create_resistance("nature", TYPICAL_RESISTANCE),
        create_resistance("arcane", MEDIUM_RESISTANCE),
        create_resistance("fire", LOW_MEDIUM_RESISTANCE),
    }

    self.drawer:Draw(resistances, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Resistances")
    -- Sorted alphabetically: Arcane, Fire, Nature
    lu.assertEquals(
        call.value,
        "|cff66d5ceArcane 40%|r|cffffffff, |r|cffdf6b6bFire 20%|r|cffffffff, |r|cff85d985Nature 30%|r"
    )
    lu.assertEquals(call.wrap, true)
end

-- Test: Each resistance has correct color
function TestResistancesDrawer:test_resistance_colors()
    local test_cases = {
        { id = "arcane", expected = "|cff66d5ceArcane 50%|r" },
        { id = "fire", expected = "|cffdf6b6bFire 50%|r" },
        { id = "frost", expected = "|cff3dbdddFrost 50%|r" },
        { id = "holy", expected = "|cffdada4bHoly 50%|r" },
        { id = "nature", expected = "|cff85d985Nature 50%|r" },
        { id = "shadow", expected = "|cffcd81dcShadow 50%|r" },
    }

    for _, tc in ipairs(test_cases) do
        self.tooltip:Clear()
        local resistances = { create_resistance(tc.id, HIGH_RESISTANCE) }
        self.drawer:Draw(resistances, self.tooltip)
        lu.assertEquals(self.tooltip:GetCallCount(), 1, "Call count mismatch for " .. tc.id)
        local call = self.tooltip:GetCall(1)
        lu.assertEquals(call.label, "Resistances", "Label mismatch for " .. tc.id)
        lu.assertEquals(call.value, tc.expected, "Value mismatch for " .. tc.id)
        lu.assertEquals(call.wrap, true, "Wrap mismatch for " .. tc.id)
    end
end

-- Test: Multiple resistances separated by comma with space
function TestResistancesDrawer:test_comma_separator()
    local resistances = {
        create_resistance("fire", TYPICAL_RESISTANCE),
        create_resistance("frost", MEDIUM_RESISTANCE),
    }

    self.drawer:Draw(resistances, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Resistances")
    -- Sorted alphabetically: Fire, Frost
    lu.assertEquals(call.value, "|cffdf6b6bFire 30%|r|cffffffff, |r|cff3dbdddFrost 40%|r")
    lu.assertEquals(call.wrap, true)
end

-- Test: All six resistances with value 0% display "None"
function TestResistancesDrawer:test_all_six_zero_displays_none()
    local resistances = create_all_six_resistances(0)

    self.drawer:Draw(resistances, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Resistances")
    lu.assertEquals(call.value, "None")
    lu.assertEquals(call.wrap, true)
end

-- Test: 100% resistance (maximum value)
function TestResistancesDrawer:test_maximum_resistance_100_percent()
    -- Tests that 100% resistance displays correctly
    local resistances = {
        create_resistance("fire", 100),
    }

    self.drawer:Draw(resistances, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Resistances")
    lu.assertEquals(call.value, "|cffdf6b6bFire 100%|r")
    lu.assertEquals(call.wrap, true)
end

-- Test: Rounding of resistance percentages
function TestResistancesDrawer:test_resistance_rounding()
    -- Test that percentages are properly rounded to nearest integer
    -- 49.4% → 49%, 49.5% → 50%, 49.6% → 50%
    -- Note: Uses create_resistance() which performs percent→ratio→amount→percent conversion
    -- Floating-point precision should be sufficient for these test cases
    local test_cases = {
        { percent = 49.4, expected = 49 },
        { percent = 49.5, expected = 50 },
        { percent = 49.6, expected = 50 },
        { percent = 50.4, expected = 50 },
        { percent = 50.5, expected = 51 },
    }

    for _, tc in ipairs(test_cases) do
        self.tooltip:Clear()
        local resistances = { create_resistance("fire", tc.percent) }
        self.drawer:Draw(resistances, self.tooltip)
        lu.assertEquals(self.tooltip:GetCallCount(), 1)
        local call = self.tooltip:GetCall(1)
        local expected_value = string.format("|cffdf6b6bFire %d%%|r", tc.expected)
        lu.assertEquals(call.value, expected_value, "Rounding mismatch for " .. tc.percent .. "%")
    end
end

-- Test: 5 same + 1 zero (missing) compacts to "Missing 0%, Other X%"
function TestResistancesDrawer:test_five_same_one_zero_missing()
    local resistances = {
        create_resistance("arcane", TYPICAL_RESISTANCE),
        create_resistance("fire", TYPICAL_RESISTANCE),
        create_resistance("frost", TYPICAL_RESISTANCE),
        create_resistance("holy", TYPICAL_RESISTANCE),
        create_resistance("nature", TYPICAL_RESISTANCE),
        -- Shadow is missing (0%)
    }

    self.drawer:Draw(resistances, self.tooltip)

    lu.assertEquals(self.tooltip:GetCallCount(), 1)
    local call = self.tooltip:GetCall(1)
    lu.assertEquals(call.label, "Resistances")
    -- Should show "Other 30%, Shadow 0%" (alphabetically sorted)
    lu.assertEquals(call.value, "|cffffffffOther 30%|r|cffffffff, |r|cffcd81dcShadow 0%|r")
    lu.assertEquals(call.wrap, true)
end

return TestResistancesDrawer
