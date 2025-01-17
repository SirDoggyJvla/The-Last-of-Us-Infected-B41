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
local ZombRand = ZombRand -- java function


--- import module from ZomboidForge
local ZomboidForge = require "ZomboidForge_module"
local TLOU_infected = require "TLOU_infected_module"

--- Create zombie types
TLOU_infected.Initialize_TLOUInfected = function(ZTypes)
	-- Sandbox options imported localy for performance reasons
	TLOU_infected.HideIndoorsUpdates 		=		math.floor(SandboxVars.TLOU_infected.HideIndoorsUpdates * 1.2)
	TLOU_infected.OnlyUnexplored 			=		SandboxVars.TLOU_infected.OnlyUnexplored
	TLOU_infected.WanderAtNight 			=		SandboxVars.TLOU_infected.WanderAtNight
	TLOU_infected.MaxDistanceToCheck 		=		SandboxVars.TLOU_infected.MaxDistanceToCheck
	TLOU_infected.AllowWeaponPush			=		SandboxVars.TLOU_infected.AllowWeaponPush
	TLOU_infected.NoStompClickers			=		SandboxVars.TLOU_infected.NoStompClickers
	TLOU_infected.StandOnInfected_Stagger	=		SandboxVars.TLOU_infected.StandOnInfected_Stagger

	-- retrieve infection time
	TLOU_infected.areaInfectionTime = {
		top = {
			min = SandboxVars.TLOU_infected.CustomInfectionSystemTopMin,
			max = SandboxVars.TLOU_infected.CustomInfectionSystemTopMax,
		},
		middle = {
			min = SandboxVars.TLOU_infected.CustomInfectionSystemMiddleMin,
			max = SandboxVars.TLOU_infected.CustomInfectionSystemMiddleMax,
		},
		bottom = {
			min = SandboxVars.TLOU_infected.CustomInfectionSystemBottomMin,
			max = SandboxVars.TLOU_infected.CustomInfectionSystemBottomMax,
		},
	}

    -- RUNNER
	if SandboxVars.TLOU_infected.RunnerSpawn then
		ZTypes.TLOU_Runner = {
			-- base informations
			name 					=		getText("IGUI_TLOU_Runner"),
			chance 					=		SandboxVars.TLOU_infected.RunnerSpawnWeight,
			-- customEmitter = {
			-- 	male 				=		"Zombie/Voice/MaleA",
			-- 	female 				=		"Zombie/Voice/FemaleA",
			-- },

			-- stats
			walkType 				=		ZomboidForge.SpeedOptionToWalktype[SandboxVars.TLOU_infected.RunnerSpeed],
			strength 				=		SandboxVars.TLOU_infected.RunnerStrength,
			toughness 				=		SandboxVars.TLOU_infected.RunnerToughness,
			cognition 				=		2,
			memory 					=		2,
			sight 					=		SandboxVars.TLOU_infected.RunnerVision,
			hearing 				=		SandboxVars.TLOU_infected.RunnerHearing,
			HP 						=		SandboxVars.TLOU_infected.RunnerHealth,
			fireKillRate			=		0.0038*SandboxVars.TLOU_infected.RunnerBurnRate,
			shouldCrawl = false,

			-- UI
			color 					=		{122, 243, 0,},
			outline 				=		{0, 0, 0,},

			-- attack functions
			canCrawlUnderVehicles	=		true,

			-- custom behavior

			-- custom data for TLOU_infected
			lootchance 				=		SandboxVars.TLOU_infected.CordycepsSpawnRate_Runner,
			roll_lootcount 			=		function() return ZombRand(1,3) end,
		}
	end

    -- STALKER
	if SandboxVars.TLOU_infected.StalkerSpawn then
		ZTypes.TLOU_Stalker = {
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
			-- customEmitter = {
			-- 	male 				= 		"Zombie/Voice/MaleB",
			-- 	female 				= 		"Zombie/Voice/FemaleB",
			-- },
			clothingVisuals = {
				dirty = 0.5,
				bloody = 0.5,
				holes = true,
			},
			removeBandages 			= 		true,

			-- stats
			walkType 				=		ZomboidForge.SpeedOptionToWalktype[SandboxVars.TLOU_infected.StalkerSpeed],
			strength 				=		1,
			toughness 				=		2,
			cognition 				=		2,
			memory 					=		3,
			sight 					=		SandboxVars.TLOU_infected.StalkerVision,
			hearing 				=		SandboxVars.TLOU_infected.StalkerHearing,
			HP 						=		SandboxVars.TLOU_infected.StalkerHealth,
			fireKillRate			=		0.0038*SandboxVars.TLOU_infected.StalkerBurnRate,
			canCrawlUnderVehicles	=		true,

			-- UI
			color 					= 		{230, 230, 0,},
			outline 				= 		{0, 0, 0,},

			-- attack functions

			-- custom behavior

			-- custom data for TLOU_infected
			lootchance 				= 		SandboxVars.TLOU_infected.CordycepsSpawnRate_Stalker,
			roll_lootcount 			= 		function() return ZombRand(1,5) end,
		}
	end

    -- CLICKER
	if SandboxVars.TLOU_infected.ClickerSpawn then
		ZTypes.TLOU_Clicker = {
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
			-- customEmitter 			= 		"Zombie/Voice/FemaleC",
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
			walkType 				=		ZomboidForge.SpeedOptionToWalktype[2],
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
			onZombieHitCharacter = {
				TLOU_infected.KillTarget,
			},

			-- custom behavior
			onZombieDead = {
				TLOU_infected.OnClickerDeath,
			},
			onTick = {
				TLOU_infected.ClickerAgro,
			},
			customDamage 			= 		"customDamage_tankyInfected",
			-- hitTime 				=		0,
			ignorePush				=		SandboxVars.TLOU_infected.NoPushClickers,
			onlyOneShotgunPellet	=		true,
			fixShotgunsDamage		=		true,

			-- other behavior
			canCrawlUnderVehicles	=		true,

			-- custom data for TLOU_infected
			lootchance 				=		SandboxVars.TLOU_infected.CordycepsSpawnRate_Clicker,
			roll_lootcount 			=		function() return ZombRand(3,8) end,
			fireDamageMultiplier 	=		SandboxVars.TLOU_infected.ExtraFireDamage,
			damageLimiter			=		SandboxVars.TLOU_infected.DamageLimiterClicker,
			extrafireDamage			=		SandboxVars.TLOU_infected.ExtraFireDamage_Clicker,
			totalArmor				=		SandboxVars.TLOU_infected.ClickerArmor,
			energyRequired			=		SandboxVars.TLOU_infected.ClickerEnergyRequired, -- Joule
		}
	end

    -- BLOATER
	if SandboxVars.TLOU_infected.BloaterSpawn then
		ZTypes.TLOU_Bloater = {
			-- base informations
			name 					=		getText("IGUI_TLOU_Bloater"),
			chance 					=		SandboxVars.TLOU_infected.BloaterSpawnWeight,
			outfit = "Bloater",
			animationVariable 		= 		"isBloater",
			-- customEmitter 			=		"Zombie/Voice/MaleC",
			removeBandages 			=		true,

			-- stats
			walkType 				=		ZomboidForge.SpeedOptionToWalktype[2],
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
			onZombieHitCharacter = {
				TLOU_infected.KillTarget,
			},
			-- hitTime 				=		0,
			jawStabImmune			=		true,
			ignoreStagger 			=		true,
			ignoreKnockdown 		=		true,
			ignorePush				=		true,
			onlyOneShotgunPellet	=		true,
			fixShotgunsDamage		=		true,

			-- other behavior
			canCrawlUnderVehicles	=		true,

			-- custom data for TLOU_infected
			lootchance 				=		SandboxVars.TLOU_infected.CordycepsSpawnRate_Bloater,
			roll_lootcount 			=		function() return ZombRand(5,15) end,
			fireDamageMultiplier 	=		SandboxVars.TLOU_infected.ExtraFireDamage,
			damageLimiter			=		SandboxVars.TLOU_infected.DamageLimiterBloater,
			extrafireDamage			=		SandboxVars.TLOU_infected.ExtraFireDamage_Bloater,
			totalArmor				=		SandboxVars.TLOU_infected.BloaterArmor,
			energyRequired			=		SandboxVars.TLOU_infected.BloaterEnergyRequired, -- Joule
		}
	end



	--- ADD SANDBOX OPTIONS BASED ZTYPE CARACTERISTICS ---

	-- cache infected tables
	local runner = ZTypes.TLOU_Runner
	local stalker = ZTypes.TLOU_Stalker
	local clicker = ZTypes.TLOU_Clicker
	local bloater = ZTypes.TLOU_Bloater

	-- If runners and stalkers are able to vault
	if SandboxVars.TLOU_infected.VaultingRunner then
		if runner then
			runner.animationVariable = "isInfected"
		end
	end

	if SandboxVars.TLOU_infected.VaultingStalker then
		if stalker then
			stalker.animationVariable = "isInfected"
		end
	end

	-- if infected should hide indoors during daytime
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

	-- can't stand on infected
	if runner then
		local runner_stand = SandboxVars.TLOU_infected.StandOnInfected_Runner
		if runner_stand ~= 0 then
			runner.standOnInfected = runner_stand
			runner.onTick = runner.onTick or {}
			table.insert(runner.onTick,TLOU_infected.CantStantOnInfected)
		end
	end

	if stalker then
		local stalker_stand = SandboxVars.TLOU_infected.StandOnInfected_Stalker
		if stalker_stand ~= 0 then
			stalker.standOnInfected = stalker_stand
			stalker.onTick = stalker.onTick or {}
			table.insert(stalker.onTick,TLOU_infected.CantStantOnInfected)
		end
	end

	if clicker then
		local clicker_stand = SandboxVars.TLOU_infected.StandOnInfected_Clicker
		if clicker_stand ~= 0 then
			clicker.standOnInfected = clicker_stand
			clicker.onTick = clicker.onTick or {}
			table.insert(clicker.onTick,TLOU_infected.CantStantOnInfected)
		end
	end

	if bloater then
		local bloater_stand = SandboxVars.TLOU_infected.StandOnInfected_Bloater
		if bloater_stand ~= 0 then
			bloater.standOnInfected = bloater_stand
			bloater.onTick = bloater.onTick or {}
			table.insert(bloater.onTick,TLOU_infected.CantStantOnInfected)
		end
	end

	-- if Bloaters are allowed to deal more damage to structures
	if SandboxVars.TLOU_infected.StrongBloater and bloater then
		bloater.onZombieThump = bloater.onZombieThump or {}
		table.insert(bloater.onZombieThump,TLOU_infected.StrongBloater)
	end



	--- CLICKERS ---

	if SandboxVars.TLOU_infected.OneShotClickers then
		if clicker then
			clicker.onZombieHitCharacter = clicker.onZombieHitCharacter or {}
			table.insert(clicker.onZombieHitCharacter,TLOU_infected.KillTarget)
		end
	end



	--- GRABBY INFECTED ---

	if SandboxVars.TLOU_infected.GrabbyClickers then
		if clicker then
			clicker.onZombieHitCharacter = clicker.onZombieHitCharacter or {}
			table.insert(clicker.onZombieHitCharacter,TLOU_infected.GrabbyInfected)
		end
	end

	if SandboxVars.TLOU_infected.GrabbyBloaters then
		if bloater then
			bloater.onZombieHitCharacter = bloater.onZombieHitCharacter or {}
			table.insert(bloater.onZombieHitCharacter,TLOU_infected.GrabbyInfected)
		end
	end



	--- COMPATBILITY PATCHES ---

	-- if Cordyceps Spore Zone is installed and sandbox options for cordyceps spawn is on
	if getActivatedMods():contains("BB_SporeZones") and SandboxVars.TLOU_infected.CordycepsSpawn then
		if runner then
			runner.onZombieDead = runner.onZombieDead or {}
			table.insert(runner.onZombieDead,
				"OnInfectedDeath_cordyceps"
			)
		end

		if stalker then
			stalker.onZombieDead = stalker.onZombieDead or {}
			table.insert(stalker.onZombieDead,
				"OnInfectedDeath_cordyceps"
			)
		end

		if clicker then
			clicker.onZombieDead = clicker.onZombieDead or {}
			table.insert(clicker.onZombieDead,
				"OnInfectedDeath_cordyceps"
			)
		end

		if bloater then
			bloater.onZombieDead = bloater.onZombieDead or {}
			table.insert(bloater.onZombieDead,
				"OnInfectedDeath_cordyceps"
			)
		end
	end
end

return TLOU_infected