-- Presentation/UtilsTest.lua
-- Tests for Presentation/Utils.lua utility functions

local lu = require("luaunit")
require("src.Tests.Support.Mocks.MockEnvironment")

-- Color constants for tests
local RED_COLOR_CODE = "|cffff0000"
local GREEN_COLOR_CODE = "|cff00ff00"

TestPresentationUtils = {}

-- ============================================================================
-- Tests for round()
-- ============================================================================

-- Test: Round positive number down
function TestPresentationUtils:test_round_positive_down()
    lu.assertEquals(MobStats.round(1.4, 0), 1)
end

-- Test: Round positive number up
function TestPresentationUtils:test_round_positive_up()
    lu.assertEquals(MobStats.round(1.6, 0), 2)
end

-- Test: Round exactly 0.5 rounds up (round half away from zero)
function TestPresentationUtils:test_round_positive_half_rounds_up()
    lu.assertEquals(MobStats.round(0.5, 0), 1)
    lu.assertEquals(MobStats.round(1.5, 0), 2)
    lu.assertEquals(MobStats.round(2.5, 0), 3)
end

-- Test: Round negative number toward zero
function TestPresentationUtils:test_round_negative_toward_zero()
    lu.assertEquals(MobStats.round(-1.4, 0), -1)
end

-- Test: Round negative number away from zero
function TestPresentationUtils:test_round_negative_away_from_zero()
    lu.assertEquals(MobStats.round(-1.6, 0), -2)
end

-- Test: Round exactly -0.5 rounds down (away from zero)
function TestPresentationUtils:test_round_negative_half_rounds_down()
    lu.assertEquals(MobStats.round(-0.5, 0), -1)
    lu.assertEquals(MobStats.round(-1.5, 0), -2)
    lu.assertEquals(MobStats.round(-2.5, 0), -3)
end

-- Test: Round with 1 decimal place
function TestPresentationUtils:test_round_one_decimal_place()
    lu.assertEquals(MobStats.round(1.44, 1), 1.4)
    lu.assertEquals(MobStats.round(1.45, 1), 1.5)
    lu.assertEquals(MobStats.round(1.46, 1), 1.5)
end

-- Test: Round with 2 decimal places
function TestPresentationUtils:test_round_two_decimal_places()
    lu.assertEquals(MobStats.round(1.234, 2), 1.23)
    lu.assertEquals(MobStats.round(1.235, 2), 1.24)
    lu.assertEquals(MobStats.round(1.236, 2), 1.24)
end

-- Test: Round with many decimal places
function TestPresentationUtils:test_round_many_decimal_places()
    lu.assertEquals(MobStats.round(1.123456789, 5), 1.12346)
    lu.assertEquals(MobStats.round(1.123454, 5), 1.12345)
end

-- Test: Round zero
function TestPresentationUtils:test_round_zero()
    lu.assertEquals(MobStats.round(0, 0), 0)
    lu.assertEquals(MobStats.round(0, 2), 0)
end

-- Test: Round whole number
function TestPresentationUtils:test_round_whole_number()
    lu.assertEquals(MobStats.round(5, 0), 5)
    lu.assertEquals(MobStats.round(5, 2), 5)
end

-- Test: Round very small positive number
function TestPresentationUtils:test_round_very_small_positive()
    lu.assertEquals(MobStats.round(0.001, 2), 0)
    lu.assertEquals(MobStats.round(0.005, 2), 0.01)
    lu.assertEquals(MobStats.round(0.004, 2), 0)
end

-- Test: Round very small negative number
function TestPresentationUtils:test_round_very_small_negative()
    lu.assertEquals(MobStats.round(-0.001, 2), 0)
    lu.assertEquals(MobStats.round(-0.005, 2), -0.01)
    lu.assertEquals(MobStats.round(-0.004, 2), 0)
end

-- Test: Round large number
function TestPresentationUtils:test_round_large_number()
    lu.assertEquals(MobStats.round(123456.789, 2), 123456.79)
    lu.assertEquals(MobStats.round(123456.784, 2), 123456.78)
