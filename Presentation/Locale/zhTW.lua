setfenv(1, MobStats)

if GetLocale() ~= "zhTW" then return end

L.MELEE                       = "近戰"
L.MELEE_MH                    = "近戰 (主手)"
L.MELEE_OH                    = "近戰 (副手)"
L.MELEE_FORMAT                = "%d-%d @ %.2f (%.1f DPS)"

L.ARMOR                       = "護甲"
L.ARMOR_NONE                  = "無"
L.ARMOR_FORMAT                = "%d (%d%% 傷害減少)"

L.RESISTANCES                 = "抗性"
L.RESISTANCES_NONE            = "無"
L.RESISTANCES_ALL             = "全部"
L.RESISTANCES_OTHER           = "其他"
L.RESISTANCE_ARCANE           = "秘法"
L.RESISTANCE_FIRE             = "火焰"
L.RESISTANCE_FROST            = "冰霜"
L.RESISTANCE_HOLY             = "神聖"
L.RESISTANCE_NATURE           = "自然"
L.RESISTANCE_SHADOW           = "暗影"
