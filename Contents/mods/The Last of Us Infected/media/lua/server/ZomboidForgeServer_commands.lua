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
---@param player	IsoPlayer	--player unused
---@param args		table
ZomboidForge_server.Commands.ZF_ModData.ModData_Client2Server = function(player, args)
	local ModData = ModData.getOrCreate(args.modData)

	-- Initialize mod data tables if not already
	if not ModData[args.category] then
		ModData[args.category] = {}
		ModData[args.category][args.key] = {}
	elseif not ModData[args.category][args.key] then
		ModData[args.category][args.key] = {}
	end

	-- Add data to mod data
	-- If data = table then add every entries else add just the data to the key
	if type(args.data) == "table" then
		for k,v in pairs(args.data) do
			ModData[args.category][args.key][k] = v
		end
	else
		ModData[args.category][args.key] = args.data
	end

	-- Tell every other clients to update their mod data
	ZomboidForge_server.Commands.ZF_ModData.ModData_Server2Clients(player,args)
end

-- Send data from server to every clients to store in their mod data.
---@param player	IsoPlayer	--player unused
---@param args		table
ZomboidForge_server.Commands.ZF_ModData.ModData_Server2Clients = function(player,args)
	-- Used for players to ignore updating their mod data if they are the source of this update
	args.playerID = player:getOnlineID()

	-- Call clients to update their mod data with the data received by server
	sendClientCommand('ZF_ModData', 'ModData_Server2Client', args)
end

--#endregion