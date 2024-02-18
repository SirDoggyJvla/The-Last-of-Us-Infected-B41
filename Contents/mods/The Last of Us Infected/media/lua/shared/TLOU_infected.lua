
--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the core of the mod of The Last of Us Infected Fork

]]--
--[[ ================================================ ]]--

--- Import functions localy for performances reasons
local table = table -- Lua's table module
local ipairs = ipairs -- ipair function
local ZombRand = ZombRand -- java random function
local print = print -- print function

--- import module from ZomboidForge
local ZomboidForge = require "ZomboidForge"

--- setup local functions
local TLOU_infected = {}

--- Create zombie types
ZomboidForge.InitTLOUInfected = function()
	TLOU_infected.lootchance = {
		runner = SandboxVars.TLOU_Overhaul.CordycepsSpawnRate_Runner,
		stalker = SandboxVars.TLOU_Overhaul.CordycepsSpawnRate_Stalker,
		clicker = SandboxVars.TLOU_Overhaul.CordycepsSpawnRate_Clicker,
		bloater = SandboxVars.TLOU_Overhaul.CordycepsSpawnRate_Bloater,
	}

    -- RUNNER
    table.insert(ZomboidForge.ZTypes,
        {
            -- base informations
            spawn = true,
            name = "IGUI_TLOU_Runner",
            chance = SandboxVars.TLOUZombies.Runner,
			outfit = {},
			reanimatedPlayer = false,
			skeleton = false,
			hair = false, -- input string
			beard = false, -- input string

            -- stats
			walktype = 1,
			strength = 2,
			toughness = 2,
			cognition = 3,
			memory = 2,
			sight = SandboxVars.TLOUZombies.RunnerVision,
			hearing = SandboxVars.TLOUZombies.RunnerHearing,
			HP = 1,

			noteeth = false,
			transmission = false, -- probably requires a number

            -- custom variables
			isRunner = true,

            -- UI
			color = {122, 243, 0,},
			outline = {0, 0, 0,},

            -- attack functions
			funcattack = {},
			funconhit = {},

            -- custom behavior
			onDeath = {
				"OnInfectedDeath",
			},
            customBehavior = {
				"SetRunnerSounds",
			},
        }
    )

    -- STALKER
    table.insert(ZomboidForge.ZTypes,
        {
            -- base informations
            spawn = true,
            name = "IGUI_TLOU_Stalker",
            chance = SandboxVars.TLOUZombies.Stalker,
			outfit = {},
			reanimatedPlayer = false,
			skeleton = false,
			hair = false, -- input string
			beard = false, -- input string

            -- stats
			walktype = 1,
			strength = 1,
			toughness = 2,
			cognition = 3,
			memory = 4,
			sight = SandboxVars.TLOUZombies.StalkerVision,
			hearing = SandboxVars.TLOUZombies.StalkerHearing,
			HP = 1,

			noteeth = false,
			transmission = false, -- probably requires a number

            -- custom variables
			isStalker = true,

            -- UI
			color = {230, 230, 0,},
			outline = {0, 0, 0,},

            -- attack functions
			funcattack = {},
			funconhit = {},

            -- custom behavior
			onDeath = {
				"OnInfectedDeath",
			},
            customBehavior = {
				"SetStalkerSounds",
			},
        }
    )

    -- CLICKER
    table.insert(ZomboidForge.ZTypes,
        {
            -- base informations
            spawn = true,
            name = "IGUI_TLOU_Clicker",
            chance = SandboxVars.TLOUZombies.Clicker,
			outfit = {},
			reanimatedPlayer = false,
			skeleton = false,
			hair = false, -- input string
			beard = false, -- input string

            -- stats
			walktype = 2,
			strength = 1,
			toughness = 1,
			cognition = 3,
			memory = 2,
			sight = 3,
			hearing = SandboxVars.TLOUZombies.ClickerHearing,
			HP = SandboxVars.TLOUZombies.ClickerHealth,

			noteeth = false,
			transmission = false, -- probably requires a number

            -- custom variables
			isClicker = true,

            -- UI
			color = {218, 109, 0,},
			outline = {0, 0, 0,},

            -- attack functions
			funcattack = {"ClickerAttack"},
			funconhit = {"ClickerHit"},

            -- custom behavior
			onDeath = {
				"OnClickerDeath",
				"OnInfectedDeath",
			},
            customBehavior = {
				"SetClickerClothing",
				"SetClickerSounds",
			},
        }
    )

    -- BLOATER
    table.insert(ZomboidForge.ZTypes,
        {
            -- base informations
            spawn = true,
            name = "IGUI_TLOU_Bloater",
            chance = SandboxVars.TLOUZombies.Bloater,
			outfit = {"Bloater"},
			reanimatedPlayer = false,
			skeleton = false,
			hair = false, -- input string
			beard = false, -- input string

            -- stats
			walktype = 2,
			strength = 1,
			toughness = 1,
			cognition = 3,
			memory = 2,
			sight = 3,
			hearing = SandboxVars.TLOUZombies.BloaterHearing,
			HP = SandboxVars.TLOUZombies.BloaterHealth,

			noteeth = false,
			transmission = false, -- probably requires a numbers

            -- custom variables
			isBloater = true,

            -- UI
			color = {205, 0, 0,},
			outline = {0, 0, 0,},

            -- attack functions
			funcattack = {"BloaterAttack"},
			funconhit = {"BloaterHit"},

            -- custom behavior
			onDeath = {
				"OnInfectedDeath",
			},
            customBehavior = {
				"SetBloaterSounds",
			},
        }
    )
