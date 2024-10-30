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
local function initTLOU_OnGameStart(playerIndex, player_init)
	player = getPlayer()
end
Events.OnCreatePlayer.Remove(initTLOU_OnGameStart)
Events.OnCreatePlayer.Add(initTLOU_OnGameStart)


-- Add fungi hat food type on a Clicker's death.
---@param zombie IsoZombie
---@param ZType string
---@param ZombieTable table
ZomboidForge.OnClickerDeath = function(zombie,ZType,ZombieTable)
	-- add fungi hat food type to inventory
	local inventory = zombie:getInventory()
	inventory:AddItems("TLOU.Hat_Fungi_Loot",1)
end

--#region Custom behavior: `ClickerAgro`

-- Manage Clicker agro to change their animation when they run after a player.
---@param zombie IsoZombie
---@param ZType string
---@param ZombieTable table
---@param tick int
ZomboidForge.ClickerAgro = function(zombie,ZType,ZombieTable,tick)
	-- check only every 15 ticks
	if tick%15 ~= 0 then return end

	-- if target, then Clicker is in agro stance, else go back to chill after a while
	local target = zombie:getTarget()
	local agro = zombie:getVariableBoolean("ClickerAgro")
	if target then
		if not agro then
			zombie:setVariable("ClickerAgro",'true')
		end
	else
		if agro and zombie.TimeSinceSeenFlesh > 1000 then
			zombie:setVariable("ClickerAgro",'false')
		end
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
ZomboidForge.ClickerBehavior = function(zombie,ZType,ZombieTable,tick)
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