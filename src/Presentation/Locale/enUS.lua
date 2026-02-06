setfenv(1, MobStats)

---@class L
---@field MELEE string
---@field MELEE_MH string
---@field MELEE_OH string
---@field MELEE_FORMAT string
---@field ARMOR string
---@field ARMOR_NONE string
---@field ARMOR_FORMAT string
---@field RESISTANCES string
---@field RESISTANCES_NONE string
---@field RESISTANCES_ALL string
---@field RESISTANCES_OTHER string
---@field RESISTANCE_ARCANE string
---@field RESISTANCE_FIRE string
---@field RESISTANCE_FROST string
---@field RESISTANCE_HOLY string
---@field RESISTANCE_NATURE string
---@field RESISTANCE_SHADOW string

L = {
    MELEE                       = "Melee",
    MELEE_MH                    = "Melee (MH)",
    MELEE_OH                    = "Melee (OH)",
    MELEE_FORMAT                = "%d-%d @ %.2f (%.1f dps)",

    ARMOR                       = "Armor",
    ARMOR_NONE                  = "None",
    ARMOR_FORMAT                = "%d (%d%% DR)",

    RESISTANCES                 = "Resistances",
    RESISTANCES_NONE            = "None",
    RESISTANCES_ALL             = "All",
    RESISTANCES_OTHER           = "Other",
    RESISTANCE_ARCANE           = "Arcane",
    RESISTANCE_FIRE             = "Fire",
    RESISTANCE_FROST            = "Frost",
    RESISTANCE_HOLY             = "Holy",
    RESISTANCE_NATURE           = "Nature",
    RESISTANCE_SHADOW           = "Shadow",
}
