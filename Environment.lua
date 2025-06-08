setfenv(1, MobStats)

---@class Environment
Environment = {}

---@return boolean
function Environment:IsPlayingOnTurtleWoW()
    return getglobal("LFT") ~= nil
end