end

-- Test: Round negative with decimal places
function TestPresentationUtils:test_round_negative_with_decimal_places()
    lu.assertEquals(MobStats.round(-1.234, 2), -1.23)
    lu.assertEquals(MobStats.round(-1.235, 2), -1.24)
    lu.assertEquals(MobStats.round(-1.236, 2), -1.24)
end

-- Test: Round with negative decimal_places (round to tens, hundreds)
function TestPresentationUtils:test_round_negative_decimal_places()
    lu.assertEquals(MobStats.round(1234, -1), 1230)
    lu.assertEquals(MobStats.round(1235, -1), 1240)
    lu.assertEquals(MobStats.round(1234, -2), 1200)
    lu.assertEquals(MobStats.round(1250, -2), 1300)
    lu.assertEquals(MobStats.round(1234, -3), 1000)
    lu.assertEquals(MobStats.round(1500, -3), 2000)
end

-- ============================================================================
-- Tests for boolean_to_wowboolean()
-- ============================================================================

-- Test: True converts to 1
function TestPresentationUtils:test_boolean_to_wowboolean_true()
    lu.assertEquals(MobStats.boolean_to_wowboolean(true), 1)
end

-- Test: False converts to nil
function TestPresentationUtils:test_boolean_to_wowboolean_false()
    lu.assertNil(MobStats.boolean_to_wowboolean(false))
end

-- Test: Nil converts to nil (falsy)
function TestPresentationUtils:test_boolean_to_wowboolean_nil()
    lu.assertNil(MobStats.boolean_to_wowboolean(nil))
end

-- Test: Truthy non-boolean value converts to 1
function TestPresentationUtils:test_boolean_to_wowboolean_truthy_string()
    lu.assertEquals(MobStats.boolean_to_wowboolean("text"), 1)
end

-- Test: Truthy number converts to 1
function TestPresentationUtils:test_boolean_to_wowboolean_truthy_number()
    lu.assertEquals(MobStats.boolean_to_wowboolean(42), 1)
end

-- Test: Zero is truthy in Lua (converts to 1)
function TestPresentationUtils:test_boolean_to_wowboolean_zero_is_truthy()
    lu.assertEquals(MobStats.boolean_to_wowboolean(0), 1)
end

-- Test: Empty string is truthy in Lua (converts to 1)
function TestPresentationUtils:test_boolean_to_wowboolean_empty_string_is_truthy()
    lu.assertEquals(MobStats.boolean_to_wowboolean(""), 1)
end

-- ============================================================================
-- Tests for strjoin()
-- ============================================================================

-- Test: Empty array returns empty string
function TestPresentationUtils:test_strjoin_empty_array()
    lu.assertEquals(MobStats.strjoin({}, ", "), "")
end

-- Test: Single element returns element without glue
function TestPresentationUtils:test_strjoin_single_element()
    lu.assertEquals(MobStats.strjoin({ "hello" }, ", "), "hello")
end

-- Test: Two elements joined with glue
function TestPresentationUtils:test_strjoin_two_elements()
    lu.assertEquals(MobStats.strjoin({ "hello", "world" }, ", "), "hello, world")
end

-- Test: Multiple elements joined with glue
function TestPresentationUtils:test_strjoin_multiple_elements()
    lu.assertEquals(MobStats.strjoin({ "a", "b", "c", "d" }, "-"), "a-b-c-d")
end

-- Test: Empty glue concatenates directly
function TestPresentationUtils:test_strjoin_empty_glue()
    lu.assertEquals(MobStats.strjoin({ "a", "b", "c" }, ""), "abc")
end

-- Test: Multi-character glue
function TestPresentationUtils:test_strjoin_multichar_glue()
    lu.assertEquals(MobStats.strjoin({ "one", "two", "three" }, " :: "), "one :: two :: three")
end

