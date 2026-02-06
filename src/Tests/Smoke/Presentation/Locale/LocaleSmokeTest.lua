-- LocaleSmokeTest.lua
-- Smoke tests that verify each locale produces correct localized output in tooltips

local lu = require('luaunit')
require('src.Tests.Support.Mocks.MockEnvironment')
local MockTooltipInterface = require('src.Tests.Support.Mocks.MockTooltipInterface')

TestLocaleSmoke = {}

--- Reloads locale files and drawers for the given locale code.
--- This is necessary because ID_TO_DISPLAY in ResistancesDrawer captures L values at load time.
local function setup_locale(locale_code)
    dofile("src/Presentation/Locale/enUS.lua")
    MobStats.GetLocale = function() return locale_code end
    if locale_code ~= "enUS" then
        dofile("src/Presentation/Locale/" .. locale_code .. ".lua")
    end
    dofile("src/Presentation/Drawers/ArmorDrawer.lua")
    dofile("src/Presentation/Drawers/MeleeDrawer.lua")
    dofile("src/Presentation/Drawers/ResistancesDrawer.lua")
end

function TestLocaleSmoke:tearDown()
    setup_locale("enUS")
end

--- Creates an ArmorVO with zero armor
local function create_zero_armor()
    local mob_level = MobStats.MobLevelVO:Construct(60, 60, false, false)
    return MobStats.ArmorVO:Construct(0, 60, mob_level)
end

--- Creates a single fire resistance at 50%
local function create_fire_resistance()
    local caster_level = 60
    local cap = caster_level * 5
    local ratio = (50 / 100) / 0.75
    local amount = ratio * cap
    local mob_level = MobStats.MobLevelVO:Construct(60, 60, false, false)
    return MobStats.ResistanceVO:Construct("fire", amount, caster_level, mob_level)
end

--- Creates a MeleeVO with mainhand-only damage
local function create_melee()
    local mh = MobStats.DamageVO:Construct(100, 200, 2.0)
    return MobStats.MeleeVO:Construct(mh, nil)
end

--- Expected labels per locale: { armor_label, armor_none, melee_label, resistances_label, fire_name }
local EXPECTED = {
    enUS = { "Armor",           "None",     "Melee",              "Resistances",     "Fire" },
    deDE = { "Rüstung",         "Keine",    "Nahkampf",           "Widerstände",     "Feuer" },
    esES = { "Armadura",        "Nada",     "Cuerpo a cuerpo",    "Resistencias",    "Fuego" },
    frFR = { "Armure",          "Aucune",   "Mêlée",             "Résistances",     "Feu" },
    koKR = { "방어도",           "없음",      "근접",               "저항",             "화염" },
    ptBR = { "Armadura",        "Nenhuma",  "Corpo a corpo",      "Resistências",    "Fogo" },
    ruRU = { "Броня",           "Нет",      "Ближний бой",        "Сопротивления",   "Огонь" },
    zhCN = { "护甲",            "无",        "近战",               "抗性",             "火焰" },
    zhTW = { "護甲",            "無",        "近戰",               "抗性",             "火焰" },
}

local function run_locale_test(locale_code)
    local expected = EXPECTED[locale_code]
    setup_locale(locale_code)

    -- Test ArmorDrawer with zero armor
    local tooltip = MockTooltipInterface:new()
    local armor_drawer = MobStats.new(MobStats.ArmorDrawer)
    armor_drawer:Draw(create_zero_armor(), tooltip)
    lu.assertEquals(tooltip:GetCallCount(), 1, locale_code .. ": ArmorDrawer call count")
    local armor_call = tooltip:GetCall(1)
    lu.assertEquals(armor_call.label, expected[1], locale_code .. ": Armor label")
    lu.assertEquals(armor_call.value, expected[2], locale_code .. ": Armor none value")

    -- Test MeleeDrawer
    tooltip:Clear()
    local melee_drawer = MobStats.new(MobStats.MeleeDrawer)
    melee_drawer:Draw(create_melee(), tooltip)
    lu.assertEquals(tooltip:GetCallCount(), 1, locale_code .. ": MeleeDrawer call count")
    local melee_call = tooltip:GetCall(1)
    lu.assertEquals(melee_call.label, expected[3], locale_code .. ": Melee label")

    -- Test ResistancesDrawer with single fire resistance
    tooltip:Clear()
    local resistances_drawer = MobStats.new(MobStats.ResistancesDrawer)
    resistances_drawer:Draw({ create_fire_resistance() }, tooltip)
    lu.assertEquals(tooltip:GetCallCount(), 1, locale_code .. ": ResistancesDrawer call count")
    local res_call = tooltip:GetCall(1)
    lu.assertEquals(res_call.label, expected[4], locale_code .. ": Resistances label")
    lu.assertStrContains(res_call.value, expected[5], locale_code .. ": Fire resistance name")
end

function TestLocaleSmoke:test_enUS() run_locale_test("enUS") end
function TestLocaleSmoke:test_deDE() run_locale_test("deDE") end
function TestLocaleSmoke:test_esES() run_locale_test("esES") end
function TestLocaleSmoke:test_frFR() run_locale_test("frFR") end
function TestLocaleSmoke:test_koKR() run_locale_test("koKR") end
function TestLocaleSmoke:test_ptBR() run_locale_test("ptBR") end
function TestLocaleSmoke:test_ruRU() run_locale_test("ruRU") end
function TestLocaleSmoke:test_zhCN() run_locale_test("zhCN") end
function TestLocaleSmoke:test_zhTW() run_locale_test("zhTW") end

return TestLocaleSmoke
