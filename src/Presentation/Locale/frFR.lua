setfenv(1, MobStats)

if GetLocale() ~= "frFR" then
    return
end

L.MELEE = "Mêlée"
L.MELEE_MH = "Mêlée (MP)"
L.MELEE_OH = "Mêlée (MS)"
L.MELEE_FORMAT = "%d-%d @ %.2f (%.1f DPS)"

L.ARMOR = "Armure"
L.ARMOR_NONE = "Aucune"
L.ARMOR_FORMAT = "%d (%d%% RD)"

L.RESISTANCES = "Résistances"
L.RESISTANCES_NONE = "Aucune"
L.RESISTANCES_ALL = "Toutes"
L.RESISTANCES_OTHER = "Autres"
L.RESISTANCE_ARCANE = "Arcanes"
L.RESISTANCE_FIRE = "Feu"
L.RESISTANCE_FROST = "Givre"
L.RESISTANCE_HOLY = "Sacré"
L.RESISTANCE_NATURE = "Nature"
L.RESISTANCE_SHADOW = "Ombre"
