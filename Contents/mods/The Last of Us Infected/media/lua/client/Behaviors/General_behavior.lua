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
local CaliberData = require "TLOU_infected_caliberStats"
local random = newrandom()

--- import GameTime localy for performance reasons
local gametime = GameTime:getInstance()

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
	local playerModData_TLOU = playerModData.TLOU

	-- retrieve infection table or define it
	local infected = playerModData_TLOU.infected or {top = {}, middle = {}, bottom = {}}

	-- check every body parts for infections
	local bodyParts = player:getBodyDamage():getBodyParts()
	local bodyPart
	local bodyPartID
	local area
	local infectionTime
	for i = 0, bodyParts:size() - 1 do
		-- retrieve bodyPart i
		bodyPart = bodyParts:get(i)

		-- get bodyPart name and area
		bodyPartID = tostring(bodyPart:getType())
		area = TLOU_infected.bodyParts[bodyPartID]

		-- verify bodyPart has an area associated
		if area then
			-- check bodyPart is already acknowledged as bitten
			infectionTime = infected[area][bodyPartID]

			-- check if infected
			if bodyPart:IsInfected() then
				-- count bites in this area
				if not infectionTime then
					infected[area][bodyPartID] = TLOU_infected.GetAreaInfectionTime(area)
				end

			-- no longer infected, so just remove it from the list
			elseif infectionTime then
				infected[area][bodyPartID] = nil

				-- reset old infection time
				playerModData_TLOU.oldInfectionTime = nil
			end
		end
	end

	playerModData_TLOU.infected = infected
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
	local chosenTime = 1000000
	for _, time in pairs(bodyParts) do
		if time < chosenTime then
			chosenTime = time
		end
	end

	return chosenTime*(1 - numberInfected*0.05)
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
	if bodyParts then
		for bodyPart, _ in ipairs(bodyParts) do
			bodyParts[bodyPart] = newInfectionTime
		end
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
	elseif client_player:getModData().TLOU then
		client_player:getModData().TLOU = nil
	end
end

--#endregion

--#region Can't stand on infected

TLOU_infected.StandOnInfectedPriority = {
	TLOU_Bloater = 1,
	TLOU_Clicker = 2,
	TLOU_Stalker = 3,
	TLOU_Runner = 4,
}

-- can't stand on infected
ZomboidForge.CantStantOnInfected = function(zombie,ZType,ZombieTable,tick)
	-- check only every 15 ticks to reduce performance impact
	if tick%15 ~= 0 then return end

	local staggered = TLOU_infected.StandOnInfected_Stagger and not zombie:isProne()
	if zombie:isBeingSteppedOn() and not staggered then
		local z_x = zombie:getX()
		local z_y = zombie:getY()

		-- take into account when in stairs
		local z_z = zombie:getZ()
		z_z = z_z - z_z%1

		-- check squares around the zombie for either players or zombies and stagger all of these after some time
		local square
		local movingObjects
		local StandOnInfectedPriority = TLOU_infected.StandOnInfectedPriority
		local zombie_priority = StandOnInfectedPriority[ZType]
		for i = -1,1 do
			for j = -1,1 do
				square = getSquare(z_x+i,z_y+j,z_z)
				if square then
					-- access moving objects
					movingObjects = square:getMovingObjects()
					for k = 0, movingObjects:size() - 1 do
						local movingObject = movingObjects:get(k)

						-- zed needs to be on the same level
						local m_z = movingObject:getZ()
						if m_z - m_z%1 == z_z then
							-- check if the moving objects are other zombies or players
							local isZombie = instanceof(movingObject,"IsoZombie")
							local isPlayer = instanceof(movingObject,"IsoPlayer")
							if isPlayer or isZombie and movingObject ~= zombie then
								-- verify the moving object is standing on the zombie
								if ZombieOnGroundState.isCharacterStandingOnOther(movingObject,zombie) then
									-- check how long the zombie has been stepped on
									local timer = zombie:getModData().TLOU_standOnMeTimer
									if timer then
										-- movingObject:addLineChatElement(tostring(os.time() - timer))
										-- check threshold for this infected type
										if os.time() - timer > ZombieTable.standOnInfected then
											-- reaction to player
											if isPlayer then
												movingObject:setBumpType("stagger");
												movingObject:setVariable("BumpFall", false);
												movingObject:setVariable("BumpDone", true);
												movingObject:setVariable("BumpFallType", "pushedFront");
												zombie:getModData().TLOU_standOnMeTimer = nil

											-- reaction to zombie
											elseif isZombie and not movingObject:isProne() then
												-- each infected has priority over some types, runners being the weakess
												-- and bloaters the strongest
												-- if the movingObject is not valid then stagger anyway
												local trueID_movingObject = ZomboidForge.pID(movingObject)
												local ZType_movingObject = ZomboidForge.GetZType(trueID_movingObject)

												local movingObject_priority = StandOnInfectedPriority[ZType_movingObject]
												if not movingObject_priority or zombie_priority <= movingObject_priority then
													movingObject:setStaggerBack(true)
													zombie:getModData().TLOU_standOnMeTimer = nil
												end
											end
										end
									else
										zombie:getModData().TLOU_standOnMeTimer = os.time()
									end
								end
							end
						end
					end
				end
			end
		end
	elseif zombie:getModData().TLOU_standOnMeTimer then
		zombie:getModData().TLOU_standOnMeTimer = nil
	end
