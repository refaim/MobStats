setfenv(1, MobStats)

if GetLocale() ~= "koKR" then
    return
end

L.MELEE = "근접"
L.MELEE_MH = "근접 (주무기)"
L.MELEE_OH = "근접 (보조)"
L.MELEE_FORMAT = "%d-%d @ %.2f (%.1f DPS)"

L.ARMOR = "방어도"
L.ARMOR_NONE = "없음"
L.ARMOR_FORMAT = "%d (%d%% 피해감소)"

L.RESISTANCES = "저항"
L.RESISTANCES_NONE = "없음"
L.RESISTANCES_ALL = "모두"
L.RESISTANCES_OTHER = "기타"
L.RESISTANCE_ARCANE = "비전"
L.RESISTANCE_FIRE = "화염"
L.RESISTANCE_FROST = "냉기"
L.RESISTANCE_HOLY = "신성"
L.RESISTANCE_NATURE = "자연"
L.RESISTANCE_SHADOW = "암흑"
