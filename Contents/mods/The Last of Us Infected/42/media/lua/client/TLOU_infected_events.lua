--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the events used by The Last of Us Infected based on Zomboid Forge framework.

]]--
--[[ ================================================ ]]--

--- Makes sure files are loaded before adding events is loaded before
local TLOU_infected = require "TLOU_infected"
require "TLOU_infected_tools"
require "General_behavior"
require "Runner_behavior"
require "Stalker_behavior"
require "Clicker_behavior"
require "Bloater_behavior"

--- TLOU_infected functions
Events.OnGameStart.Add(TLOU_infected.Initialize_TLOUInfected)

--- Handle player
Events.EveryOneMinute.Add(TLOU_infected.CustomInfection)

--- Add buildings to the list of buildings available to check for zombies
-- Events.LoadGridsquare.Add(TLOU_infected.AddBuildingList)

--- Add a check if it's day every hours
Events.EveryHours.Add(TLOU_infected.IsDay)

--- handling of commands sent 
Events.OnServerCommand.Add(function(module, command, args)
	if TLOU_infected.Commands[module] and TLOU_infected.Commands[module][command] then
		TLOU_infected.Commands[module][command](args)
	end
end)

-- patch for CheckUpstairs, changes the zombie name to show in voicelines
if getActivatedMods():contains("CheckUpstairs") then
    local CheckUpstairs = require "CheckUpstairs_module"

	CheckUpstairs.defaultZombieName = getText("IGUI_TLOU_zombieName")
	CheckUpstairs.defaultZombiesName = getText("IGUI_TLOU_zombiesName")
end

-- debug tool
-- Events.OnPostRender.Add(TLOU_infected.RenderHighLights)