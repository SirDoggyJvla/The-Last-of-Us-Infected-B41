
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

--- import module from ZomboidForge
local ZomboidForge = require "ZomboidForge"

--- setup local functions
local TLOU_infected = {}

--- Create zombie type
ZomboidForge.InitTLOUInfected = function()
    table.insert(ZomboidForge.ZTypes,
        {
            name = "Stalker",
            onZombieUpdate = {"myfunction"},
        }
    )
    table.insert(ZomboidForge.ZTypes,
        {
            name = "Clicker",
            onZombieUpdate = {"myfunction"},
        }
    )

    --[[
    table.insert(ZomboidForge.ZTypes,
        {
            name = "IGUI_TLOU_Runner",
            chance = SandboxVars.TLOUZombies.Runner,
			walktype = 2,
			strength = 1,
			toughness = 1,
			cognition = 3,
			memory = 2,
			sight = 3,
			hearing = SandboxVars.TLOUZombies.RunnerHearing,
			HP = SandboxVars.TLOUZombies.RunnerHealth,

			keepstand = true,
			isClicker = true,
			isBloater = false,
			hideIndoors = true,

			color = {218, 109, 0,},
			outline = {0, 0, 0,},

			funcattack = {"RunnerAttack"},
			funconhit = {"RunnerHit"},

            onZombieUpdate = {"myfunction"},
        }
    )
    table.insert(ZomboidForge.ZTypes,
        {
            name = "IGUI_TLOU_Clicker",
            chance = SandboxVars.TLOUZombies.Clicker,
			walktype = 2,
			strength = 1,
			toughness = 1,
			cognition = 3,
			memory = 2,
			sight = 3,
			hearing = SandboxVars.TLOUZombies.ClickerHearing,
			HP = SandboxVars.TLOUZombies.ClickerHealth,

			keepstand = true,
			isClicker = true,
			isBloater = false,
			hideIndoors = true,

			color = {218, 109, 0,},
			outline = {0, 0, 0,},

			funcattack = {"ClickerAttack"},
			funconhit = {"ClickerHit"},

            onZombieUpdate = {"myfunction"},
        }
    )
    ]]
end

ZomboidForge.myfunction = function()
    print("hello")
end

Events.OnGameStart.Add(ZomboidForge.InitTLOUInfected)