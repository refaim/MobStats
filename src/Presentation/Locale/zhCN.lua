setfenv(1, MobStats)

if GetLocale() ~= "zhCN" then return end

L.MELEE                       = "近战"
L.MELEE_MH                    = "近战 (主手)"
L.MELEE_OH                    = "近战 (副手)"
L.MELEE_FORMAT                = "%d-%d @ %.2f (%.1f DPS)"

L.ARMOR                       = "护甲"
L.ARMOR_NONE                  = "无"
L.ARMOR_FORMAT                = "%d (%d%% 伤害减少)"

L.RESISTANCES                 = "抗性"
L.RESISTANCES_NONE            = "无"
L.RESISTANCES_ALL             = "全部"
L.RESISTANCES_OTHER           = "其他"
L.RESISTANCE_ARCANE           = "奥术"
L.RESISTANCE_FIRE             = "火焰"
L.RESISTANCE_FROST            = "冰霜"
L.RESISTANCE_HOLY             = "神圣"
L.RESISTANCE_NATURE           = "自然"
L.RESISTANCE_SHADOW           = "暗影"
