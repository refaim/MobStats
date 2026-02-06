-- UtilsTest.lua
-- Tests for Utils.lua utility functions

local lu = require("luaunit")
require("src.Tests.Support.Mocks.MockEnvironment")

TestUtils = {}

-- ============================================================================
-- Tests for new()
-- ============================================================================

-- Test: Creates object with class as metatable
function TestUtils:test_new_creates_object_with_metatable()
    local TestClass = { value = 42 }

    local obj = MobStats.new(TestClass)

    lu.assertEquals(obj.value, 42)
end

-- Test: Object inherits methods from class
function TestUtils:test_new_object_inherits_methods()
    local TestClass = {
        GetValue = function(obj)
            return obj.data
        end,
    }

    local obj = MobStats.new(TestClass)
    obj.data = "test"

    lu.assertEquals(obj:GetValue(), "test")
end

-- Test: Object can override class properties
function TestUtils:test_new_object_can_override_properties()
    local TestClass = { value = 42 }

    local obj = MobStats.new(TestClass)
    obj.value = 100

    lu.assertEquals(obj.value, 100)
    lu.assertEquals(TestClass.value, 42)
end

-- Test: Multiple objects from same class are independent
function TestUtils:test_new_multiple_objects_are_independent()
    local TestClass = { value = 0 }

    local obj1 = MobStats.new(TestClass)
    local obj2 = MobStats.new(TestClass)
    obj1.data = "first"
    obj2.data = "second"

    lu.assertEquals(obj1.data, "first")
    lu.assertEquals(obj2.data, "second")
end

-- Test: Nil class throws error
function TestUtils:test_new_nil_class_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.new(nil)
    end)
end

-- Test: Non-table class throws error
function TestUtils:test_new_non_table_class_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.new("not a table")
    end)
end

-- ============================================================================
-- Tests for get_any_table_size()
-- ============================================================================

-- Test: Empty table returns 0
function TestUtils:test_get_any_table_size_empty_table()
    local t = {}

    lu.assertEquals(MobStats.get_any_table_size(t), 0)
end

-- Test: Array table returns correct size
function TestUtils:test_get_any_table_size_array()
    local t = { "a", "b", "c" }

    lu.assertEquals(MobStats.get_any_table_size(t), 3)
end

-- Test: Hash table returns correct size
function TestUtils:test_get_any_table_size_hash()
    local t = { key1 = "value1", key2 = "value2" }

    lu.assertEquals(MobStats.get_any_table_size(t), 2)
end

-- Test: Mixed table returns correct size
function TestUtils:test_get_any_table_size_mixed()
    local t = { "a", "b", key1 = "value1", key2 = "value2" }

    lu.assertEquals(MobStats.get_any_table_size(t), 4)
end

-- Test: Table with nil gaps
function TestUtils:test_get_any_table_size_with_explicit_keys()
    local t = {}
    t[1] = "a"
    t[3] = "c"
    t[5] = "e"

    lu.assertEquals(MobStats.get_any_table_size(t), 3)
end

-- Test: Nil table throws error
function TestUtils:test_get_any_table_size_nil_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.get_any_table_size(nil)
    end)
end

-- Test: Non-table throws error
function TestUtils:test_get_any_table_size_non_table_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.get_any_table_size("not a table")
    end)
end

-- ============================================================================
-- Tests for get_first_key()
-- ============================================================================

-- Test: Returns a key from table with string keys
function TestUtils:test_get_first_key_returns_string_key()
    local t = { alpha = 1, beta = 2, gamma = 3 }

    local key = MobStats.get_first_key(t)

    lu.assertNotNil(key)
    lu.assertEquals(type(key), "string")
    lu.assertNotNil(t[key])
end

-- Test: Returns consistent key for same table
function TestUtils:test_get_first_key_returns_valid_key()
    local t = { only_key = "value" }

    local key = MobStats.get_first_key(t)

    lu.assertEquals(key, "only_key")
end

-- Test: Nil table throws error
function TestUtils:test_get_first_key_nil_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.get_first_key(nil)
    end)
end

-- Test: Non-table throws error
function TestUtils:test_get_first_key_non_table_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.get_first_key(123)
    end)
end

-- Test: Empty table throws error (no string key found)
function TestUtils:test_get_first_key_empty_table_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.get_first_key({})
    end)
end

-- Test: Table with only numeric keys throws error
function TestUtils:test_get_first_key_numeric_keys_only_throws()
    lu.assertErrorMsgContains("assertion failed", function()
        MobStats.get_first_key({ "a", "b", "c" })
    end)
end

return TestUtils
