setfenv(1, MobStats)

if GetLocale() ~= "ptBR" then
    return
end

L.MELEE = "Corpo a corpo"
L.MELEE_MH = "Corpo a corpo (MP)"
L.MELEE_OH = "Corpo a corpo (MS)"
L.MELEE_FORMAT = "%d-%d @ %.2f (%.1f DPS)"

L.ARMOR = "Armadura"
L.ARMOR_NONE = "Nenhuma"
L.ARMOR_FORMAT = "%d (%d%% RD)"

L.RESISTANCES = "Resistências"
L.RESISTANCES_NONE = "Nenhuma"
L.RESISTANCES_ALL = "Todas"
L.RESISTANCES_OTHER = "Outras"
L.RESISTANCE_ARCANE = "Arcano"
L.RESISTANCE_FIRE = "Fogo"
L.RESISTANCE_FROST = "Gelo"
L.RESISTANCE_HOLY = "Sagrado"
L.RESISTANCE_NATURE = "Natureza"
L.RESISTANCE_SHADOW = "Sombra"