end

--- Attack functions

-- clicker attacks a player
function ZomboidForge.ClickerAttack(player,zombie)
	if player and player:isAlive() then
		if SandboxVars.TLOUZombies.OneShotClickers then 
			if player:hasHitReaction() and not player:isGodMod() then
				--player:setDeathDragDown(true)
				player:Kill(zombie)
			end
		end
		--clicker grabs player
		if SandboxVars.TLOUZombies.GrabbyClickers and not player:isGodMod() then
			player:setSlowFactor(1)
			player:setSlowTimer(1)
		end
	end
end

-- bloater attacks a player
function ZomboidForge.BloaterAttack(player,zombie)
	if player and player:isAlive() then
		--bloater grabs player
		player:setSlowFactor(1)
		player:setSlowTimer(1)	
		if player:hasHitReaction() and not player:isGodMod() then
			--player:setDeathDragDown(true)
			player:Kill(zombie)
		end
	end
end


-- player attacked a clicker
function ZomboidForge.ClickerHit(player, zombie, HandWeapon, damage)

	if SandboxVars.TLOUZombies.NoPushClickers then
		if HandWeapon:getDisplayName() == "Bare Hands" then
			zombie:setOnlyJawStab(true)
		else
			zombie:setOnlyJawStab(false)
		end
	end
end

-- player attacked a bloater
function ZomboidForge.BloaterHit(player, zombie, HandWeapon, damage)

	zombie:setOnlyJawStab(true)

	if zombie:isOnFire() then
		zombie:setHealth(zombie:getHealth() - (damage * 3))
	else
		zombie:setHealth(zombie:getHealth() - damage)
	end

	if zombie:getHealth() <= 0 and not player:isGodMod() then 
		zombie:setOnlyJawStab(false)
		zombie:Kill(player)
	end

	zombie:setHitTime(0)
end


Events.OnGameStart.Add(ZomboidForge.InitTLOUInfected)
--Events.OnGameBoot.Add(ZomboidForge.InitTLOUInfected)

--- Custom behavior

-- onDeath of a clicker
ZomboidForge.OnClickerDeath = function(zombie,ZType)
	-- add fungi hat food type to inventory
	local inventory = zombie:getInventory()
	inventory:AddItems("Hat_Fungi_Loot",1)
end

