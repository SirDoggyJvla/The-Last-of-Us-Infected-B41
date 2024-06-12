--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the client2server commands of the mod of The Last of Us Infected

]]--
--[[ ================================================ ]]--

TLOU_infected_server = {
	Commands = {
		Behavior = {},
	},
}

TLOU_infected_server.Commands.Behavior.KillTarget = function(player,args)
	local new_args = {
		zombie = args.zombie,
		victim = player:getOnlineID()
	}

    sendServerCommand('Behavior','KillTarget',new_args)
end

return TLOU_infected_server