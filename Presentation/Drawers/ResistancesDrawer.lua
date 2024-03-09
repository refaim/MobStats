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

---@shape ResistanceValuePresentationDTO
---@field label string
---@field color string|nil
---@field value number
---@field could_be_higher boolean

---@param value_objects ResistanceVO[]
---@return ResistanceValuePresentationDTO[]
local function convert_value_objects_to_dtos(value_objects)
    ---@type ResistanceValuePresentationDTO[]
    local dtos = {}
    for _, vo in ipairs(value_objects) do
        local value = round(vo:GetAverageResistanceInPercents(), 0)
        if value > 0 then
            local display = ID_TO_DISPLAY[vo:GetId()]
            tinsert(dtos, {
                label = display.label,
                color = display.color,
                value = value,
                could_be_higher = vo:CouldBeHigher(),
            })
        end
    end
    return dtos
end

---@param dtos ResistanceValuePresentationDTO[]
---@return table<string, ResistanceValuePresentationDTO[]>
local function group_dtos(dtos)
    ---@type table<string, ResistanceValuePresentationDTO[]>
    local dto_groups_by_key = {}
    for _, dto in ipairs(dtos) do
        local key = tostring(dto.value) .. tostring(dto.could_be_higher)
        local group = dto_groups_by_key[key] or {}
        tinsert(group, dto)
        dto_groups_by_key[key] = group
    end
    return dto_groups_by_key
end

---@param groups_by_key table<string, ResistanceValuePresentationDTO[]>
---@return ResistanceValuePresentationDTO[]
local function compact_dto_groups(groups_by_key)
    local num_of_groups = get_any_table_size(groups_by_key)

    if num_of_groups == 1 then
        local group = groups_by_key[get_first_key(groups_by_key)]
        local dto = group[1]
        return {{
            label = "All",
            color = nil,
            value = dto.value,
            could_be_higher = dto.could_be_higher,
        }}
    end

    ---@type ResistanceValuePresentationDTO[]
    local group_with_single_dto
    ---@type ResistanceValuePresentationDTO[]
    local group_with_other_dtos
    if num_of_groups == 2 then
        for _, group in pairs(groups_by_key) do
            if getn(group) == 1 then
                group_with_single_dto = group
            else
                group_with_other_dtos = group
            end
        end
    end

    ---@type ResistanceValuePresentationDTO[]
    local dtos = {}

    if group_with_single_dto ~= nil and group_with_other_dtos ~= nil then
        local other_dto = group_with_other_dtos[1]
        tinsert(dtos, group_with_single_dto[1])
        tinsert(dtos, {
            label = "Other",
            color = nil,
            value = other_dto.value,
            could_be_higher = other_dto.could_be_higher,
        })
    else
        for _, group in pairs(groups_by_key) do
            for _, dto in ipairs(group) do
                tinsert(dtos, dto)
            end
        end
    end

    return dtos
end

---@param dtos ResistanceValuePresentationDTO[]
---@return ResistanceValuePresentationDTO[]
local function sort_dtos(dtos)
    ---@type table<string, ResistanceValuePresentationDTO>
    local label_to_dto = {}
    ---@type string[]
    local sorted_labels = {}
    for _, dto in pairs(dtos) do
        label_to_dto[dto.label] = dto
        tinsert(sorted_labels, dto.label)
    end
    sort(sorted_labels)

    local sorted_dtos = {}
    for _, label in ipairs(sorted_labels) do
        tinsert(sorted_dtos, label_to_dto[label])
    end
    return sorted_dtos
end

---@param resistances ResistanceVO[]
---@param tooltip TooltipInterface
function ResistancesDrawer:Draw(resistances, tooltip)
    local dtos = sort_dtos(compact_dto_groups(group_dtos(convert_value_objects_to_dtos(resistances))))
    local strings = {}
    for _, dto in ipairs(dtos) do
        local plus = ''
        if dto.could_be_higher then
            plus = '+'
        end
        local formatted_string = format("%s %d%%%s", dto.label, dto.value, plus)
        tinsert(strings, paint(formatted_string, dto.color or tooltip:GetValueColor()))
    end

    if getn(strings) == 0 then
        tinsert(strings, "None")
    end

    tooltip:AddValue("Resistances", strjoin(strings, paint(", ", tooltip:GetValueColor())), true)
end
