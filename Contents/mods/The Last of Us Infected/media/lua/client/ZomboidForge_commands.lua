--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the core of the mod Zomboid Forge

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

-- Sends a request to server to update every clients animationVariable for every clients.
---@param args          table
ZomboidForge.Commands.AnimationHandler.SetAnimationVariable = function(args)
    -- get zombie info
    local zombie = args.zombie
    if getPlayer() ~= getPlayerByOnlineID(args.id) then
        if zombie then
            zombie:setVariable(args.animationVariable,args.state)
        end
    end
end

-- Receive mod data from server to update for the client.
---@param args		table
ZomboidForge.Commands.ZF_ModData.ModData_Server2Client = function(args)
    local ModData = ModData.getOrCreate(args.modData)
	ModData[args.category][args.key] = args.data
end