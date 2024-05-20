--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the core of the mod of The Last of Us Infected

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
local TLOU_ModData = ModData.getOrCreate("TLOU_Infected")

ZomboidForge.initTLOU_ModData = function()
	TLOU_ModData = ModData.getOrCreate("TLOU_Infected")
end

--- import GameTime localy for performance reasons
local gametime = GameTime:getInstance()

--- setup local functions
ZomboidForge.TLOU_infected = {}

-- Sandbox options imported localy for performance reasons
-- used here for file reloads in-game
ZomboidForge.TLOU_infected.lootchance = {
	TLOU_Runner = SandboxVars.TLOU_infected.CordycepsSpawnRate_Runner,
	TLOU_Stalker = SandboxVars.TLOU_infected.CordycepsSpawnRate_Stalker,
	TLOU_Clicker = SandboxVars.TLOU_infected.CordycepsSpawnRate_Clicker,
	TLOU_Bloater = SandboxVars.TLOU_infected.CordycepsSpawnRate_Bloater,
}
ZomboidForge.TLOU_infected.HideIndoorsUpdates = math.floor(SandboxVars.TLOU_infected.HideIndoorsUpdates * 1.2)
ZomboidForge.TLOU_infected.OnlyUnexplored = SandboxVars.TLOU_infected.OnlyUnexplored
ZomboidForge.TLOU_infected.WanderAtNight = SandboxVars.TLOU_infected.WanderAtNight
ZomboidForge.TLOU_infected.MaxDistanceToCheck = SandboxVars.TLOU_infected.MaxDistanceToCheck

