
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

print("load TLOU_infected")
--- import module from ZomboidForge
local ZomboidForge = require "ZomboidForge"

--- setup local functions
local TLOU_infected = {}

--- Create zombie type
ZomboidForge.InitTLOUInfected = function()
    -- Runner
    table.insert(ZomboidForge.ZTypes,
        {
            -- base informations
            name = "IGUI_TLOU_Runner",
            chance = SandboxVars.TLOUZombies.Runner,

            -- stats
			walktype = 1,
			strength = 2,
			toughness = 2,
			cognition = 3,
			memory = 2,
			sight = SandboxVars.TLOUZombies.RunnerVision,
			hearing = SandboxVars.TLOUZombies.RunnerHearing,
			HP = 1,

            -- custom variables
			keepstand = true,
			isClicker = true,
			isBloater = false,
			hideIndoors = true,

            -- UI
			color = {122, 243, 0,},
			outline = {0, 0, 0,},

            -- attack functions
			funcattack = {},
			funconhit = {},

            -- custom behavior
            onZombieUpdate = {},
        }
    )

    -- Stalker
    table.insert(ZomboidForge.ZTypes,
        {
            -- base informations
            name = "IGUI_TLOU_Stalker",
            chance = SandboxVars.TLOUZombies.Stalker,

            -- stats
			walktype = 1,
			strength = 1,
			toughness = 2,
			cognition = 3,
			memory = 4,
			sight = SandboxVars.TLOUZombies.StalkerVision,
			hearing = SandboxVars.TLOUZombies.StalkerHearing,
			HP = 1,

            -- custom variables
			keepstand = true,
			isClicker = true,
			isBloater = false,
			hideIndoors = true,

            -- UI
			color = {230, 230, 0,},
			outline = {0, 0, 0,},

            -- attack functions
			funcattack = {},
			funconhit = {},

            -- custom behavior
            onZombieUpdate = {},
        }
    )

    -- Clicker
    table.insert(ZomboidForge.ZTypes,
        {
            -- base informations
            name = "IGUI_TLOU_Clicker",
            chance = SandboxVars.TLOUZombies.Clicker,

            -- stats
			walktype = 2,
			strength = 1,
			toughness = 1,
			cognition = 3,
			memory = 2,
			sight = 3,
			hearing = SandboxVars.TLOUZombies.ClickerHearing,
			HP = SandboxVars.TLOUZombies.ClickerHealth,

            -- custom variables
			keepstand = true,
			isClicker = true,
			isBloater = false,
			hideIndoors = true,

            -- UI
			color = {218, 109, 0,},
			outline = {0, 0, 0,},

            -- attack functions
			funcattack = {"ClickerAttack"},
			funconhit = {"ClickerHit"},

            -- custom behavior
            onZombieUpdate = {},
        }
    )

    -- Bloater
    table.insert(ZomboidForge.ZTypes,
        {
            -- base informations
            name = "IGUI_TLOU_Bloater",
            chance = SandboxVars.TLOUZombies.Bloater,

            -- stats
			walktype = 2,
			strength = 1,
			toughness = 1,
			cognition = 3,
			memory = 2,
			sight = 3,
			hearing = SandboxVars.TLOUZombies.BloaterHearing,
			HP = SandboxVars.TLOUZombies.BloaterHealth,

            -- custom variables
			keepstand = true,
			isClicker = false,
			isBloater = true,
			hideIndoors = true,

            -- UI
			color = {205, 0, 0,},
			outline = {0, 0, 0,},

            -- attack functions
			funcattack = {"BloaterAttack"},
			funconhit = {"BloaterHit"},

            -- custom behavior
            onZombieUpdate = {},
        }
    )
end

--- Behavior functions
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