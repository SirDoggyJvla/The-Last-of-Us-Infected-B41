--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the server2clients commands of the mod of The Last of Us Infected

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
require "TLOU_infected"

-- localy initialize player
local player = getPlayer()
local function initTLOU_OnGameStart(playerIndex, player_init)
	player = getPlayer()
end
Events.OnCreatePlayer.Remove(initTLOU_OnGameStart)
Events.OnCreatePlayer.Add(initTLOU_OnGameStart)

-- Call from server2clients to kill player target.
TLOU_infected.Commands.Behavior.KillTarget = function(args)
    -- retrieve attacker IsoPlayer
    local victim = getPlayerByOnlineID(args.victim)
    if victim and player ~= victim  then
        -- get zombie info
        local zombie = args.zombie and ZomboidForge.getZombieByOnlineID(args.zombie) or nil
        victim:Kill(zombie)
    end
end