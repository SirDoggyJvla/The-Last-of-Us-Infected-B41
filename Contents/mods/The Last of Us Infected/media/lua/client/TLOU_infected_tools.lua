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

-- Coin flips either `1` or `-1`
---@return integer coinFlip
TLOU_infected.CoinFlip = function()
    local randomNumber = ZombRand(2)

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

-- Lure `Zombie` to the building during daytime or make it wander around during night time.
---@param zombie 		IsoZombie
TLOU_infected.LureZombie = function(zombie)
    if TLOU_ModData.IsDay or not TLOU_infected.WanderAtNight then
		local sourcesq = zombie:getCurrentSquare()
		local squareMoveTo = TLOU_infected.GetClosestBuilding(sourcesq)
		if not squareMoveTo then return end
		zombie:pathToSound(squareMoveTo:getX(), squareMoveTo:getY() ,squareMoveTo:getZ())
    else
		local maxDistance = TLOU_infected.MaxDistanceToCheck
		local x = zombie:getX() + ZombRand(10,maxDistance) * TLOU_infected.CoinFlip()
		local y = zombie:getY() + ZombRand(10,maxDistance) * TLOU_infected.CoinFlip()
        zombie:pathToSound(x, y ,0)
    end
end

--#endregion

--#region IsoBuilding tools

-- Lists to allow easier writing of the code checking buildings
TLOU_infected.ChunkCheck = {}
TLOU_infected.ChunkCheck.FirstCheck = {
	{1,0},
	{-1,0},
	{0,1},
	{0,-1},
	{1,1},
	{1,-1},
	{-1,1},
	{-1,-1},
}
TLOU_infected.ChunkCheck.SecondCheck = {
	{1,1},
	{1,-1},
	{-1,1},
	{1,-1},
}

-- Determines the closest square within a building.
-- Checks in spiral around the original square `sourcesq` and stops when the closest building within
-- a ring of `i` chunk size (up to `maxChunk` size) is found.
---@param sourcesq 		IsoGridSquare
---@return IsoGridSquare|nil 	closestSquare
TLOU_infected.GetClosestBuilding = function(sourcesq)
	-- skip if no buildings available
	if not sourcesq or not TLOU_ModData.BuildingList then return end

	-- initialize data checks
	local closestDist = 100000
	local closestSquare = nil

	-- get coordinates of sourcesq to check distances
	local x_sourcesq = sourcesq:getX()
	local y_sourcesq = sourcesq:getY()

	-- get original chunk of sourcesq and it's data
	local chunk_origin = sourcesq:getChunk()
	local chunkID_origin = TLOU_infected.GetChunkID(chunk_origin)
	local wx_origin = chunk_origin.wx
	local wy_origin = chunk_origin.wy

	-- data to retrieve chunkID by calculating wx and wy positions
	local wx = nil
	local wy = nil
	local chunkID = nil

	-- check if building is in central chunk then stops everything there if detected
	closestDist, closestSquare = TLOU_infected.CheckBuildingDistance(chunkID_origin,closestDist,closestSquare,x_sourcesq,y_sourcesq)
	if closestSquare then return closestSquare end

	-- iterates through max distance
	local maxChunk = TLOU_infected.MaxDistanceToCheck/10
	for i = 1,maxChunk do
		-- check main lines x and y chunks
		for _,j in ipairs(TLOU_infected.ChunkCheck.FirstCheck) do
			wx = wx_origin + i * j[1]
			wy = wy_origin + i * j[2]
			chunkID = tostring(wx).."x"..tostring(wy)
			closestDist, closestSquare = TLOU_infected.CheckBuildingDistance(chunkID,closestDist,closestSquare,x_sourcesq,y_sourcesq)
		end
		-- check side chunks
		for _,j in ipairs(TLOU_infected.ChunkCheck.SecondCheck) do
			for k = 1,i do
				wx = wx_origin + j[1] * k
				wy = wy_origin + j[2] * i
				chunkID = tostring(wx).."x"..tostring(wy)
				closestDist, closestSquare = TLOU_infected.CheckBuildingDistance(chunkID,closestDist,closestSquare,x_sourcesq,y_sourcesq)

				wx = wx_origin + j[1] * i
				wy = wy_origin + j[2] * k
				chunkID = tostring(wx).."x"..tostring(wy)
				closestDist, closestSquare = TLOU_infected.CheckBuildingDistance(chunkID,closestDist,closestSquare,x_sourcesq,y_sourcesq)
			end
		end

		-- stops early if found, no point in going further since it will look at chunks further
		if closestSquare then return closestSquare end
	end
	return closestSquare
