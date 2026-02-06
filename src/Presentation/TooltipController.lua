setfenv(1, MobStats)

---@param mob_stats MobStatsApplicationDTO
local function draw(mob_stats)
    MeleeDrawer:Draw(mob_stats.melee, TooltipInterface)
    ArmorDrawer:Draw(mob_stats.armor, TooltipInterface)
    ResistancesDrawer:Draw(mob_stats.resistances, TooltipInterface)
end

local function do_nothing() end

---@type function
local previous_script
local frame = CreateFrame("Frame")
frame:RegisterEvent("VARIABLES_LOADED")
frame:SetScript("OnEvent", function ()
    previous_script = GameTooltip:GetScript("OnShow") or do_nothing
    GameTooltip:SetScript("OnShow", function()
        local stats = ApplicationService:GetMobStats("mouseover")
        if stats ~= nil then
            draw(--[[---@type MobStatsApplicationDTO]] stats)
            GameTooltip:Show()
        end
        previous_script()
    end)
end)
