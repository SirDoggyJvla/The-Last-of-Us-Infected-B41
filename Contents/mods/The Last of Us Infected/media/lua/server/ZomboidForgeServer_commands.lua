--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the server side lua of ZomboidForge.

]]--
--[[ ================================================ ]]--

--- Import functions localy for performances reasons
local table = table -- Lua's table module
local ipairs = ipairs -- ipairs function
local pairs = pairs -- pairs function
local ZombRand = ZombRand -- java function
local print = print -- print function
local tostring = tostring --tostring function

--- import module
local ZomboidForge_server = require "ZomboidForgeServer_module"

--#region Server side commands
-- ZomboidForge.Commands.module.command

-- Updates animation variables of zombies for every single clients.
ZomboidForge_server.Commands.AnimationHandler.SetAnimationVariable = function(player, args)
	sendServerCommand('AnimationHandler', 'SetAnimationVariable', {id = player:getOnlineID(), animationVariable = args.animationVariable, zombie =  args.zombie, state = args.state})
end

-- Update data received from client to store in server's mod data
-- and send the data to every other clients to store in their own mod data.
---@param _			nil
---@param args		table
ZomboidForge_server.Commands.ZF_ModData.ModData_Client2Server = function(_, args)
	local ModData = ModData.getOrCreate(args.modData)
	ModData[args.category][args.key] = args.data

	
end

-- Send data from server to every clients to store in their mod data.
---@param _			nil
---@param args		table
ZomboidForge_server.Commands.ZF_ModData.ModData_Server2Clients = function(_,args)
	sendClientCommand('ZF_ModData', 'ModData_Server2Client', args)
end

--#endregion