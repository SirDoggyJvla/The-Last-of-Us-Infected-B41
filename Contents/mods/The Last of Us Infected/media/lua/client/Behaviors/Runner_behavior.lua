--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

The Runner behavior is written in this file

]]--
--[[ ================================================ ]]--

--- Import functions localy for performances reasons
local table = table -- Lua's table module
local ipairs = ipairs -- ipairs function
local pairs = pairs -- pairs function
local ZombRand = ZombRand -- java function
local print = print -- print function
local tostring = tostring --tostring function

--- import module from ZomboidForge
local ZomboidForge = require "ZomboidForge_module"
local TLOU_infected = require "TLOU_infected"

-- localy initialize mod data
local TLOU_ModData = ModData.getOrCreate("TLOU_Infected")
local function initTLOU_ModData()
	TLOU_ModData = ModData.getOrCreate("TLOU_Infected")
end
Events.OnInitGlobalModData.Remove(initTLOU_ModData)
Events.OnInitGlobalModData.Add(initTLOU_ModData)


-- Set `Runner` sounds.
---@param zombie 		IsoZombie
---@param _		 		string   	--Zombie Type ID
ZomboidForge.SetRunnerSounds = function(zombie,_)
	if not zombie:getEmitter():isPlaying("Zombie/Voice/MaleA") and not zombie:isFemale()
	or not zombie:getEmitter():isPlaying("Zombie/Voice/FemaleA") and zombie:isFemale() then
		zombie:getEmitter():stopAll()
		if zombie:isFemale() then
			zombie:getEmitter():playVocals("Zombie/Voice/FemaleA")
		else 
			zombie:getEmitter():playVocals("Zombie/Voice/MaleA")
		end
	end
end