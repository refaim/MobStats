setfenv(1, MobStats)

---@class ResistancesDrawer
ResistancesDrawer = {}

---@class ResistanceDisplayPresentationDTO
---@field label string
---@field color string

---@type table<ResistanceId, ResistanceDisplayPresentationDTO>
local ID_TO_DISPLAY = {}
ID_TO_DISPLAY["arcane"] = { label = L.RESISTANCE_ARCANE, color = "|cff66d5ce" }
ID_TO_DISPLAY["fire"] = { label = L.RESISTANCE_FIRE, color = "|cffdf6b6b" }
ID_TO_DISPLAY["frost"] = { label = L.RESISTANCE_FROST, color = "|cff3dbddd" }
ID_TO_DISPLAY["holy"] = { label = L.RESISTANCE_HOLY, color = "|cffdada4b" }
ID_TO_DISPLAY["nature"] = { label = L.RESISTANCE_NATURE, color = "|cff85d985" }
ID_TO_DISPLAY["shadow"] = { label = L.RESISTANCE_SHADOW, color = "|cffcd81dc" }

---@class ResistanceValuePresentationDTO
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
    local num_of_possible_resists = get_any_table_size(ID_TO_DISPLAY)
    local num_of_groups = get_any_table_size(groups_by_key)

    if num_of_groups == 1 then
        local group = groups_by_key[get_first_key(groups_by_key)]
        if getn(group) == num_of_possible_resists then
            local dto = group[1]
            assert(dto)
            return {
                {
                    label = L.RESISTANCES_ALL,
                    color = nil,
                    value = dto.value,
                    could_be_higher = dto.could_be_higher,
                },
            }
        elseif getn(group) == num_of_possible_resists - 1 then
            -- 5 same resistances, 1 missing (filtered as 0%)
            -- Find the missing resistance and show "MissingResist 0%, Other X%"
            local present_labels = {}
            for _, dto in ipairs(group) do
                present_labels[dto.label] = true
            end

            ---@type ResistanceId|nil
            local missing_id = nil
            for id, display in pairs(ID_TO_DISPLAY) do
                if not present_labels[display.label] then
                    missing_id = id
                    break
                end
            end

            if missing_id then
                local missing_display = ID_TO_DISPLAY[missing_id]
                local other_dto = group[1]
                assert(other_dto)
                return {
                    {
                        label = missing_display.label,
                        color = missing_display.color,
                        value = 0,
                        could_be_higher = false,
                    },
                    {
                        label = L.RESISTANCES_OTHER,
                        color = nil,
                        value = other_dto.value,
                        could_be_higher = other_dto.could_be_higher,
                    },
                }
            end
        end
    end

    ---@type ResistanceValuePresentationDTO[]
    local group_with_single_dto
    ---@type ResistanceValuePresentationDTO[]
    local group_with_other_dtos
    if num_of_groups == 2 then
        for _, group in pairs(groups_by_key) do
            if getn(group) == 1 then
                group_with_single_dto = group
            elseif getn(group) == num_of_possible_resists - 1 then
                group_with_other_dtos = group
            end
        end
    end

    ---@type ResistanceValuePresentationDTO[]
    local dtos = {}

    if group_with_single_dto ~= nil and group_with_other_dtos ~= nil then
        local other_dto = group_with_other_dtos[1]
        assert(other_dto)
        tinsert(dtos, group_with_single_dto[1])
        tinsert(dtos, {
            label = L.RESISTANCES_OTHER,
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
        local plus = ""
        if dto.could_be_higher then
            plus = "+"
        end
        local formatted_string = format("%s %d%%%s", dto.label, dto.value, plus)
        tinsert(strings, paint(formatted_string, dto.color or tooltip:GetValueColor()))
    end

    if getn(strings) == 0 then
        tinsert(strings, L.RESISTANCES_NONE)
    end

    tooltip:AddValue(L.RESISTANCES, strjoin(strings, paint(", ", tooltip:GetValueColor())), true)
end