end

--#endregion

ZomboidForge.hitTimeReaction = function(ZType,zombie,bonusData)
	if not bonusData then return nil end

	-- get zombie data
	local ZombieTable = ZomboidForge.ZTypes[ZType]

	-- retrieve current hit time and weapon used
	local currentHitTime = bonusData.currentHitTime

	-- don't chip armor if hand attack
	if bonusData.handPush or bonusData.footStomp then
		return currentHitTime
	end

	-- armor was already pierced
	local totalArmor = ZombieTable.totalArmor
	if currentHitTime >= totalArmor then
		return totalArmor
	end

	-- retrieve handWeapon
	local handWeapon = bonusData.handWeapon

	-- check is ranged
	local isRanged = handWeapon:isRanged()

	-- handle weapon as ranged
	if isRanged then
		-- check ammo type
		local ammoType = handWeapon:getAmmoType()
		if ammoType then
			-- access caliber stats
			local bulletData = CaliberData[ammoType]
			if bulletData then
				-- verify bullet should damage armor
				if bulletData.increaseHitTime then
					local bulletEnergyMinimum = bulletData.Emin
					local bulletEnergyMaximum = bulletData.Emax
					local zombieEnergyRequired = ZombieTable.energyRequired

					-- will damage OR might damage and coin flip for damage
					if bulletEnergyMinimum >= zombieEnergyRequired
					or bulletEnergyMaximum >= zombieEnergyRequired and random:random(1,2) == 1 then
						local ratio = (bulletEnergyMinimum + bulletEnergyMaximum)/(2*zombieEnergyRequired)
						ratio = ratio - ratio%1

						return currentHitTime + ratio
					end
				end

				return currentHitTime
			end
		end

	-- handle weapon as melee
	else
		-- weapon is heavy and will chunk armor by a lot
		if handWeapon:isAlwaysKnockdown() then
			return currentHitTime + 4
		end
	end
end

