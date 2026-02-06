-- MockEnvironment.lua
-- Sets up a test environment that mocks WoW API and loads real project files

local _G = getfenv(0)

-- Create MobStats namespace (same as Boot.lua)
MobStats = setmetatable({ _G = _G }, { __index = _G })

-- Mock WoW API functions
MobStats.format = string.format
MobStats.tinsert = table.insert
MobStats.getn = function(t) return #t end
MobStats.sort = table.sort
MobStats.floor = math.floor
MobStats.ceil = math.ceil
MobStats.max = math.max
MobStats.min = math.min
MobStats.pairs = pairs
MobStats.ipairs = ipairs
MobStats.tostring = tostring
MobStats.strlower = string.lower

-- Mock WoW constants (color codes)
MobStats.HIGHLIGHT_FONT_COLOR_CODE = "|cffffffff"  -- White
MobStats.NORMAL_FONT_COLOR_CODE = "|cffffcc00"     -- Yellow
MobStats.FONT_COLOR_CODE_CLOSE = "|r"

-- Mock assert (use Lua's assert)
MobStats.assert = assert
MobStats.type = type
MobStats.setmetatable = setmetatable

-- Mock Environment for Turtle WoW detection
MobStats.Environment = {
    IsPlayingOnTurtleWoW = function() return false end
}

-- Mock GetLocale (default: enUS)
MobStats.GetLocale = function() return "enUS" end

-- Load real utilities from project
dofile("Utils.lua")
dofile("Presentation/Utils.lua")

-- Load locale
dofile("Presentation/Locale/enUS.lua")

-- Load real domain objects
dofile("Domain/Armor.lua")
dofile("Domain/Damage.lua")
dofile("Domain/Melee.lua")
dofile("Domain/Resistance.lua")
dofile("Domain/MobLevel.lua")

-- Load drawers to test
dofile("Presentation/Drawers/ArmorDrawer.lua")
dofile("Presentation/Drawers/MeleeDrawer.lua")
dofile("Presentation/Drawers/ResistancesDrawer.lua")

-- Load infrastructure and application layers
dofile("Infrastructure/GameAPI.lua")
dofile("Application/ApplicationService.lua")

return MobStats
