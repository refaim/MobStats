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
    ---@type table<string, ResistanceVO>
    local label_to_vo = {}
    ---@type string[]
    local sorted_labels = {}
    for _, vo in ipairs(resistances) do
        local display = ID_TO_DISPLAY[vo:GetId()]
        label_to_vo[display.label] = vo
        tinsert(sorted_labels, display.label)
    end
    sort(sorted_labels)

    ---@type string[]
    local value_strings = {}
    for _, label in ipairs(sorted_labels) do
        local vo = label_to_vo[label]
        local display = ID_TO_DISPLAY[vo:GetId()]
        local amount = vo:GetAmount()
        if amount > 0 then
            tinsert(value_strings, paint(format("%s %d", label, amount), display.color))
        end
    end

    if getn(value_strings) == 0 then
        tinsert(value_strings, "None")
    end

    tooltip:AddValue("Resistances", strjoin(value_strings, ", "), true)
end
