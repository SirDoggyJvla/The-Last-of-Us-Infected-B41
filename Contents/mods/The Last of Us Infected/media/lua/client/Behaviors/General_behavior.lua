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
require "ZomboidForge_tools"

-- localy initialize mod data
local TLOU_ModData = ModData.getOrCreate("TLOU_Infected")
local function initTLOU_ModData()
	TLOU_ModData = ModData.getOrCreate("TLOU_Infected")
end
Events.OnInitGlobalModData.Remove(initTLOU_ModData)
Events.OnInitGlobalModData.Add(initTLOU_ModData)

-- localy initialize player
local client_player = getPlayer()
local objectList = client_player and client_player:getCell():getObjectList()
local function initTLOU_OnGameStart(playerIndex, player_init)
	client_player = getPlayer()
	objectList = client_player:getCell():getObjectList()
end
Events.OnCreatePlayer.Remove(initTLOU_OnGameStart)
Events.OnCreatePlayer.Add(initTLOU_OnGameStart)


--#region Custom infection system

-- Associated area of the body for each body parts
TLOU_infected.bodyParts = {
	["Head"]			=		"top",
	["Neck"]			=		"top",
	["Hand_L"]			=		"middle",
	["Hand_R"]			=		"middle",
	["ForeArm_L"]		=		"middle",
	["ForeArm_R"]		=		"middle",
	["UpperArm_L"]		=		"middle",
	["UpperArm_R"]		=		"middle",
	["Torso_Upper"]		=		"middle",
	["Torso_Lower"]		=		"middle",
	["Groin"]			=		"middle",
	["UpperLeg_L"]		=		"bottom",
	["UpperLeg_R"]		=		"bottom",
	["LowerLeg_L"]		=		"bottom",
	["LowerLeg_R"]		=		"bottom",
	["Foot_L"]			=		"bottom",
	["Foot_R"]			=		"bottom",
}

TLOU_infected.areaInfectionTime = {
	top = 1,
	middle = 2,
	bottom = 3,
}

-- Minimal and maximum infection time associated to the area of the body
TLOU_infected.areaInfectionTime = {
	top = {
		min = 5,
		max = 15,
	},
	middle = {
		min = 120,
		max = 480,
	},
	bottom = {
		min = 720,
		max = 1440,
	},
}

-- Retrieves a random infection time for a body part based on it's area on the body.
---@param area string
---@return number
TLOU_infected.GetAreaInfectionTime = function(area)
	local time = TLOU_infected.areaInfectionTime[area]
	return ZombRand(time.min,time.max + 1)
end

-- Checks for infected body parts of a player and the number of it then stores them in mod data.
---@param player IsoPlayer
TLOU_infected.HasInfectedBodyParts = function(player)
	-- initialize mod data
	local playerModData = player:getModData()
	playerModData.TLOU = playerModData.TLOU or {}
	local playerModData_TLOU = playerModData.TLOU or {}

	local infected = playerModData_TLOU.infected or {top = {}, middle = {}, bottom = {}}
	local totalInfection = 0
	local infectionTime

	-- check every body parts
	local bodyParts = player:getBodyDamage():getBodyParts()
	for i = 0, bodyParts:size() - 1 do
		-- retrieve bodyPart i
		local bodyPart = bodyParts:get(i)

		-- get bodyPart name
		local bodyPartID = tostring(bodyPart:getType())
		local area = TLOU_infected.bodyParts[bodyPartID]

		-- retrieve the area associated
		if area then
			-- check bodyPart is already acknowledged as bitten
			infectionTime = infected[area][bodyPartID]

			-- check if bitten
			if bodyPart:IsInfected() then
				-- count bites in this area
				if not infectionTime then
					infected[area][bodyPartID] = TLOU_infected.GetAreaInfectionTime(area)
				end

				-- count bodyParts that are bitten
				totalInfection = totalInfection + 1
			elseif infectionTime then
				infected[area][bodyPartID] = nil
				playerModData_TLOU.oldInfectionTime = nil
			end
		end
	end

	playerModData_TLOU.infected = infected
	playerModData_TLOU.totalInfection = totalInfection
end

-- Retrieve area priority to get infection time:
-- 1. top
-- 2. middle
-- 3. bottom
--
-- Returns area, infected bodyparts and number of infected body parts.
---@param infected table
---@return table
---@return int
---@return string
TLOU_infected.GetAreaPriority = function(infected)
	local size
	for area,bodyParts in pairs(infected) do
		size = 0
		for _,_ in pairs(bodyParts) do
			size = size + 1
		end

		if size > 0 then
			return bodyParts,size,area
		end
	end

	return {},0,""
end

-- Retieve the time before death after being infected, based on the body parts.
---@param bodyParts table
---@param numberInfected int
---@return number
TLOU_infected.GetInfectionTime = function(bodyParts,numberInfected)
	local totalTime = 0
	for _, time in pairs(bodyParts) do
		totalTime = totalTime + time
	end

	return totalTime/numberInfected
end