--- Create zombie types
ZomboidForge.Initialize_TLOUInfected = function()
	-- roll lootcount functions depending on infected type
	ZomboidForge.TLOU_infected.roll_lootcount = {
		TLOU_Runner = function() return ZombRand(1,3) end,
		TLOU_Stalker = function() return ZombRand(1,5) end,
		TLOU_Clicker = function() return ZombRand(3,5) end,
		TLOU_Bloater = function() return ZombRand(5,15) end,
	}

	-- Sandbox options imported localy for performance reasons
	ZomboidForge.TLOU_infected.lootchance = {
		TLOU_Runner = SandboxVars.TLOU_infected.CordycepsSpawnRate_Runner,
		TLOU_Stalker = SandboxVars.TLOU_infected.CordycepsSpawnRate_Stalker,
		TLOU_Clicker = SandboxVars.TLOU_infected.CordycepsSpawnRate_Clicker,
		TLOU_Bloater = SandboxVars.TLOU_infected.CordycepsSpawnRate_Bloater,
	}
	ZomboidForge.TLOU_infected.HideIndoorsUpdates = math.floor(SandboxVars.TLOU_infected.HideIndoorsUpdates * 1.2)
	ZomboidForge.TLOU_infected.OnlyUnexplored = SandboxVars.TLOU_infected.OnlyUnexplored
	ZomboidForge.TLOU_infected.WanderAtNight = SandboxVars.TLOU_infected.WanderAtNight
	ZomboidForge.TLOU_infected.MaxDistanceToCheck = SandboxVars.TLOU_infected.MaxDistanceToCheck
	ZomboidForge.TLOU_infected.ExtraFireDamage = SandboxVars.TLOU_infected.ExtraFireDamage

    -- RUNNER
	if SandboxVars.TLOU_infected.RunnerSpawn then
		ZomboidForge.ZTypes.TLOU_Runner = {
			-- base informations
			name = "IGUI_TLOU_Runner",
			chance = SandboxVars.TLOU_infected.RunnerSpawnWeight,

			-- stats
			walktype = 1,
			strength = SandboxVars.TLOU_infected.RunnerStrength,
			toughness = SandboxVars.TLOU_infected.RunnerToughness,
			cognition = 3,
			memory = 2,
			sight = SandboxVars.TLOU_infected.RunnerVision,
			hearing = SandboxVars.TLOU_infected.RunnerHearing,
			HP = SandboxVars.TLOU_infected.RunnerHealth,

			-- UI
			color = {122, 243, 0,},
			outline = {0, 0, 0,},

			-- attack functions
			zombieAgro = {},
			zombieOnHit = {},

			-- custom behavior
			zombieDeath = {},
			customBehavior = {},

			customData = {
				"SetRunnerSounds",
			},
		}
	end

    -- STALKER
	if SandboxVars.TLOU_infected.StalkerSpawn then
		ZomboidForge.ZTypes.TLOU_Stalker = {
			-- base informations
			name = "IGUI_TLOU_Stalker",
			chance = SandboxVars.TLOU_infected.StalkerSpawnWeight,
			beard = {
				"",
			},

			-- stats
			walktype = 1,
			strength = 1,
			toughness = 2,
			cognition = 3,
			memory = 3,
			sight = SandboxVars.TLOU_infected.StalkerVision,
			hearing = SandboxVars.TLOU_infected.StalkerHearing,
			HP = SandboxVars.TLOU_infected.StalkerHealth,

			-- UI
			color = {230, 230, 0,},
			outline = {0, 0, 0,},

			-- attack functions
			zombieAgro = {},
			zombieOnHit = {},

			-- custom behavior
			zombieDeath = {},
			customBehavior = {},

			customData = {
				"SetStalkerSounds",
				"RemoveBandages",
			},
		}
	end

    -- CLICKER
	if SandboxVars.TLOU_infected.ClickerSpawn then
		ZomboidForge.ZTypes.TLOU_Clicker = {
			-- base informations
			name = "IGUI_TLOU_Clicker",
			chance = SandboxVars.TLOU_infected.ClickerSpawnWeight,
			hair = {
				male = {
					"",
				},
				female = {
					"",
				},
			},
			hairColor = {
				ImmutableColor.new(Color.new(0.70, 0.70, 0.70, 1)),
			},
			beard = {
				"",
			},
			animationVariable = "isClicker",

			-- stats
			walktype = 2,
			strength = 1,
			toughness = 1,
			cognition = 3,
			memory = 2,
			sight = 3,
			hearing = SandboxVars.TLOU_infected.ClickerHearing,
			HP = SandboxVars.TLOU_infected.ClickerHealth,

			-- UI
			color = {218, 109, 0,},
			outline = {0, 0, 0,},

			-- attack functions
			zombieAgro = {
				"ClickerAttack",
			},
			zombieOnHit = {
				"ClickerHit",
			},

			-- custom behavior
			zombieDeath = {
				"OnClickerDeath",
			},
			customBehavior = {
				"ClickerAgro",
			},

			customData = {
				"SetClickerClothing",
				"SetClickerSounds",
				"RemoveBandages",
			},
		}
	end

    -- BLOATER
	if SandboxVars.TLOU_infected.BloaterSpawn then
		ZomboidForge.ZTypes.TLOU_Bloater = {
			-- base informations
			name = "IGUI_TLOU_Bloater",
			chance = SandboxVars.TLOU_infected.BloaterSpawnWeight,
			outfit = {
				"Bloater",
			},
			animationVariable = "isBloater",

			-- stats
			walktype = 2,
			strength = 1,
			toughness = 1,
			cognition = 3,
			memory = 2,
			sight = 3,
			hearing = SandboxVars.TLOU_infected.BloaterHearing,
			HP = SandboxVars.TLOU_infected.BloaterHealth,

			-- UI
			color = {205, 0, 0,},
			outline = {0, 0, 0,},

			-- attack functions
			zombieAgro = {
				"BloaterAttack",
			},
			zombieOnHit = {
				"BloaterHit",
			},
			shouldNotStagger = true,

			-- custom behavior
			zombieDeath = {},
			customBehavior = {},

			customData = {
				"SetBloaterSounds",
				"RemoveBandages",
			},
		}
	end

	-- If runners and stalkers are able to vault
	if SandboxVars. TLOU_infected.VaultingInfected then
		ZomboidForge.ZTypes.TLOU_Runner.animationVariable = "isInfected"
		ZomboidForge.ZTypes.TLOU_Stalker.animationVariable = "isInfected"
	end

	-- if infected should hide indoors in daytime
	if SandboxVars.TLOU_infected.HideIndoors then
		if ZomboidForge.ZTypes.TLOU_Stalker and not ZomboidForge.CheckInTable(ZomboidForge.ZTypes.TLOU_Stalker.customBehavior,"StrongBloater") then
			table.insert(ZomboidForge.ZTypes.TLOU_Stalker.customBehavior,
				"HideIndoors"
			)
		end

		if ZomboidForge.ZTypes.TLOU_Clicker and not ZomboidForge.CheckInTable(ZomboidForge.ZTypes.TLOU_Clicker.customBehavior,"StrongBloater") then
			table.insert(ZomboidForge.ZTypes.TLOU_Clicker.customBehavior,
				"HideIndoors"
			)
		end

		if ZomboidForge.ZTypes.TLOU_Bloater and not ZomboidForge.CheckInTable(ZomboidForge.ZTypes.TLOU_Bloater.customBehavior,"StrongBloater") then
			table.insert(ZomboidForge.ZTypes.TLOU_Bloater.customBehavior,
				"HideIndoors"
			)
		end
	end

	-- if Bloaters are allowed to deal more damage to structures
	if SandboxVars.TLOU_infected.StrongBloater then
		if ZomboidForge.ZTypes.TLOU_Bloater and not ZomboidForge.CheckInTable(ZomboidForge.ZTypes.TLOU_Bloater.customBehavior,"StrongBloater") then
			table.insert(ZomboidForge.ZTypes.TLOU_Bloater.customBehavior,
				"StrongBloater"
			)
		end
	end

	-- if Clicker and Bloaters take extra damage from fire but the damage they take is capped
	if SandboxVars. TLOU_infected.ExtraFireDamage_Clicker then
		ZomboidForge.ZTypes.TLOU_Clicker.customDamage = "ExtraFireDamage"
	end

	if SandboxVars. TLOU_infected.ExtraFireDamage_Bloater then
		ZomboidForge.ZTypes.TLOU_Bloater.customDamage = "ExtraFireDamage"
	end

	-- if Cordyceps Spore Zone is installed and sandbox options for cordyceps spawn is on
	if getActivatedMods():contains("BB_SporeZones") and SandboxVars.TLOU_infected.CordycepsSpawn then
		if not ZomboidForge.CheckInTable(ZomboidForge.ZTypes.TLOU_Runner.zombieDeath,"OnInfectedDeath_cordyceps") then
			table.insert(ZomboidForge.ZTypes.TLOU_Runner.zombieDeath,
				"OnInfectedDeath_cordyceps"
			)
		end

		if not ZomboidForge.CheckInTable(ZomboidForge.ZTypes.TLOU_Stalker.zombieDeath,"OnInfectedDeath_cordyceps") then
			table.insert(ZomboidForge.ZTypes.TLOU_Stalker.zombieDeath,
				"OnInfectedDeath_cordyceps"
			)
		end

		if not ZomboidForge.CheckInTable(ZomboidForge.ZTypes.TLOU_Clicker.zombieDeath,"OnInfectedDeath_cordyceps") then
			table.insert(ZomboidForge.ZTypes.TLOU_Clicker.zombieDeath,
				"OnInfectedDeath_cordyceps"
			)
		end

		if not ZomboidForge.CheckInTable(ZomboidForge.ZTypes.TLOU_Bloater.zombieDeath,"OnInfectedDeath_cordyceps") then
			table.insert(ZomboidForge.ZTypes.TLOU_Bloater.zombieDeath,
				"OnInfectedDeath_cordyceps"
			)
		end
	end
