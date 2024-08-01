--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

The general infected behavior are written in this file

]]--
--[[ ================================================ ]]--

--- Import functions localy for performances reasons
local table = table -- Lua's table module
local ipairs = ipairs -- ipairs function
local pairs = pairs -- pairs function
local ZombRand = ZombRand -- java function

--- import module
local ZomboidForge = require "ZomboidForge_module"
local TLOU_infected = require "TLOU_infected"

-- localy initialize mod data
local TLOU_ModData = ModData.getOrCreate("TLOU_Infected")
local function initTLOU_ModData()
	TLOU_ModData = ModData.getOrCreate("TLOU_Infected")
end
Events.OnInitGlobalModData.Remove(initTLOU_ModData)
Events.OnInitGlobalModData.Add(initTLOU_ModData)

-- player cannot push infected
ZomboidForge.NoPush = function(zombie, ZType)
	local target = zombie:getTarget()
	if not target or instanceof(target:getPrimaryHandItem(),"HandWeapon") then
		return false
	else
		return true
	end
end

-- grabby infected, slowing you down in place
function ZomboidForge.GrabbyInfected(ZType,target,zombie)
	if target:isAlive() then
		--clicker grabs target
		if not target:isGodMod() then
			target:setSlowFactor(1)
			target:setSlowTimer(1)
		end
	end
end

-- One shot target
ZomboidForge.KillTarget = function(ZType,zombie,victim,handWeapon)
	-- zombie kills victim
	if not victim:isGodMod() then
		victim:Kill(zombie)
	end
end

-- cap damage to clicker and bloater from player
-- increase damage if on fire
ZomboidForge.ExtraFireDamage = function(ZType,player, zombie, handWeapon, damage)
	-- maximum damage output
	if damage >= 3 then
		damage = 3
	end

	-- if Zombie is on fire, deal more damage even past max damage output
	if zombie:isOnFire() then
		return damage * ZomboidForge.ZTypes[ZType].fireDamageMultiplier
	end

	return damage
end

-- Add cordyceps mushrooms from Braven's Cordyceps Spore Zones when activated to various infected loot.
-- Purely for aesthetic and immersion.
-- Cordyceps loot count :
--
-- 		`Runner = 1 to 3`
-- 		`Stalker = 1 to 5`
-- 		`Clicker = 3 to 10`
-- 		`Bloater = 5 to 15`
--
---@param zombie 		IsoZombie
---@param ZType 		string   	--Zombie Type ID
ZomboidForge.OnInfectedDeath_cordyceps = function(zombie,ZType)
	-- roll to inventory
	local rand = ZombRand(1,100)
	if ZomboidForge.ZTypes[ZType].lootchance >= rand then
		zombie:getInventory():AddItems("Cordyceps", ZomboidForge.ZTypes[ZType].roll_lootcount())
	end
end


--#region Custom behavior: `HideIndoors`

-- Main function to handle `Zombie` behavior to go hide inside the closest building or wander during night.
---@param zombie 		IsoZombie
---@param _		 		string   	--Zombie Type ID
ZomboidForge.HideIndoors = function(zombie,_)
	-- get zombie data
	local trueID = ZomboidForge.pID(zombie)
	local PersistentZData_TLOU = ZomboidForge.GetPersistentZData(trueID,"TLOU_infected")

	-- if zombie is already in building, completely skip
	-- elseif has target
	-- elseif hasn't been at least N seconds since last update 
	if zombie:getBuilding()
	or zombie:getTarget()
	or zombie:isMoving()
	or math.floor(zombie.TimeSinceSeenFlesh / 100)%(TLOU_infected.HideIndoorsUpdates) ~= 0
	or PersistentZData_TLOU.target
	then
		return
	end

	-- lure zombie either to a building or make it wander if it's daytime
	TLOU_infected.LureZombie(zombie)
end

--#endregion