ZomboidForge.customDamage_tankyInfected = function(data)
	if data.ZType == "TLOU_Clicker" then
		-- ignore foot stomping damage if option is set
		if data.footStomp and TLOU_infected.NoStompClickers then
			return 0
		end
	end

	-- ZType,player,zombie,handWeapon,damage
    -- process inputs
    local zombie = data.zombie
    local ZombieTable = data.ZombieTable

	local handWeapon = data.handWeapon
	-- check is ranged
	local isRanged = handWeapon:isRanged()

	-- handle weapon as ranged
	local ratio = 1
	if isRanged then
		-- check ammo type
		local ammoType = handWeapon:getAmmoType()
		if ammoType then
			-- access caliber stats
			local bulletData = CaliberData[ammoType]
			if bulletData then
				-- verify bullet should damage armor
				if bulletData.increaseHitTime then
					local energyInBullet = (bulletData.Emin + bulletData.Emax)/2
					local zombieEnergyRequired = ZombieTable.energyRequired

					ratio = energyInBullet/zombieEnergyRequired + 1
				end
			end
		end
	end

	-- get damage
	local hitTime = zombie:getHitTime()
	local multiplier = (hitTime/ZombieTable.totalArmor)^4 * 4
	local damage = data.damage/hitTime^2*multiplier*ratio

	-- if zombie is on fire, deal more damage even past max damage output
	if ZombieTable.extrafireDamage and zombie:isOnFire() then
		return damage * ZombieTable.fireDamageMultiplier
	end

	return damage
end

-- player cannot push infected
ZomboidForge.NoPush = function(ZType,zombie,bonusData)
	local handWeapon
	if not TLOU_infected.AllowWeaponPush and bonusData then
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
ZomboidForge.GrabbyInfected = function(data)
	-- verify victim is alive and not in god mode
	local victim = data.victim
	if not victim:isAlive() or victim:isGodMod() then return end

	-- infected grabs target
	victim:setSlowFactor(1)
	victim:setSlowTimer(1)
end

-- One shot victim
ZomboidForge.KillTarget = function(data)
	-- verify victim is alive and not in god mode
	local victim = data.victim
	if not victim:isAlive() or victim:isGodMod() then return end

	-- verify attack is valid
	if data.attackOutcome ~= "success" or data.hitReaction ~= "Bite" then return end

	-- kill player
	local zombie = data.zombie
	victim:Kill(zombie)
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
---@param zombie IsoZombie
---@param ZType string
---@param ZombieTable table
ZomboidForge.OnInfectedDeath_cordyceps = function(zombie,ZType,ZombieTable)
	-- roll to inventory
	local rand = ZombRand(1,100)
	if ZombieTable.lootchance >= rand then
		zombie:getInventory():AddItems("Cordyceps", ZombieTable.roll_lootcount())
	end
end


--#region Custom behavior: `HideIndoors`

-- Main function to handle `Zombie` behavior to go hide inside the closest building or wander during night.
---@param zombie IsoZombie
---@param ZType string
---@param ZombieTable table
---@param tick int
ZomboidForge.HideIndoors = function(zombie,ZType,ZombieTable,tick)
	-- if on server, only the zombie owner should handle the client
	local onServer = isClient()
	if onServer then
		-- if on server, verify owner of the zombie is the client to handle zombie
		local zombieOwner = zombie.authOwnerPlayer
		if not zombieOwner or zombieOwner ~= client_player then return end
	end

	-- check only every 15 ticks
	if tick%15 ~= 0 then return end

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

	-- max distance and intialize local variables
	local maxDistance = TLOU_infected.MaxDistanceToCheck
	local x
	local y
	local z = 0

	-- verify if zombie should hide inside
    if gametime:getNight() < 0.5 or not TLOU_infected.WanderAtNight then
		-- retrieve nearest building
		local squareMoveTo = TLOU_infected.GetClosestBuildingSquareAroundZombie(zombie,maxDistance)
		if not squareMoveTo then return end

		-- get coordinates of building square
		x = squareMoveTo:getX()
		y = squareMoveTo:getY()
		z = squareMoveTo:getZ()

	-- or roam around during night time
    else
		x = zombie:getX() + ZombRand(10,maxDistance) * TLOU_infected.CoinFlip()
		y = zombie:getY() + ZombRand(10,maxDistance) * TLOU_infected.CoinFlip()
    end

	if x then
		-- path towards coordinates
		if not onServer then
			zombie:pathToSound(x, y ,z)

		-- send a call to server to tell everyone to path
		else
			sendClientCommand(
				'ZombieHandler',
				'PathToSound',
				{
					zombie = zombie:getOnlineID(),
					x=x, y=y, z=z,
				}
			)
		end
	end
end

--#endregion