-- Test: Elements containing glue character
function TestPresentationUtils:test_strjoin_elements_contain_glue()
    lu.assertEquals(MobStats.strjoin({ "a,b", "c,d" }, ","), "a,b,c,d")
end

-- Test: Empty strings in array
function TestPresentationUtils:test_strjoin_empty_strings_in_array()
    lu.assertEquals(MobStats.strjoin({ "", "b", "" }, "-"), "-b-")
end

-- Test: Single empty string
function TestPresentationUtils:test_strjoin_single_empty_string()
    lu.assertEquals(MobStats.strjoin({ "" }, ", "), "")
end

-- Test: Newline as glue
function TestPresentationUtils:test_strjoin_newline_glue()
    lu.assertEquals(MobStats.strjoin({ "line1", "line2" }, "\n"), "line1\nline2")
end

-- ============================================================================
-- Tests for paint()
-- ============================================================================

-- Test: Paints value with color code
function TestPresentationUtils:test_paint_basic()
    local result = MobStats.paint("text", RED_COLOR_CODE)

    lu.assertEquals(result, RED_COLOR_CODE .. "text|r")
end

-- Test: Paints with highlight color
function TestPresentationUtils:test_paint_highlight_color()
    local result = MobStats.paint("value", MobStats.HIGHLIGHT_FONT_COLOR_CODE)

    lu.assertEquals(result, "|cffffffffvalue|r")
end

-- Test: Paints with normal color
function TestPresentationUtils:test_paint_normal_color()
    local result = MobStats.paint("value", MobStats.NORMAL_FONT_COLOR_CODE)

    lu.assertEquals(result, "|cffffcc00value|r")
end

-- Test: Paints empty string
function TestPresentationUtils:test_paint_empty_string()
    local result = MobStats.paint("", RED_COLOR_CODE)

    lu.assertEquals(result, RED_COLOR_CODE .. "|r")
end

-- Test: Paints string with special characters
function TestPresentationUtils:test_paint_special_characters()
    local result = MobStats.paint("10% damage", RED_COLOR_CODE)

    lu.assertEquals(result, RED_COLOR_CODE .. "10% damage|r")
end

-- Test: Paints numeric value converted to string
function TestPresentationUtils:test_paint_preserves_value()
    local result = MobStats.paint("42", GREEN_COLOR_CODE)

    lu.assertEquals(result, GREEN_COLOR_CODE .. "42|r")
end

-- ============================================================================
-- Validation tests (document crash behavior for invalid inputs)
-- ============================================================================

-- Test: round() with nil value throws error
function TestPresentationUtils:test_round_nil_value_throws()
    lu.assertError(function()
        MobStats.round(nil, 0)
    end)
end

-- Test: round() with nil decimal_places throws error
function TestPresentationUtils:test_round_nil_decimal_places_throws()
    lu.assertError(function()
        MobStats.round(1.5, nil)
    end)
end

-- Test: strjoin() with nil array throws error
function TestPresentationUtils:test_strjoin_nil_array_throws()
    lu.assertError(function()
        MobStats.strjoin(nil, ", ")
    end)
end

-- Test: strjoin() with nil glue throws error
function TestPresentationUtils:test_strjoin_nil_glue_throws()
    lu.assertError(function()
        MobStats.strjoin({ "a", "b" }, nil)
    end)
end

-- Test: strjoin() with numbers in array (Lua auto-converts to strings)
function TestPresentationUtils:test_strjoin_numbers_auto_converted()
    lu.assertEquals(MobStats.strjoin({ 1, 2, 3 }, "-"), "1-2-3")
end

-- Test: paint() with nil value throws error
function TestPresentationUtils:test_paint_nil_value_throws()
    lu.assertError(function()
        MobStats.paint(nil, RED_COLOR_CODE)
    end)
end

-- Test: paint() with nil color throws error
function TestPresentationUtils:test_paint_nil_color_throws()
    lu.assertError(function()
        MobStats.paint("text", nil)
    end)
end

return TestPresentationUtils