end

--#region Attack and Onhit functions

-- clicker attacks a player
function ZomboidForge.ClickerAttack(player,zombie)
	if player and player:isAlive() then
		--clicker grabs player
		if SandboxVars.TLOU_infected.GrabbyClickers and not player:isGodMod() then
			player:setSlowFactor(1)
			player:setSlowTimer(1)
		end

		-- kill player if oneshot clickers
		if SandboxVars.TLOU_infected.OneShotClickers then
			if player:hasHitReaction() and not player:isGodMod() then
				--player:setDeathDragDown(true)
				player:Kill(zombie)
			end
		end
	end
end

-- bloater attacks a player
function ZomboidForge.BloaterAttack(player,zombie)
	if player and player:isAlive() then
		-- bloater grabs player
		if not player:isGodMod() then
			player:setSlowFactor(1)
			player:setSlowTimer(1)
		end

		-- kill player
		if player:hasHitReaction() and not player:isGodMod() then
			player:Kill(zombie)
		end
	end
end

-- player attacked a clicker
function ZomboidForge.ClickerHit(player, zombie, handWeapon, damage)
	if SandboxVars.TLOU_infected.NoPushClickers then
		if handWeapon:getFullType() == "Base.BareHands" then
			zombie:setOnlyJawStab(true)
		end
	elseif zombie:isOnlyJawStab() then
		zombie:setOnlyJawStab(false)
	end
