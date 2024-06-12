--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

The Stalker behavior is written in this file

]]--
--[[ ================================================ ]]--

--- Import functions localy for performances reasons
local table = table -- Lua's table module
local ipairs = ipairs -- ipairs function
local pairs = pairs -- pairs function
local ZombRand = ZombRand -- java function
local smokeFlag = IsoFlagType.smoke

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

-- localy initialize player
local player = getPlayer()
local function initTLOU_OnGameStart()
	player = getPlayer()
end
Events.OnGameStart.Remove(initTLOU_OnGameStart)
Events.OnGameStart.Add(initTLOU_OnGameStart)

---@param zombie 				IsoZombie
---@param ZType	 				string   	--Zombie Type ID
ZomboidForge.StalkerBehavior = function(zombie,ZType)
	--[[
	The idea is that the Stalker picks up a target the first time and this target is registered in
	PersistentZData.TLOU_infected.target or just PersistentZData.target (not decided yet)

	step

	if getTarget() or PersistentZData.TLOU_infected.target then
		update agrometer for this stalker
	else
		return
	end

	if Agrometer > whatever value
		zombie:setUseless(false)
		zombie:setTarget(PersistentZData.TLOU_infected.target)
	else
		zombie:setUseless(true) --deactivate targeting
		PersistentZData.TLOU_infected.target = getTarget() --if target
	]]

	local trueID = ZomboidForge.pID(zombie)
	local PersistentZData_TLOU = ZomboidForge.GetPersistentZData(trueID,"TLOU_infected")

	--zombie:setTarget(player)
	-- get target
	local target = PersistentZData_TLOU.target
	local agrometer = TLOU_infected.UpdateAgrometer(zombie,player)
	-- if no target, verify Stalker didn't pick up a new target
	if not target then
		target = zombie:getTarget()
	end

	-- if no target anymore then means no target is available, allow Stalker to pick up a new target
	if not target then
		TLOU_infected.SwitchUseless(zombie,false)
		return
	end

	-- verify target is a player
	if not instanceof(target,"IsoPlayer") then
		TLOU_infected.SwitchUseless(zombie,false)
		PersistentZData_TLOU.target = nil
		return
	elseif not PersistentZData_TLOU.target then
		PersistentZData_TLOU.target = target
	end
	-- Stalker has now acquired a valid target and will stalk it
	---@cast target IsoPlayer

	-- verify target is alive
	-- if not then delete any possible trace of the target
	if not target:isAlive() then
		PersistentZData_TLOU.target = nil
		return
	end

	-- need distance check to stop Stalker from having a target is target is too far

	-- update Agrometer
	--local agrometer = TLOU_infected.UpdateAgrometer(zombie,target)
	local threshold = 100
	-- needs tweaking but max would maybe be 100 ?
	-- if sandbox options to chose what affects a Stalker decision the need to take into account the
	-- total decrease of overall Agrometer
	-- for that maybe take 70% of total agrometer max value resources ?

	-- if agrometer is above threshold, make stalker rush at target
	-- elseif below lose agro threshold then doesn't have enough agro to fuck around with its target anymore
	-- else go back to useless mode
	if agrometer > threshold then
		TLOU_infected.SwitchUseless(zombie,false)
		zombie:setTarget(target)
		zombie:pathToLocation(target:getX(),target:getY(),target:getZ())
		--zombie:pathToCharacter(target)
	elseif agrometer < -100 then
		TLOU_infected.SwitchUseless(zombie,false)
		PersistentZData_TLOU.target = nil

		--sq smoke stops target selecting
		zombie:getSquare():getProperties():Set(smokeFlag)
	else
		--sq smoke stops target selecting
		zombie:getSquare():getProperties():Set(smokeFlag)
		zombie:setTarget(nil)

		local zombieVelocity = TLOU_infected.GetZombieVelocity(zombie)

		-- Negate game movement.
		local negativeZombieVelocity = zombieVelocity:clone():set(-zombieVelocity:getX(), -zombieVelocity:getY())
		zombie:MoveUnmodded(negativeZombieVelocity)

		local target_x, target_y, target_z = target:getX(), target:getY(), target:getZ()
		local zombie_x, zombie_y, zombie_z = zombie:getX(), zombie:getY(), zombie:getZ()

		local r_x, r_y = zombie_x - target_x, zombie_y - target_y
		local r = math.sqrt(r_x*r_x + r_y*r_y)
		local rt_x, rt_y = -r_y, r_x

		local multi = math.sqrt(zombieVelocity:getX()^2 + zombieVelocity:getY()^2)
		local velocity_x, velocity_y = multi*rt_x/r, multi*rt_y/r

		local vector = Vector2.new(velocity_x,velocity_y)
		zombie:MoveUnmodded(vector)
		zombie:setForwardDirection(vector)
		--zombie:pathToLocationF(zombie_x + velocity_x,zombie_y + velocity_y,zombie_z)
	end
