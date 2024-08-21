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


--- import module from ZomboidForge
local ZomboidForge = require "ZomboidForge_module"
require "ZomboidForge"
require "ZomboidForge_tools"


-- localy initialize mod data
local TLOU_ModData = ModData.getOrCreate("TLOU_Infected")
local function initTLOU_ModData()
	TLOU_ModData = ModData.getOrCreate("TLOU_Infected")
end
Events.OnInitGlobalModData.Remove(initTLOU_ModData)
Events.OnInitGlobalModData.Add(initTLOU_ModData)

--- setup local functions
TLOU_infected = {
	Commands = {
		Behavior = {},
	},
}

-- Sandbox options imported localy for performance reasons
-- used here for file reloads in-game
TLOU_infected.HideIndoorsUpdates 	=		math.floor(SandboxVars.TLOU_infected.HideIndoorsUpdates * 1.2)
TLOU_infected.OnlyUnexplored 		=		SandboxVars.TLOU_infected.OnlyUnexplored
TLOU_infected.WanderAtNight 		=		SandboxVars.TLOU_infected.WanderAtNight
TLOU_infected.MaxDistanceToCheck 	=		SandboxVars.TLOU_infected.MaxDistanceToCheck

--- Create zombie types
TLOU_infected.Initialize_TLOUInfected = function()
	-- Sandbox options imported localy for performance reasons
	TLOU_infected.HideIndoorsUpdates 	=		math.floor(SandboxVars.TLOU_infected.HideIndoorsUpdates * 1.2)
	TLOU_infected.OnlyUnexplored 		=		SandboxVars.TLOU_infected.OnlyUnexplored
	TLOU_infected.WanderAtNight 		=		SandboxVars.TLOU_infected.WanderAtNight
	TLOU_infected.MaxDistanceToCheck 	=		SandboxVars.TLOU_infected.MaxDistanceToCheck

    -- RUNNER
	if SandboxVars.TLOU_infected.RunnerSpawn then
		ZomboidForge.ZTypes.TLOU_Runner = {
			-- base informations
			name 					=		getText("IGUI_TLOU_Runner"),
			chance 					=		SandboxVars.TLOU_infected.RunnerSpawnWeight,
			customEmitter = {
				male 				=		"Zombie/Voice/MaleA",
				female 				=		"Zombie/Voice/FemaleA",
			},

			-- stats
			walktype 				=		SandboxVars.TLOU_infected.RunnerSpeed,
			strength 				=		SandboxVars.TLOU_infected.RunnerStrength,
			toughness 				=		SandboxVars.TLOU_infected.RunnerToughness,
			cognition 				=		2,
			memory 					=		2,
			sight 					=		SandboxVars.TLOU_infected.RunnerVision,
			hearing 				=		SandboxVars.TLOU_infected.RunnerHearing,
			HP 						=		SandboxVars.TLOU_infected.RunnerHealth,
			fireKillRate			=		0.0038*SandboxVars.TLOU_infected.RunnerBurnRate,

			-- UI
			color 					=		{122, 243, 0,},
			outline 				=		{0, 0, 0,},

			-- attack functions

			-- custom behavior

			-- custom data for TLOU_infected
			lootchance 				=		SandboxVars.TLOU_infected.CordycepsSpawnRate_Runner,
			roll_lootcount 			=		function() return ZombRand(1,3) end,
		}
	else
		ZomboidForge.ZTypes.TLOU_Runner = nil
	end

    -- STALKER
	if SandboxVars.TLOU_infected.StalkerSpawn then
		ZomboidForge.ZTypes.TLOU_Stalker = {
			-- base informations
			name 					= 		getText("IGUI_TLOU_Stalker"),
			chance 					= 		SandboxVars.TLOU_infected.StalkerSpawnWeight,
			hairColor = {
				ImmutableColor.new(Color.new(0.70, 0.70, 0.70, 1)),
			},
			beard = {
				"",
			},
			beardColor = {
				ImmutableColor.new(Color.new(0.70, 0.70, 0.70, 1)),
			},
			customEmitter = {
				male 				= 		"Zombie/Voice/MaleB",
				female 				= 		"Zombie/Voice/FemaleB",
			},
			clothingVisuals = {
				dirty = 0.5,
				bloody = 0.5,
				holes = true,
			},
			removeBandages 			= 		true,

			-- stats
			walktype 				=		SandboxVars.TLOU_infected.StalkerSpeed,
			strength 				=		1,
			toughness 				=		2,
			cognition 				=		2,
			memory 					=		3,
			sight 					=		SandboxVars.TLOU_infected.StalkerVision,
			hearing 				=		SandboxVars.TLOU_infected.StalkerHearing,
			HP 						=		SandboxVars.TLOU_infected.StalkerHealth,
			fireKillRate			=		0.0038*SandboxVars.TLOU_infected.StalkerBurnRate,

			-- UI
			color 					= 		{230, 230, 0,},
			outline 				= 		{0, 0, 0,},

			-- attack functions

			-- custom behavior

			-- custom data for TLOU_infected
			lootchance 				= 		SandboxVars.TLOU_infected.CordycepsSpawnRate_Stalker,
			roll_lootcount 			= 		function() return ZombRand(1,5) end,
		}
	else
		ZomboidForge.ZTypes.TLOU_Stalker = nil
	end

    -- CLICKER
	if SandboxVars.TLOU_infected.ClickerSpawn then
		ZomboidForge.ZTypes.TLOU_Clicker = {
			-- base informations
			name 					= 		getText("IGUI_TLOU_Clicker"),
			chance 					= 		SandboxVars.TLOU_infected.ClickerSpawnWeight,
			hair = {
				male = {
					"",
				},
				female = {
					"",
				},
			},
			beard = {
				"",
			},
			animationVariable 		= 		"isClicker",
			customEmitter 			= 		"Zombie/Voice/FemaleC",
			clothingVisuals = {
				set = {
					["UnderwearBottom"] 	= 		{
						"TLOU.ClickerBody_01",
						"TLOU.ClickerBody_02",
						"TLOU.ClickerBody_03",
						"TLOU.ClickerBody_04",
					},
				},
				dirty = true,
				bloody = true,
				holes = true,
				remove = {
					["Hat"]			=		true,
					["Mask"] 		= 		true,
					["Eyes"] 		= 		true,
					["LeftEye"] 	= 		true,
					["RightEye"] 	= 		true,
					["Nose"] 		= 		true,
					["Ears"] 		= 		true,
					["EarTop"] 		= 		true,
					["Scarf"] 		= 		true,
					["Socks"]		=		true,
					["Shoes"]		=		true,
				},
			},
			removeBandages 			= 		true,

			-- stats
			walktype 				= 		2,
			strength 				= 		1,
			toughness 				= 		1,
			cognition 				= 		2,
			memory 					= 		2,
			sight 					= 		3,
			hearing 				= 		SandboxVars.TLOU_infected.ClickerHearing,
			HP 						= 		SandboxVars.TLOU_infected.ClickerHealth,
			fireKillRate			=		0.0038*SandboxVars.TLOU_infected.ClickerBurnRate,

			-- UI
			color 					=		{218, 109, 0,},
			outline 				=		{0, 0, 0,},

			-- attack functions
			-- zombieAgroCharacter = {},
			-- onHit_zombieAttacking = {},
			-- onHit_zombie2player = {},
			-- onHit_player2zombie = {},

			-- custom behavior
			zombieDeath = {
				"OnClickerDeath",
			},
			customBehavior = {
				"ClickerAgro",
			},

			-- custom data for TLOU_infected
			lootchance 				=		SandboxVars.TLOU_infected.CordycepsSpawnRate_Clicker,
			roll_lootcount 			=		function() return ZombRand(3,8) end,
			fireDamageMultiplier 	=		SandboxVars.TLOU_infected.ExtraFireDamage,
			damageLimiter			=		SandboxVars.TLOU_infected.DamageLimiterClicker
		}
	else
		ZomboidForge.ZTypes.TLOU_Clicker = nil
	end

    -- BLOATER
	if SandboxVars.TLOU_infected.BloaterSpawn then
		ZomboidForge.ZTypes.TLOU_Bloater = {
			-- base informations
			name 					=		getText("IGUI_TLOU_Bloater"),
			chance 					=		SandboxVars.TLOU_infected.BloaterSpawnWeight,
			-- outfit = {
			-- 	female = {
			-- 		Weighted = {
			-- 			{
			-- 				name = "Bloater",
			-- 				weight = 100,
			-- 			},
			-- 			{
			-- 				name = "AirCrew",
			-- 				weight = 500,
			-- 			},
			-- 			{
			-- 				name = "Bandit",
			-- 				weight = 300,
			-- 			},
			-- 		},
			-- 	},
			-- 	male = {
			-- 		"Bloater",
			-- 	},
			-- },
			outfit = "Bloater",
			animationVariable 		= 		"isBloater",
			customEmitter 			=		"Zombie/Voice/MaleC",
			removeBandages 			=		true,

			-- stats
			walktype 				=		2,
			strength 				=		1,
			toughness 				=		1,
			cognition 				=		2,
			memory 					=		2,
			sight 					=		3,
			hearing 				=		SandboxVars.TLOU_infected.BloaterHearing,
			HP 						=		SandboxVars.TLOU_infected.BloaterHealth,
			fireKillRate			=		0.0038*SandboxVars.TLOU_infected.BloaterBurnRate,

			-- UI
			color 					=		{205, 0, 0,},
			outline 				=		{0, 0, 0,},

			-- attack functions
			-- zombieAgroCharacter = {},
			onHit_zombieAttacking = {
				"GrabbyInfected",
			},
			onHit_zombie2player = {
				"KillTarget",
			},
			shouldIgnoreStagger 	=		true,
			resetHitTime 			=		true,
			onlyJawStab 			=		true,
			jawStabImmune			=		true,

			-- custom data for TLOU_infected
			lootchance 				=		SandboxVars.TLOU_infected.CordycepsSpawnRate_Bloater,
			roll_lootcount 			=		function() return ZombRand(5,15) end,
			fireDamageMultiplier 	=		SandboxVars.TLOU_infected.ExtraFireDamage,
			damageLimiter			=		SandboxVars.TLOU_infected.DamageLimiterBloater
		}
	else
		ZomboidForge.ZTypes.TLOU_Bloater = nil
	end

	-- add sandbox option based functions
	local runner = ZomboidForge.ZTypes.TLOU_Runner
	local stalker = ZomboidForge.ZTypes.TLOU_Stalker
	local clicker = ZomboidForge.ZTypes.TLOU_Clicker
	local bloater = ZomboidForge.ZTypes.TLOU_Bloater

	-- If runners and stalkers are able to vault
	if SandboxVars.TLOU_infected.VaultingInfected then
		if runner then
			runner.animationVariable = "isInfected"
		end

		if stalker then
			stalker.animationVariable = "isInfected"
		end
	end

	-- if infected should hide indoors in daytime
	if SandboxVars.TLOU_infected.HideIndoors then
		if stalker then
			stalker.customBehavior = stalker.customBehavior or {}
			table.insert(stalker.customBehavior,
				"HideIndoors"
			)
		end

		if clicker then
			clicker.customBehavior = clicker.customBehavior or {}
			table.insert(clicker.customBehavior,
				"HideIndoors"
			)
		end

		if bloater then
			bloater.customBehavior = bloater.customBehavior or {}
			table.insert(bloater.customBehavior,
				"HideIndoors"
			)
		end
	end

	-- if Bloaters are allowed to deal more damage to structures
	if SandboxVars.TLOU_infected.StrongBloater and bloater then
		bloater.onThump = bloater.onThump or {}
		table.insert(bloater.onThump,
			"StrongBloater"
		)
	end

	-- if Clicker and Bloaters take extra damage from fire but the damage they take is capped
	if SandboxVars.TLOU_infected.ExtraFireDamage_Clicker and clicker then
		clicker.customDamage = "ExtraFireDamage"
	end

	if SandboxVars.TLOU_infected.ExtraFireDamage_Bloater and bloater then
		bloater.customDamage = "ExtraFireDamage"
	end

	-- if Clicker can't be pushed
	if SandboxVars.TLOU_infected.NoPushClickers then
		if clicker then
			clicker.onlyJawStab = "NoPush"
			clicker.shouldIgnoreStagger = "NoPush"
		end
	end

	if SandboxVars.TLOU_infected.GrabbyClickers then
		if clicker then
			clicker.onHit_zombieAttacking = clicker.onHit_zombieAttacking or {}
			table.insert(clicker.onHit_zombieAttacking,
				"GrabbyInfected"
			)
		end
	end

	-- One shot Clickers
	if SandboxVars.TLOU_infected.OneShotClickers then
		if clicker then
			clicker.onHit_zombie2player = clicker.onHit_zombie2player or {}
			table.insert(clicker.onHit_zombie2player,
				"KillTarget"
			)
		end
	end

	-- blind Clickers
	if isDebugEnabled() and clicker and false then
		clicker.customBehavior = clicker.customBehavior or {}
		table.insert(clicker.customBehavior,
			"ClickerBehavior"
		)
	end

	if isDebugEnabled() and stalker and false then
		stalker.customBehavior = stalker.customBehavior or {}
		table.insert(stalker.customBehavior,
			"StalkerBehavior"
		)
	end

	-- if Cordyceps Spore Zone is installed and sandbox options for cordyceps spawn is on
	if getActivatedMods():contains("BB_SporeZones") and SandboxVars.TLOU_infected.CordycepsSpawn then
		if runner then
			runner.zombieDeath = runner.zombieDeath or {}
			table.insert(runner.zombieDeath,
				"OnInfectedDeath_cordyceps"
			)
		end

		if stalker then
			stalker.zombieDeath = stalker.zombieDeath or {}
			table.insert(stalker.zombieDeath,
				"OnInfectedDeath_cordyceps"
			)
		end

		if clicker then
			clicker.zombieDeath = clicker.zombieDeath or {}
			table.insert(clicker.zombieDeath,
				"OnInfectedDeath_cordyceps"
			)
		end

		if bloater then
			bloater.zombieDeath = bloater.zombieDeath or {}
			table.insert(bloater.zombieDeath,
				"OnInfectedDeath_cordyceps"
			)
		end
	end
end

return TLOU_infected