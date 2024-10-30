--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the tools for the mod of The Last of Us Infected

]]--
--[[ ================================================ ]]--

--- Import functions localy for performances reasons
local table = table -- Lua's table module
local ipairs = ipairs -- ipairs function
local pairs = pairs -- pairs function
local tostring = tostring --tostring function

--- import module from ZomboidForge
local ZomboidForge = require "ZomboidForge_module"
local TLOU_infected = require "TLOU_infected"

--- import GameTime localy for performance reasons
local gametime = GameTime:getInstance()

-- localy initialize mod data
local TLOU_ModData = ModData.getOrCreate("TLOU_Infected")
local function initTLOU_ModData()
	TLOU_ModData = ModData.getOrCreate("TLOU_Infected")
end
Events.OnInitGlobalModData.Remove(initTLOU_ModData)
Events.OnInitGlobalModData.Add(initTLOU_ModData)


-- localy initialize player and zombie list
local client_player = getPlayer()
local function initTLOU_OnGameStart(_, _)
	client_player = getPlayer()
end
Events.OnCreatePlayer.Remove(initTLOU_OnGameStart)
Events.OnCreatePlayer.Add(initTLOU_OnGameStart)

--#region Debug tools

-- For debug purposes, allows to check vocals of a zombie.
---@param zombie 		IsoZombie
---@return string
TLOU_infected.VerifyEmitter = function(zombie)
	local stringZ = "Emitters:"
	stringZ = stringZ.."\nMaleA = "..tostring(zombie:getEmitter():isPlaying("Zombie/Voice/MaleA"))
	stringZ = stringZ.."\nFemaleA = "..tostring(zombie:getEmitter():isPlaying("Zombie/Voice/FemaleA"))
	stringZ = stringZ.."\nMaleB = "..tostring(zombie:getEmitter():isPlaying("Zombie/Voice/MaleB"))
	stringZ = stringZ.."\nFemaleB = "..tostring(zombie:getEmitter():isPlaying("Zombie/Voice/FemaleB"))
	stringZ = stringZ.."\nMaleC = "..tostring(zombie:getEmitter():isPlaying("Zombie/Voice/MaleC"))
	stringZ = stringZ.."\nFemaleC = "..tostring(zombie:getEmitter():isPlaying("Zombie/Voice/FemaleC"))
	return stringZ
end

--#endregion

--#region General tools

local randCoinFlip = newrandom()
-- Coin flips either `1` or `-1`
---@return integer coinFlip
TLOU_infected.CoinFlip = function()
    local randomNumber = randCoinFlip:random(0,1)

    if randomNumber == 0 then
        return -1
    else
        return 1
    end
end

-- Retrieves the ID of a chunk, from it's coordinates `wx` and `wy`
---@param chunk IsoChunk
---@return string chunkID
TLOU_infected.GetChunkID = function(chunk)
	return tostring(chunk.wx).."x"..tostring(chunk.wy)
end

--#endregion

--#region Building and lure tools

-- Retrieves a square within the closest building to the `zombie` in a `radius`.
---@param zombie IsoZombie
---@param radius int
---@return IsoGridSquare|nil
TLOU_infected.GetClosestBuildingSquareAroundZombie = function(zombie,radius)
	-- get zombie coordinates
	local zed_x = zombie:getX()
	local zed_y = zombie:getY()
	local zed_z = zombie:getZ()

	-- optimization to reduce operations
	local radius2 = radius * radius
	local x_min = zed_x - radius
	local x_max = zed_x + radius
	local y_min = zed_y - radius
	local y_max = zed_y + radius

	local square

	-- check for building on floor or a floor above
	for z = 0,1 do
		for x = x_min, x_max, 5 do
			for y = y_min, y_max, 5 do
				if (x - zed_x) * (x - zed_x) + (y - zed_y) * (y - zed_y) <= radius2 then
					square = getSquare(x, y, zed_z + z)
					if square and square:getBuilding() then
						return square
					end
				end
			end
		end
	end

	local z = zed_z - 1
	-- check a floor below
	for x = x_min, x_max, 5 do
		for y = y_min, y_max, 5 do
			if (x - zed_x) * (x - zed_x) + (y - zed_y) * (y - zed_y) <= radius2 then
				square = getSquare(x, y, z)
				if square and square:getBuilding() then
					return square
				end
			end
		end
	end

    return nil
end

--#endregion


--#region Behavior tools

---@param zombie 				IsoZombie
---@param goal 					boolean
TLOU_infected.SwitchUseless = function(zombie,goal)
	if zombie:isUseless() ~= goal then
		zombie:setUseless(goal)
	end
end

TLOU_infected.GetZombieVelocity = function(zombie)
	return Vector2.new(zombie:getNx() - zombie:getX(), zombie:getNy() - zombie:getY())
end
--#endregion

--#region Damage to Infected

local class_HandWeapon = __classmetatables[HandWeapon.class].__index
TLOU_infected.WeaponCheck = {
	{func = class_HandWeapon.getKnockdownMod, multiplier = 1, name = "knockdown"},
	{func = class_HandWeapon.getStopPower, multiplier = 1, name = "stopPower"},
	{func = class_HandWeapon.getPushBackMod, multiplier = 1, name = "pushBackMod"},
	{func = class_HandWeapon.getDoorDamage, multiplier = 1, name = "doorDamage"},
	-- {func = class_HandWeapon.isPiercingBullets, multiplier = 1, defaultTrue = 10, defaultFalse = -20, name = "doorDamage"},
}

--#endregion