end

-- Defines the various values depending on conditions that will add up to the agrometer.
-- Some of those have a high sensitivity, meaning they will affect the agrometer very high
-- then there's medium and low
TLOU_infected.AgrometerData = {
	--- high sensitivity
	-- target sees stalker
	canSee = {
		[true] = 100,
		[false] = -30,
	},
	-- wall between target and zombie
	wall = {
		[true] = -30,
		[false] = 60,
	},
	weapon = {
		[true] = -30,
		[false] = 60,
	},
	isRunning = {
		[true] = 60,
		[false] = 0,
	},

	--- medium sensitivity
	isHurt = {
		[true] = -20,
		[false] = 20,
	},

	--- low sensitivity
	isDay = {
		[true] = -10,
		[false] = 10,
	},
	inBuilding = {
		[true] = -10,
		[false] = 10,
	},
}

TLOU_infected.UpdateAgrometer = function(zombie,target)
	local agrometer = 0
	local AgrometerData = TLOU_infected.AgrometerData

	--- high sensitivity
	local canSee = AgrometerData.canSee[target:getLastSeenZomboidTime() ~= 0]
	agrometer = agrometer + canSee

	local wall = AgrometerData.wall[target:CanSee(zombie)]
	agrometer = agrometer + wall

	local weapon = AgrometerData.weapon[target:getPrimaryHandItem() and true or false]
	agrometer = agrometer + weapon

	local isRunning = AgrometerData.isRunning[target:isRunning() or target:isSprinting()]
	agrometer = agrometer + isRunning

	--- low sensitivity
	local inBuilding = AgrometerData.inBuilding[zombie:getBuilding() and true or false]
	agrometer = agrometer + inBuilding

	local isDay = AgrometerData.isDay[TLOU_ModData.IsDay]
	agrometer = agrometer + isDay


	--- direct values
	local patience = math.floor(zombie:getPatience()/10) -- perhaps needs tweaking
	agrometer = agrometer + patience

	local fleshTime = math.floor(zombie.TimeSinceSeenFlesh/120)
	agrometer = agrometer + fleshTime

	-- check number of zombies chasing
	local chased = target:getStats():getNumChasingZombies()
	if chased >= 10 then
		agrometer = 200
	elseif chased >= 5 then
		agrometer = agrometer + 60
	elseif chased >= 2 then
		agrometer = agrometer + 10
	end

	-- check distance
	local distance = math.floor(zombie:getDistanceSq(target))
	if distance <= 25 then
		agrometer = 200
	end

	--isFacingTarget()

	local stringZ = ""
	stringZ = stringZ.."\n".."canSee = "..tostring(canSee)
	stringZ = stringZ.."\n".."wall = "..tostring(wall)
	stringZ = stringZ.."\n".."weapon = "..tostring(weapon)
	stringZ = stringZ.."\n".."isRunning = "..tostring(isRunning)

	stringZ = stringZ.."\n".."isDay = "..tostring(isDay)
	stringZ = stringZ.."\n".."inBuilding = "..tostring(inBuilding)

	stringZ = stringZ.."\n".."patience = "..tostring(patience)
	stringZ = stringZ.."\n".."fleshTime = "..tostring(fleshTime)
	stringZ = stringZ.."\n".."distance = "..tostring(distance)

	stringZ = stringZ.."\n".."isUseless = "..tostring(zombie:isUseless())
	stringZ = stringZ.."\n".."target = "..tostring(zombie:getTarget())
	stringZ = stringZ.."\n".."agrometer = "..tostring(agrometer)
	zombie:addLineChatElement(stringZ)
	--zombie:addLineChatElement("Stalker")

	return agrometer
end