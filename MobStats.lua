---@shape CompositeStatDTO
---@field base number
---@field positive_buff number
---@field negative_buff number
---@field effective number

---@shape DamageDTO
---@field speed number
---@field min_damage number
---@field max_damage number
---@field dps number

---@alias ResistId "holy" | "fire" | "nature" | "frost" | "shadow" | "arcane"

---@shape AllStatsDTO
---@field main_hand_damage DamageDTO|nil
---@field offhand_damage DamageDTO|nil
---@field armor CompositeStatDTO|nil
---@field resists table<ResistId, CompositeStatDTO|nil>

---@param mob UnitId
---@param index 0|1|2|3|4|5|6
---@return CompositeStatDTO|nil
local function get_resistance(mob, index)
    local base, effective, positive_buff, negative_buff = UnitResistance(mob, index)
    if base == 0 and effective == 0 then
        return nil
    end

    return {
        base = base,
        effective = effective,
        positive_buff = positive_buff,
        negative_buff = negative_buff,
    }
end

-- TODO move utils to separate file?
---@param n number|nil
local function zero_to_nil(n)
    if n == 0 then
        return nil
    end
    return n
end

---@param value boolean
---@return wowboolean
local function boolean_to_wowboolean(value)
    if value then
        return 1
    end
    return nil
end

---@param raw_speed number|nil
---@param raw_min_damage number|nil
---@param raw_max_damage number|nil
---@return DamageDTO|nil
local function make_damage_dto(raw_speed, raw_min_damage, raw_max_damage)
    raw_speed = zero_to_nil(raw_speed)
    raw_min_damage = zero_to_nil(raw_min_damage)
    raw_max_damage = zero_to_nil(raw_max_damage)

    if raw_speed == nil or raw_min_damage == nil or raw_max_damage == nil then
        return nil
    end

    local speed = --[[---@type number]] raw_speed
    local min_damage = --[[---@type number]] raw_min_damage
    local max_damage = --[[---@type number]] raw_max_damage

    -- TODO точно ли в speed и min/max damage учтены временные модификаторы? а процент? в BCS вручную оно считается, надо проверить, скорость можно через щит мороза, а урон как?
    return {
        speed = speed,
        min_damage = min_damage,
        max_damage = max_damage,
        dps = (min_damage + (max_damage - min_damage) / 2.0) / speed,
    }
end

---@param unit UnitId
---@return boolean
local function is_mob(unit)
    return UnitCanAttack("player", unit) == 1
       and UnitIsFriend("player", unit) == nil
       and UnitIsPlayer(unit) == nil
end

---@param unit UnitId
---@return AllStatsDTO|nil
local function get_stats(unit)
    if not is_mob(unit) then
        return nil
    end

    local mh_speed, oh_speed = UnitAttackSpeed(unit)
    -- TODO проверить, точно ли бонусы не надо вручную применить, см. PaperDollFrame.lua
    local mh_min_damage, mh_max_damage, oh_min_damage, oh_max_damage, _, _, _ = UnitDamage(unit)

    return {
        main_hand_damage = make_damage_dto(mh_speed, mh_min_damage, mh_max_damage),
        offhand_damage = make_damage_dto(oh_speed, oh_min_damage, oh_max_damage),
        armor = get_resistance(unit, 0),
        resists = {
            holy = get_resistance(unit, 1),
            fire = get_resistance(unit, 2),
            nature = get_resistance(unit, 3),
            frost = get_resistance(unit, 4),
            shadow = get_resistance(unit, 5),
            arcane = get_resistance(unit, 6),
        },
    }
end

---@param strings string[]
---@param glue string
---@return string
local function strjoin(strings, glue)
    local result = ""
    for _, s in ipairs(strings) do
        if result == "" then
            result = s
        else
            result = result .. glue .. s
        end
    end
    return result
end

---@param value string
---@param color string
local function paint(value, color)
    return color .. value .. FONT_COLOR_CODE_CLOSE
end

---@param label string
---@param value string
---@param wrap boolean
local function add_to_tooltip(label, value, wrap)
    local label_color = NORMAL_FONT_COLOR_CODE
    local value_color = HIGHLIGHT_FONT_COLOR_CODE
    GameTooltip:AddLine(
        format('%s %s', paint(label .. ":", label_color), paint(value, value_color)),
        nil,
        nil,
        nil,
        boolean_to_wowboolean(wrap))
