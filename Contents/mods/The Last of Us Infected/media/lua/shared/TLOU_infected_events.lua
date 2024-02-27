--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--- Makes sure TLOU_infected is loaded before
require "TLOU_infected"

--- Import ZomboidForge module
local ZomboidForge = require "ZomboidForge_module"

--- ZomboidForge.TLOU_infected functions
Events.OnGameStart.Add(ZomboidForge.InitTLOUInfected)

--- Add buildings to the list of buildings available to check for zombies
Events.LoadGridsquare.Add(ZomboidForge.AddBuildingList)

--- Add a check if it's day every hours
Events.EveryHours.Add(ZomboidForge.IsDay)