end

-- Check building distance from `sourcesq` position and returns closest square and distance from `sourcesq`.
---@param chunkID 				string
---@param closestDist 			double|nil
---@param closestSquare 		IsoGridSquare|nil
---@param x_sourcesq 			double
---@param y_sourcesq 			double
---@return double|nil 			closestDist
---@return IsoGridSquare|nil 	closestSquare
TLOU_infected.CheckBuildingDistance = function(chunkID,closestDist,closestSquare,x_sourcesq,y_sourcesq)
	if TLOU_ModData.BuildingList[chunkID] then
		for _,buildingData in pairs(TLOU_ModData.BuildingList[chunkID]) do
			local square = getSquare(buildingData[1],buildingData[2],0)
			if square then
				local building = square:getBuilding()
				if building then
					local squareCheck = building:getRandomRoom():getRandomFreeSquare()
					if squareCheck then
						local distance = IsoUtils.DistanceTo(x_sourcesq, y_sourcesq, squareCheck:getX() , squareCheck:getY())
						-- check if distance < closestDist, if true then next test
						-- if OnlyUnexplored is false, then ignore the rest and pass
						-- if OnlyUnexplored is true, check if whole building is explored, if true then don't pass, if false then pass
						if distance and distance < closestDist and
						(not TLOU_infected.OnlyUnexplored or not building:isAllExplored())
						then
							closestDist = distance
							closestSquare = squareCheck
						end
					end
				end
			end
		end
	end
	return closestDist, closestSquare
end

-- Adds detected buildings to the list of available buildings in a chunk.
TLOU_infected.AddBuildingList = function(square)
	-- get moddata and check if BuildingList exists, else initialize it
	TLOU_ModData.BuildingList = TLOU_ModData.BuildingList or {}

	-- check if square is in building
	local building = square:getBuilding()
	if not building then return end

	-- get building ID via it's KeyID which is persistent
	local buildingID = building:getDef():getKeyId()

	-- get chunk ID
	local chunk = square:getChunk()
	local chunkID = TLOU_infected.GetChunkID(chunk)

	-- check if building is already in BuildingList, if not add its coordinates to the list
	TLOU_ModData.BuildingList[chunkID] = TLOU_ModData.BuildingList[chunkID] or {}
	if not TLOU_ModData.BuildingList[chunkID][buildingID] then
		local room = building:getRandomRoom()
		local squareBuilding = room:getRandomFreeSquare()
		if squareBuilding then
			TLOU_ModData.BuildingList[chunkID][buildingID] = {squareBuilding:getX(),squareBuilding:getY()}
		end
	end
end

--#endregion

--#region Time tools

-- Determines if it's daytime based on the time given and the season.
local season2daytime = {
	Spring = function(hour) return hour >= 6 and hour <= 21 end,
	Summer = function(hour) return hour >= 6 and hour <= 22 end,
	Autumn = function(hour) return hour >= 6 and hour <= 21 end,
	Winter = function(hour) return hour >= 8 and hour <= 17 end,
}

-- Used with `month2season` to access season based on month.
local listOfSeasons = {
	"Winter",
	"Spring",
	"Summer",
	"Autumn",
}
-- Retrieve the season based on the month.
---@param month		int
---@return string
local function month2season(month)
	return listOfSeasons[ math.floor( (month+2)/3 ) % 4 + 1 ]
end

-- Checks if it's daytime by taking into account the seasons and updates the `IsDay` check.
TLOU_infected.IsDay = function()
	-- update IsDay check
	TLOU_ModData.IsDay = season2daytime[ month2season(gametime:getMonth()) ]( math.floor(gametime:getTimeOfDay()) )
end

--#endregion