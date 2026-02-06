setfenv(1, MobStats)

if GetLocale() ~= "deDE" then return end

L.MELEE                       = "Nahkampf"
L.MELEE_MH                    = "Nahkampf (WH)"
L.MELEE_OH                    = "Nahkampf (NH)"
L.MELEE_FORMAT                = "%d-%d @ %.2f (%.1f DPS)"

L.ARMOR                       = "Rüstung"
L.ARMOR_NONE                  = "Keine"
L.ARMOR_FORMAT                = "%d (%d%% SR)"

L.RESISTANCES                 = "Widerstände"
L.RESISTANCES_NONE            = "Keine"
L.RESISTANCES_ALL             = "Alle"
L.RESISTANCES_OTHER           = "Andere"
L.RESISTANCE_ARCANE           = "Arkan"
L.RESISTANCE_FIRE             = "Feuer"
L.RESISTANCE_FROST            = "Frost"
L.RESISTANCE_HOLY             = "Heilig"
L.RESISTANCE_NATURE           = "Natur"
L.RESISTANCE_SHADOW           = "Schatten"