end

-- TODO сконвертировать в проценты
---@param stat CompositeStatDTO|nil
local function draw_armor(stat)
    if stat == nil then
        return
    end

    ---@type CompositeStatDTO
    local v = --[[---@type CompositeStatDTO]] stat
    add_to_tooltip("Armor", tostring(v.effective), false)
end

---@type table<string, ResistId>
local RESIST_LABEL_TO_ID = {
    Arcane = "arcane",
    Fire = "fire",
    Frost = "frost",
    Holy = "holy",
    Nature = "nature",
    Shadow = "shadow",
}

local RESIST_ID_TO_COLOR = {
    arcane = "|cff66d5ce",
    fire = "|cffdf6b6b",
    frost = "|cff3dbddd",
    holy = "|cffdada4b",
    nature = "|cff85d985",
    shadow = "|cffcd81dc",
}

-- TODO сконвертировать в проценты
---@param values table<ResistId, CompositeStatDTO|nil>
local function draw_resists(values)
    local sorted_labels = {}
    for label, _ in pairs(RESIST_LABEL_TO_ID) do
        tinsert(sorted_labels, label)
    end
    sort(sorted_labels)

    local resist_strings = {}
    for _, label in pairs(sorted_labels) do
        local resist_id = RESIST_LABEL_TO_ID[label]
        local resist_or_nil = values[resist_id]
        if resist_or_nil ~= nil then
            local resist = --[[---@type CompositeStatDTO]] resist_or_nil
            local value_color = RESIST_ID_TO_COLOR[resist_id]
            if resist.effective ~= 0 then
                tinsert(resist_strings, paint(format("%s %d", label, resist.effective), value_color))
            end
        end
    end
    if getn(resist_strings) == 0 then
        tinsert(resist_strings, "None")
    end
    add_to_tooltip("Resistances", strjoin(resist_strings, ", "), true)
end

---@param n number
---@param decimal_places number
local function round(n, decimal_places)
    local m = 10 ^ decimal_places
    n = n * m
    if n >= 0 then
        n = floor(n + 0.5)
    else
        n = ceil(n - 0.5)
    end
    return n / m
end

---@param damage DamageDTO|nil
local function format_damage(dto_or_nil)
    if dto_or_nil == nil then
        return nil
    end

    ---@type DamageDTO
    local dto = --[[---@type DamageDTO]] dto_or_nil
    return format("%d-%d @ %.2f (%.1f dps)", round(dto.min_damage, 0), round(dto.max_damage, 0), dto.speed, round(dto.dps, 1))
end

---@param mh DamageDTO|nil
---@param oh DamageDTO|nil
---@param name string
local function draw_melee_damage(mh, oh)
    local mh_string = format_damage(mh)
    local oh_string = format_damage(oh)
    if mh_string ~= nil and oh_string ~= nil then
        add_to_tooltip("Melee (MH)", --[[---@type string]] mh_string, false)
        add_to_tooltip("Melee (OH)", --[[---@type string]] oh_string, false)
    elseif mh_string ~= nil then
        add_to_tooltip("Melee", --[[---@type string]] mh_string, false)
    elseif oh_string ~= nil then
        add_to_tooltip("Melee (OH)", --[[---@type string]] oh_string, false)
    end
end

---@param stats AllStatsDTO
local function draw_stats_on_tooltip(stats)
    draw_melee_damage(stats.main_hand_damage, stats.offhand_damage)
    draw_armor(stats.armor)
    draw_resists(stats.resists)
end

local PreviousOnShow
local frame = CreateFrame("Frame")
frame:RegisterEvent("VARIABLES_LOADED")
frame:SetScript("OnEvent", function ()
    -- TODO test with pfQuest and fix if not displaying
    PreviousOnShow = GameTooltip:GetScript("OnShow")
    GameTooltip:SetScript("OnShow", function()
        local stats = get_stats("mouseover")
        if stats ~= nil then
            draw_stats_on_tooltip(--[[---@type AllStatsDTO]] stats)
            GameTooltip:Show()
        elseif PreviousOnShow ~= nil then
            (--[[---@type function]] PreviousOnShow)()
        end
    end)
end)
