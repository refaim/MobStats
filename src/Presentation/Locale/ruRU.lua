setfenv(1, MobStats)

if GetLocale() ~= "ruRU" then
    return
end

L.MELEE = "Ближний бой"
L.MELEE_MH = "Ближний бой (ОР)"
L.MELEE_OH = "Ближний бой (ЛР)"
L.MELEE_FORMAT = "%d-%d @ %.2f (%.1f УВС)"

L.ARMOR = "Броня"
L.ARMOR_NONE = "Нет"
L.ARMOR_FORMAT = "%d (%d%% СУ)"

L.RESISTANCES = "Сопротивления"
L.RESISTANCES_NONE = "Нет"
L.RESISTANCES_ALL = "Все"
L.RESISTANCES_OTHER = "Прочие"
L.RESISTANCE_ARCANE = "Тайная магия"
L.RESISTANCE_FIRE = "Огонь"
L.RESISTANCE_FROST = "Лёд"
L.RESISTANCE_HOLY = "Свет"
L.RESISTANCE_NATURE = "Природа"
L.RESISTANCE_SHADOW = "Тьма"
