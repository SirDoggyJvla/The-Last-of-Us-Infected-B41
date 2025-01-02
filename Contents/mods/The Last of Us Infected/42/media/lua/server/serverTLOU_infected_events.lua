--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the server events of the mod of The Last of Us Infected

]]--
--[[ ================================================ ]]--

local TLOU_infected_server = require "serverTLOU_infected_commands"

Events.OnClientCommand.Add(function(module, command, player, args)
	if TLOU_infected_server.Commands[module] and TLOU_infected_server.Commands[module][command] then
	    TLOU_infected_server.Commands[module][command](player, args)
	end
end)