-- add cordyceps mushrooms
ZomboidForge.OnInfectedDeath = function(zombie,ZType)
	-- add fungi hat food type to inventory
	local inventory = zombie:getInventory()
	local ZombieTable = ZomboidForge.ZTypes[ZType]

	-- roll to inventory
	local rand = ZombRand(1,100)
	local lootchance = TLOU_infected.lootchance
	if ZombieTable.isRunner and lootchance.runner >= rand then
		inventory:AddItems("Cordyceps", ZombRand(1,3))
	elseif ZombieTable.isStalker and lootchance.stalker >= rand then
		inventory:AddItems("Cordyceps", ZombRand(1,5))
	elseif ZombieTable.isClicker and lootchance.clicker >= rand then
		inventory:AddItems("Cordyceps", ZombRand(3,10))
	elseif ZombieTable.isBloater and lootchance.bloater >= rand then
		inventory:AddItems("Cordyceps", ZombRand(5,15))
	end
end

-- set runner sounds
ZomboidForge.SetRunnerSounds = function(zombie,ZType)
	if zombie:getAge() == -1 then
		if zombie:getEmitter():isPlaying("MaleZombieCombined") or zombie:getEmitter():isPlaying("FemaleZombieCombined") then
			zombie:setAge(-2)
			if zombie:isFemale() then
				zombie:getEmitter():playVocals("Zombie/Voice/FemaleA")
			else 
				zombie:getEmitter():playVocals("Zombie/Voice/MaleA")
			end
			zombie:makeInactive(true);
			zombie:makeInactive(false);
		end
	end
end

-- set stalker sounds
ZomboidForge.SetStalkerSounds = function(zombie,ZType)
	if zombie:getAge() == -1 then
		if zombie:getEmitter():isPlaying("MaleZombieCombined") or zombie:getEmitter():isPlaying("FemaleZombieCombined") then
			zombie:setAge(-2)
			if zombie:isFemale() then
				zombie:getEmitter():playVocals("Zombie/Voice/FemaleB")
			else
				zombie:getEmitter():playVocals("Zombie/Voice/MaleB")
			end
			zombie:makeInactive(true);
			zombie:makeInactive(false);
		end
	end
end
-- set clicker sounds
ZomboidForge.SetClickerSounds = function(zombie,ZType)
	print("setting clicker sounds")
	if zombie:getAge() == -1 then
		if zombie:getEmitter():isPlaying("MaleZombieCombined") or zombie:getEmitter():isPlaying("FemaleZombieCombined") then
			zombie:setAge(-2)
			zombie:getEmitter():playVocals("Zombie/Voice/FemaleC")
			zombie:makeInactive(true);
			zombie:makeInactive(false);
		end
	end
end
-- set bloater sounds
ZomboidForge.SetBloaterSounds = function(zombie,ZType)
	print("setting bloater sounds")
	if zombie:getAge() == -1 then
		if zombie:getEmitter():isPlaying("MaleZombieCombined") or zombie:getEmitter():isPlaying("FemaleZombieCombined") then
			zombie:setAge(-2)
			zombie:getEmitter():playVocals("Zombie/Voice/MaleC")
			zombie:makeInactive(true);
			zombie:makeInactive(false);
		end
	end
end

-- clothing priority to replace
local clothingPriority = {
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

-- set clicker clothing by visually replacing one of its clothing
function ZomboidForge.SetClickerClothing(zombie,ZType)
	--if not zombie:getModData()['ClickerClothing'] then
		-- get zombie visual clothing
		local visual = zombie:getItemVisuals()
		-- scroll through every clothing and replace it
		if visual:size() > 0 then
			local hasHat_Fungi = false
			local priority = 100
			local itemReset = nil
			for i = 1, visual:size()-1 do
				local item = visual:get(i)
				if not item then
					break
				end
				local bodyLocation = item:getScriptItem():getBodyLocation()
				local priorityTest = clothingPriority[bodyLocation]
				if item:getItemType() == "Base.Hat_Fungi" then
					hasHat_Fungi = true
					break
				elseif priorityTest and priorityTest < priority then
					-- if not, then add one to the item
					priority = priorityTest
					itemReset = item
				end
			end
			if not hasHat_Fungi and itemReset then
				itemReset:setItemType("Base.Hat_Fungi")
				zombie:resetModel()
			end
		end
		zombie:getModData()['ClickerClothing'] = true
	--end
end