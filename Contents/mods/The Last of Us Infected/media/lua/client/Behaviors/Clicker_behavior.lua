--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

The Clicker behavior is written in this file

]]--
--[[ ================================================ ]]--

--- Import functions localy for performances reasons
local table = table -- Lua's table module
local ipairs = ipairs -- ipairs function
local pairs = pairs -- pairs function
local ZombRand = ZombRand -- java function

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


-- clicker attacks a player
function ZomboidForge.ClickerAttack(ZType,target,zombie)
	if target and target:isAlive() then
		--clicker grabs target
		if SandboxVars.TLOU_infected.GrabbyClickers and not target:isGodMod() then
			target:setSlowFactor(1)
			target:setSlowTimer(1)
		end

		-- kill target if oneshot clickers
		if target == player and SandboxVars.TLOU_infected.OneShotClickers then
			if target:hasHitReaction() and not target:isGodMod() then
				--target:setDeathDragDown(true)
				target:Kill(zombie)
				if isClient() then
					sendClientCommand('Behavior','KillTarget',{zombie = zombie:getOnlineID()})
				end
			end
		end
	end
end

-- Replace fungi hat clothing with fungi hat food type on a `Clicker`'s death.
---@param zombie 		IsoZombie
---@param _		 		string   	--Zombie Type ID
ZomboidForge.OnClickerDeath = function(zombie,_)
	-- add fungi hat food type to inventory
	local inventory = zombie:getInventory()
	inventory:AddItems("Hat_Fungi_Loot",1)
end

--#region Custom behavior: `SetClickerClothing`

-- clothing priority to replace
TLOU_infected.ClothingPriority = {
	["Hat"] = 1,
	["Mask"] = 2,
	["Eyes"] = 3,
	["LeftEye"] = 4,
	["RightEye"] = 5,
	["Nose"] = 6,
	["BellyButton"] = 7,
	["Right_MiddleFinge"] = 8,
	["Left_MiddleFinger"] = 9,
	["Right_RingFinger"] = 10,
	["Left_RingFinger"] = 11,
	["Ears"] = 12,
	["EarTop"] = 13,
	["Necklace"] = 14,
	["Necklace_Long"] = 15,
	["UnderwearTop"] = 16,
	["UnderwearBottom"] = 17,
	["UnderwearExtra1"] = 18,
	["UnderwearExtra2"] = 19,
	["Underwear"] = 20,
	["Socks"] = 21,
	["RightWrist"] = 22,
	["LeftWrist"] = 23,
	["Tail"] = 24,

	["Hands"] = 25,
	["Belt"] = 26,
	["BeltExtra"] = 27,
	["AmmoStrap"] = 28,
	["Scarf"] = 29,
	["Neck"] = 30,
	["TorsoExtra"] = 31,
	["TankTop"] = 32,
	["Tshirt"] = 33,
	["ShortSleeveShirt"] = 34,
	["Shirt"] = 35,
	["Sweater"] = 36,
	["TorsoExtraVest"] = 37,
	["Pants"] = 38,
	["Skirt"] = 39,
	["Torso1Legs1"] = 40,
	["Legs1"] = 41,
	["Shoes"] = 42,
	["Jacket"] = 43,
}

--#endregion

--#region Custom behavior: `ClickerAgro`

-- Manage Clicker agro to change their animation when 
-- they run after a player.
---@param zombie 		IsoZombie
---@param ZType 		string   	     --Zombie Type ID
ZomboidForge.ClickerAgro = function(zombie,ZType)
	local target = zombie:getTarget()
	if target and not zombie:getVariableBoolean("ClickerAgro") then
		zombie:setVariable("ClickerAgro",'true')
	elseif not target and zombie:getVariableBoolean("ClickerAgro") then
		zombie:setVariable("ClickerAgro",'false')
	end
end
--#endregion


-- custom targeting of Clickers to make them attack other zombies when blind
--[[

if storeZombie and storeZombie ~= zombie and zombie:getTarget() ~= storeZombie then
	zombie:setTarget(storeZombie)
	zombie:setAttackedBy(storeZombie)
	print("setting target")
end
storeZombie = zombie
zombie:addLineChatElement(tostring(zombie:getTarget()))
]]

--#region Custom Behavior: Blind Clickers

local stringZ = ""
---@param zombie 				IsoZombie
---@param ZType	 				string   	--Zombie Type ID
ZomboidForge.ClickerBehavior = function(zombie,ZType)
	--[[
		awake player if action nearby that should, this sets a temporary target to reset
		TimeSinceSeenFlesh
		if TimeSinceSeenFlesh goes above a certain number then set zombie back to sleep
		TimeSinceSeenFlesh resets when struck by an attack

		when awake, force roam around the point of awakening or towards the target
		also force awake if not in building to go inside nearest building

		setUseless can be used to stop the clicker from setting a target but still 
		allows him to move around
	]]

	stringZ = ""

	local target = zombie:getTarget()
	stringZ = stringZ.."\n".."target = "..tostring(target)

	local alerted = zombie.alerted
	stringZ = stringZ.."\n".."alerted = "..tostring(alerted)

	local realState = zombie:getRealState()
	stringZ = stringZ.."\n".."realState = "..tostring(realState)

	local targetTime = math.floor(zombie:getTargetSeenTime())
	stringZ = stringZ.."\n".."targetTime = "..tostring(targetTime)

	local fleshTime = math.floor(zombie.TimeSinceSeenFlesh)
	stringZ = stringZ.."\n".."fleshTime = "..tostring(fleshTime)

	local action = zombie:isIgnoreStaggerBack()
	--zombie:setIgnoreStaggerBack(true)
	stringZ = stringZ.."\n".."action = "..tostring(action)

	--zombie:addLineChatElement(stringZ)
end

--#endregion