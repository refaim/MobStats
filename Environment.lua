setfenv(1, MobStats)

---@class Environment
Environment = {}

---@return boolean
function Environment:IsPlayingOnTurtleWoW()
    return TargetHPText ~= nil and TargetHPPercText ~= nil
end