-- Updates the infection time of each body parts to suit the general infection time of the player.
---@param infectionTime number
---@param area string
TLOU_infected.UpdateInfectionTime = function(infectionTime,area)
	local playerModData_TLOU = client_player:getModData().TLOU

	-- infection time can't go up, so it should either stay same as before or reduce due to new bite
	local oldInfectionTime = client_player:getModData().TLOU.oldInfectionTime
	local newInfectionTime = oldInfectionTime and math.min(infectionTime,oldInfectionTime) or infectionTime

	-- updates oldInfectionTime to keep track of old state bite infection time
	client_player:getModData().TLOU.oldInfectionTime = infectionTime

	-- get bodyParts to update infection time
	local bodyParts = playerModData_TLOU.infected[area]

	-- normalize infection time for each body parts, to reduce the total infection time
	for bodyPart, _ in pairs(bodyParts) do
		bodyParts[bodyPart] = newInfectionTime
	end
end

-- Get how long the player has been infected in hours.
---@param player IsoPlayer
---@return number
TLOU_infected.GetTimeSinceInfected = function(player)
	return player:getHoursSurvived() - player:getBodyDamage():getInfectionTime()
end

math.floor_decimals = function(x,decimales)
	local n = 10^decimales

	return math.floor(x*n)/n
end

-- Handles the custom infection of the player if it was infected.
TLOU_infected.CustomInfection = function()
	local bodyDamage = client_player:getBodyDamage()

	-- check if player is infected
	if bodyDamage:IsInfected() then
		-- check which parts are infected
		TLOU_infected.HasInfectedBodyParts(client_player)
		local playerModData_TLOU = client_player:getModData().TLOU

		-- retrieve bites and check for priority
		local infected = playerModData_TLOU.infected
		local bodyParts, numberInfected, area = TLOU_infected.GetAreaPriority(infected)

		-- retrieve infection time and reduce by a minute
		local infectionTime = TLOU_infected.GetInfectionTime(bodyParts,numberInfected)
		local infectionTime_hour = infectionTime/60

		-- updates oldInfectionTime to keep track of old state body parts infection time
		-- also makes sure the time is never increased if it was modified
		local oldInfectionTime = playerModData_TLOU.oldInfectionTime
		if infectionTime ~= oldInfectionTime then
			TLOU_infected.UpdateInfectionTime(infectionTime,area)
		end

		-- update mortalityDuration if needed
		if bodyDamage:getInfectionMortalityDuration() ~= infectionTime_hour then
			bodyDamage:setInfectionMortalityDuration(infectionTime_hour)
		end
	end
end

--#endregion



-- player cannot push infected
ZomboidForge.NoPush = function(ZType,zombie,bonusData)
	local handWeapon
	if not SandboxVars.TLOU_infected.AllowWeaponPush and bonusData then
		handWeapon = bonusData.handWeapon
	else
		local target = zombie:getTarget()
		handWeapon = target and target:getPrimaryHandItem()
	end

	if instanceof(handWeapon,"HandWeapon") and handWeapon:getFullType() ~= "Base.BareHands" then
		return false
	else
		return true
	end
end

-- grabby infected, slowing you down in place
ZomboidForge.GrabbyInfected = function(ZType,zombie,victim)
	if victim:isAlive() then
		--clicker grabs target
		if not victim:isGodMod() then
			victim:setSlowFactor(1)
			victim:setSlowTimer(1)
		end
	end
end

-- One shot victim
ZomboidForge.KillTarget = function(ZType,zombie,victim)
	-- zombie kills victim
	if not victim:isGodMod() then
		victim:Kill(zombie)
	end
end

-- cap damage to clicker and bloater from player
-- increase damage if on fire
ZomboidForge.ExtraFireDamage = function(data)
	-- ZType,player,zombie,handWeapon,damage
    -- process inputs
    local zombie = data.zombie
    local ZombieTable = data.ZombieTable

	-- if not ZombieTable, retrieve it
	if not ZombieTable then
		local ZType = data.ZType
		if not ZType then
			local trueID = data.trueID or ZomboidForge.pID(zombie)
			ZType = ZomboidForge.GetZType(trueID)
		end
		ZombieTable = ZomboidForge.ZTypes[ZType]
	end

	-- get damage
	local damage = data.damage
	local damageLimiter = ZombieTable.damageLimiter

	-- maximum damage output
	if damageLimiter ~= 0 and damage > damageLimiter then
		damage = damageLimiter
	end

	-- if zombie is on fire, deal more damage even past max damage output
	if zombie:isOnFire() then
		return damage * ZombieTable.fireDamageMultiplier
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
	local timeSinceFlesh = zombie.TimeSinceSeenFlesh/120
	-- if zombie is already in building, completely skip
	-- elseif has target
	-- elseif hasn't been at least N seconds since last update 
	if zombie:getBuilding()
	or zombie:getTarget()
	or zombie:isMoving()
	or (timeSinceFlesh - timeSinceFlesh%1)%(TLOU_infected.HideIndoorsUpdates) ~= 0
	then
		return
	end

	-- lure zombie either to a building or make it wander if it's daytime
	TLOU_infected.LureZombie(zombie)
end

--#endregion