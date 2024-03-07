setfenv(1, MobStats)

---@class ResistancesDrawer
ResistancesDrawer = {}

---@shape ResistanceDisplayPresentationDTO
---@field label string
---@field color string

---@type table<ResistanceId, ResistanceDisplayPresentationDTO>
local ID_TO_DISPLAY = {}
ID_TO_DISPLAY["arcane"] = { label = "Arcane", color = "|cff66d5ce" }
ID_TO_DISPLAY["fire"] = { label = "Fire", color = "|cffdf6b6b" }
ID_TO_DISPLAY["frost"] = { label = "Frost", color = "|cff3dbddd" }
ID_TO_DISPLAY["holy"] = { label = "Holy", color = "|cffdada4b" }
ID_TO_DISPLAY["nature"] = { label = "Nature", color = "|cff85d985" }
ID_TO_DISPLAY["shadow"] = { label = "Shadow", color = "|cffcd81dc" }

---@param resistances ResistanceVO[]
---@param tooltip TooltipInterface
function ResistancesDrawer:Draw(resistances, tooltip)
    ---@type string[]
    local sorted_labels = {}
    ---@type table<string, ResistanceId>
    local label_to_id = {}
    for _, vo in ipairs(resistances) do
        local display = ID_TO_DISPLAY[vo:GetId()]
        tinsert(sorted_labels, display.label)
        label_to_id[display.label] = vo:GetId()
    end
    sort(sorted_labels)

    ---@type table<string, number>
    local id_to_value = {}
    local has_positive_values = false
    local has_different_values = false
    local previous_value
    for _, vo in ipairs(resistances) do
        local value = round(vo:GetAverageResistanceInPercents(), 0)

        if value > 0 then
            has_positive_values = true
        end

        if previous_value == nil then
            previous_value = value
        end
        if value ~= previous_value then
            has_different_values = true
        end
        previous_value = value

        id_to_value[vo:GetId()] = value
    end

    ---@type string[]
    local value_strings = {}
    if not has_positive_values then
        tinsert(value_strings, "None")
    elseif not has_different_values then
        tinsert(value_strings, format("All %d%%", previous_value))
    else
        for _, label in ipairs(sorted_labels) do
            local id = label_to_id[label]
            local display = ID_TO_DISPLAY[id]
            local value = id_to_value[id]
            if value > 0 then
                tinsert(value_strings, paint(format("%s %d%%", label, value), display.color))
            end
        end
    end

    tooltip:AddValue("Resistances", strjoin(value_strings, ", "), true)
end
