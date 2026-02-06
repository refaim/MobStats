setfenv(1, MobStats)

if GetLocale() ~= "esES" then
    return
end

L.MELEE = "Cuerpo a cuerpo"
L.MELEE_MH = "Cuerpo a cuerpo (MP)"
L.MELEE_OH = "Cuerpo a cuerpo (MS)"
L.MELEE_FORMAT = "%d-%d @ %.2f (%.1f DPS)"

L.ARMOR = "Armadura"
L.ARMOR_NONE = "Nada"
L.ARMOR_FORMAT = "%d (%d%% RD)"

L.RESISTANCES = "Resistencias"
L.RESISTANCES_NONE = "Nada"
L.RESISTANCES_ALL = "Todas"
L.RESISTANCES_OTHER = "Otras"
L.RESISTANCE_ARCANE = "Arcano"
L.RESISTANCE_FIRE = "Fuego"
L.RESISTANCE_FROST = "Escarcha"
L.RESISTANCE_HOLY = "Sagrado"
L.RESISTANCE_NATURE = "Naturaleza"
L.RESISTANCE_SHADOW = "Sombras"