end

-- player attacked a bloater
function ZomboidForge.BloaterHit(player, zombie, handWeapon, damage)
	-- can't be pushed
	if not zombie:isOnlyJawStab() then
		zombie:setOnlyJawStab(true)
	end

	if zombie:getHitTime() ~= 0 then
		zombie:setHitTime(0)
	end
end

-- set damage to bloater from player
function ZomboidForge.ExtraFireDamage(player, zombie, handWeapon, damage)
	-- maximum damage output
	if damage >= 3 then
		damage = 3
	end

	-- if Zombie is on fire, deal more damage even past max damage output
	if zombie:isOnFire() then
		return damage * ZomboidForge.TLOU_infected.ExtraFireDamage
	end

	return damage
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

--- Custom behavior

--#region Custom behavior: `OnDeath loot`

-- Replace fungi hat clothing with fungi hat food type on a `Clicker`'s death.
---@param zombie 		IsoZombie
---@param _		 		string   	--Zombie Type ID
ZomboidForge.OnClickerDeath = function(zombie,_)
	-- add fungi hat food type to inventory
	local inventory = zombie:getInventory()
	inventory:AddItems("Hat_Fungi_Loot",1)
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
	if ZomboidForge.TLOU_infected.lootchance[ZType] >= rand then
		--zombie:getInventory():AddItems("Cordyceps", ZombRand(ZomboidForge.TLOU_infected.lootcount_min[ZType],ZomboidForge.TLOU_infected.lootcount_max[ZType]))
		zombie:getInventory():AddItems("Cordyceps", ZomboidForge.TLOU_infected.roll_lootcount[ZType]())
	end
end
--#endregion

--#region Custom behavior: `RemoveBandages`

-- Remove visual bandages on Zombies who have some, else skip.
---@param zombie 		IsoZombie
---@param _		 		string   	--Zombie Type ID
ZomboidForge.RemoveBandages = function(zombie,_)
	-- Remove bandages
	local bodyVisuals = zombie:getHumanVisual():getBodyVisuals()
	if bodyVisuals and bodyVisuals:size() > 0 then
		zombie:getHumanVisual():getBodyVisuals():clear()
		zombie:resetModel()
	end
end

--#endregion

--#region Custom behavior: `SetInfectedSounds`

-- For debug purposes, allows to check vocals of a zombie.
---@param zombie 		IsoZombie
---@return string
ZomboidForge.VerifyEmitter = function(zombie)
	local stringZ = "Emitters:"
	stringZ = stringZ.."\nMaleA = "..tostring(zombie:getEmitter():isPlaying("Zombie/Voice/MaleA"))
	stringZ = stringZ.."\nFemaleA = "..tostring(zombie:getEmitter():isPlaying("Zombie/Voice/FemaleA"))
	stringZ = stringZ.."\nMaleB = "..tostring(zombie:getEmitter():isPlaying("Zombie/Voice/MaleB"))
	stringZ = stringZ.."\nFemaleB = "..tostring(zombie:getEmitter():isPlaying("Zombie/Voice/FemaleB"))
	stringZ = stringZ.."\nMaleC = "..tostring(zombie:getEmitter():isPlaying("Zombie/Voice/MaleC"))
	stringZ = stringZ.."\nFemaleC = "..tostring(zombie:getEmitter():isPlaying("Zombie/Voice/FemaleC"))
	return stringZ
end

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

