--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the module of Zomboid Forge server side

]]--
--[[ ================================================ ]]--

if isClient() then return end

--- main module for use in storing informations and pass along other files
local ZomboidForge_server = {}

-- initialize command module
ZomboidForge_server.Commands = {}
ZomboidForge_server.Commands.AnimationHandler = {}

-- module.Commands.module.command
ZomboidForge_server.Commands.AnimationHandler.SetAnimationVariable = function(player, args)
	sendServerCommand('AnimationHandler', 'SetAnimationVariable', {id = player:getOnlineID(), animationVariable = args.animationVariable, zombie =  args.zombie})
end

Events.OnClientCommand.Add(function(module, command, player, args)
	if ZomboidForge_server.Commands[module] and ZomboidForge_server.Commands[module][command] then
	    ZomboidForge_server.Commands[module][command](player, args)
	end
end)

return ZomboidForge_server