-- Set `Stalker` sounds.
---@param zombie 		IsoZombie
---@param _		 		string   	--Zombie Type ID
ZomboidForge.SetStalkerSounds = function(zombie,_)
	if not zombie:getEmitter():isPlaying("Zombie/Voice/MaleB") and not zombie:isFemale()
	or not zombie:getEmitter():isPlaying("Zombie/Voice/FemaleB") and zombie:isFemale() then
		zombie:getEmitter():stopAll()
		if zombie:isFemale() then
			zombie:getEmitter():playVocals("Zombie/Voice/FemaleB")
		else
			zombie:getEmitter():playVocals("Zombie/Voice/MaleB")
		end
	end
end

-- Set `Clicker` sounds.
---@param zombie 		IsoZombie
---@param _		 		string   	--Zombie Type ID
ZomboidForge.SetClickerSounds = function(zombie,_)
	if not zombie:getEmitter():isPlaying("Zombie/Voice/FemaleC")then
		zombie:getEmitter():stopAll()
		zombie:getEmitter():playVocals("Zombie/Voice/FemaleC")
	end
end

-- Set `Bloater` sounds.
---@param zombie 		IsoZombie
---@param _		 		string   	--Zombie Type ID
ZomboidForge.SetBloaterSounds = function(zombie,_)
	if not zombie:getEmitter():isPlaying("Zombie/Voice/MaleC") then
		zombie:getEmitter():stopAll()
		zombie:getEmitter():playVocals("Zombie/Voice/MaleC")
	end
end

--#endregion

--#region Custom behavior: `SetClickerClothing`

-- clothing priority to replace
ZomboidForge.TLOU_infected.ClothingPriority = {
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

-- Set clicker clothing by visually replacing one of its clothing based on the priority list of clothings to replace.
---@param zombie 		IsoZombie
---@param _		 		string   	--Zombie Type ID
ZomboidForge.SetClickerClothing = function(zombie,_)
	-- get clothing visuals from zombie
	local visual = zombie:getItemVisuals()
	if not visual then return end

	-- scroll through every clothing and replace it
	local hasHat_Fungi = false
	if visual:size() > 0 then
		local priority = 100
		local itemReset = nil
		for i = 0, visual:size()-1 do
			local item = visual:get(i)
			if not item then
				break
			end
			local bodyLocation = item:getScriptItem():getBodyLocation()
			local priorityTest = ZomboidForge.TLOU_infected.ClothingPriority[bodyLocation]
			if item:getItemType() == "Base.Hat_Fungi" then
				hasHat_Fungi = true
				break
			elseif priorityTest and priorityTest < priority then
				-- if not, then add one to the item
				priority = priorityTest
				itemReset = item
				hasHat_Fungi = false
			end
		end
		if not hasHat_Fungi and itemReset then
			itemReset:setItemType("Base.Hat_Fungi")
			itemReset:setClothingItemName("Hat_Fungi")
			zombie:resetModel()
		end

	-- if no visuals were found then add a visual item which is the Hat Fungi
	else
		local itemVisual = ItemVisual.new()
		itemVisual:setItemType("Base.Hat_Fungi")
		itemVisual:setClothingItemName("Hat_Fungi")
		visual:add(itemVisual)

		zombie:resetModel()
	end
end

--#endregion

--#region Custom behavior: `HideIndoors`

-- Main function to handle `Zombie` behavior to go hide inside the closest building or wander during night.
---@param zombie 		IsoZombie
---@param _		 		string   	--Zombie Type ID
ZomboidForge.HideIndoors = function(zombie,_)
	-- if zombie is already in building, completely skip
	-- elseif has target
	-- elseif hasn't been at least N seconds since last update 
	if zombie:getBuilding() or zombie:getTarget() or math.floor(zombie.TimeSinceSeenFlesh / 100)%(ZomboidForge.TLOU_infected.HideIndoorsUpdates) ~= 0 then
		return
	end

	-- lure zombie either to a building or make it wander if it's daytime
	ZomboidForge.TLOU_infected.LureZombie(zombie)
end

-- Lure `Zombie` to the building during daytime or make it wander around during night time.
---@param zombie 		IsoZombie
ZomboidForge.TLOU_infected.LureZombie = function(zombie)
    if TLOU_ModData.IsDay or not ZomboidForge.TLOU_infected.WanderAtNight then
		local sourcesq = zombie:getCurrentSquare()
		local squareMoveTo = ZomboidForge.TLOU_infected.GetClosestBuilding(sourcesq)
		if not squareMoveTo then return end
		zombie:pathToSound(squareMoveTo:getX(), squareMoveTo:getY() ,squareMoveTo:getZ())
    else
		local maxDistance = ZomboidForge.TLOU_infected.MaxDistanceToCheck
		local x = zombie:getX() + ZombRand(10,maxDistance) * ZomboidForge.TLOU_infected.CoinFlip()
		local y = zombie:getY() + ZombRand(10,maxDistance) * ZomboidForge.TLOU_infected.CoinFlip()
        zombie:pathToSound(x, y ,0)
    end
end

-- Retrieves the ID of a chunk, from it's coordinates `wx` and `wy`
---@param chunk IsoChunk
---@return string chunkID
ZomboidForge.TLOU_infected.GetChunkID = function(chunk)
	return tostring(chunk.wx).."x"..tostring(chunk.wy)
end

-- Coin flips either `1` or `-1`
---@return integer coinFlip
ZomboidForge.TLOU_infected.CoinFlip = function()
    local randomNumber = ZombRand(2)

    if randomNumber == 0 then
        return -1
    else
        return 1
    end
end

-- Lists to allow easier writing of the code checking buildings
ZomboidForge.TLOU_infected.ChunkCheck = {}
ZomboidForge.TLOU_infected.ChunkCheck.FirstCheck = {
	{1,0},
	{-1,0},
	{0,1},
	{0,-1},
	{1,1},
	{1,-1},
	{-1,1},
	{-1,-1},
}
ZomboidForge.TLOU_infected.ChunkCheck.SecondCheck = {
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
ZomboidForge.TLOU_infected.GetClosestBuilding = function(sourcesq)
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
	local chunkID_origin = ZomboidForge.TLOU_infected.GetChunkID(chunk_origin)
	local wx_origin = chunk_origin.wx
	local wy_origin = chunk_origin.wy

	-- data to retrieve chunkID by calculating wx and wy positions
	local wx = nil
	local wy = nil
	local chunkID = nil

	-- check if building is in central chunk then stops everything there if detected
	closestDist, closestSquare = ZomboidForge.TLOU_infected.CheckBuildingDistance(chunkID_origin,closestDist,closestSquare,x_sourcesq,y_sourcesq)
	if closestSquare then return closestSquare end

	-- iterates through max distance
	local maxChunk = ZomboidForge.TLOU_infected.MaxDistanceToCheck/10
	for i = 1,maxChunk do
		-- check main lines x and y chunks
		for _,j in ipairs(ZomboidForge.TLOU_infected.ChunkCheck.FirstCheck) do
			wx = wx_origin + i * j[1]
			wy = wy_origin + i * j[2]
			chunkID = tostring(wx).."x"..tostring(wy)
			closestDist, closestSquare = ZomboidForge.TLOU_infected.CheckBuildingDistance(chunkID,closestDist,closestSquare,x_sourcesq,y_sourcesq)
		end
		-- check side chunks
		for _,j in ipairs(ZomboidForge.TLOU_infected.ChunkCheck.SecondCheck) do
			for k = 1,i do
				wx = wx_origin + j[1] * k
				wy = wy_origin + j[2] * i
				chunkID = tostring(wx).."x"..tostring(wy)
				closestDist, closestSquare = ZomboidForge.TLOU_infected.CheckBuildingDistance(chunkID,closestDist,closestSquare,x_sourcesq,y_sourcesq)

				wx = wx_origin + j[1] * i
				wy = wy_origin + j[2] * k
				chunkID = tostring(wx).."x"..tostring(wy)
				closestDist, closestSquare = ZomboidForge.TLOU_infected.CheckBuildingDistance(chunkID,closestDist,closestSquare,x_sourcesq,y_sourcesq)
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
ZomboidForge.TLOU_infected.CheckBuildingDistance = function(chunkID,closestDist,closestSquare,x_sourcesq,y_sourcesq)
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
						(not ZomboidForge.TLOU_infected.OnlyUnexplored or not building:isAllExplored())
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
ZomboidForge.TLOU_infected.IsDay = function()
	-- update IsDay check
	TLOU_ModData.IsDay = season2daytime[ month2season(gametime:getMonth()) ]( math.floor(gametime:getTimeOfDay()) )
end

-- Adds detected buildings to the list of available buildings in a chunk.
ZomboidForge.TLOU_infected.AddBuildingList = function(square)
	-- get moddata and check if BuildingList exists, else initialize it
	TLOU_ModData.BuildingList = TLOU_ModData.BuildingList or {}

	-- check if square is in building
	local building = square:getBuilding()
	if not building then return end

	-- get building ID via it's KeyID which is persistent
	local buildingID = building:getDef():getKeyId()

	-- get chunk ID
	local chunk = square:getChunk()
	local chunkID = ZomboidForge.TLOU_infected.GetChunkID(chunk)

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

--#region Custom behavior: `DoorOneShot`

-- Manage Bloater strength against structures by making them extra strong.
---@param zombie 		IsoZombie
---@param ZType 		string   	     --Zombie Type ID
ZomboidForge.StrongBloater = function(zombie,ZType)
	-- run code if infected has thumping target
	local thumped = zombie:getThumpTarget()
	if not thumped then return end

	-- get zombie info
	local trueID = ZomboidForge.pID(zombie)
	TLOU_ModData.Infected = TLOU_ModData.Infected or {}
	TLOU_ModData.Infected[trueID] = TLOU_ModData.Infected[trueID] or {}

	-- update thumped only if infected is thumping
	-- getThumpTarget outputs the target as long as the zombie is in thumping animation
	-- but we want to make sure we damage only if a hit is sent
	local thumpCheck = TLOU_ModData.Infected[trueID].thumpCheck
	if thumpCheck == zombie:getTimeThumping() then
		return
	elseif zombie:getTimeThumping() == 0 then
		return
	end
	TLOU_ModData.Infected[trueID].thumpCheck = zombie:getTimeThumping()

	-- check barricades and damage those first if present
	local barricade = nil
	if thumped:isBarricaded() then
		---@cast thumped BarricadeAble

		-- loop to damage multiple times, it's set so Bloater remove one plank per hit approximatively
		for _ = 1,200 do
			-- need to verify the barricade is not destroyed everytime it's thumped
			barricade = thumped:getBarricadeForCharacter(zombie)
			if not barricade then
				barricade = thumped:getBarricadeOppositeCharacter(zombie)
				if not barricade then break end
			end
			barricade:Thump(zombie)
		end

	-- damage structure getting thumped if no barricades
	else
		local health = nil
		-- need to make a difference between each classes
		-- IsoThumpable is player built
		if instanceof(thumped,"IsoThumpable") then
			---@cast thumped IsoThumpable

			health = thumped:getHealth()
			if thumped:isDoor() then
				thumped:setHealth(health-200)
			elseif thumped:isWindow() then
				thumped:destroy()
			else
				thumped:setHealth(health-100)
			end

		-- IsoDoor is map structure
		elseif instanceof(thumped,"IsoDoor") then
			---@cast thumped IsoDoor

			health = thumped:getHealth()
			thumped:setHealth(health-100)

		-- IsoWindow is map structure
		elseif instanceof(thumped,"IsoWindow") then
			---@cast thumped IsoWindow

			thumped:smashWindow()
		end
	end
end
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
		if isClient() then
			--sendClientCommand('AnimationHandler', 'SetAnimationVariable', {animationVariable = "ClickerAgro", zombie = zombie:getOnlineID(), state = true})
		end
	elseif not target and zombie:getVariableBoolean("ClickerAgro") then
		zombie:setVariable("ClickerAgro",'false')
		if isClient() then
			--sendClientCommand('AnimationHandler', 'SetAnimationVariable', {animationVariable = "ClickerAgro", zombie = zombie:getOnlineID(), state = false})
		end
	end
end
--#endregion
