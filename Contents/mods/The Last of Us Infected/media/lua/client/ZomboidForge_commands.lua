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

--#region Mod Data handling

-- Send mod data to server from this client.
---@param args          table
ZomboidForge.ModData_Client2Server = function(args)
    if isClient() then
        sendClientCommand('ZF_ModData', 'ModData_Client2Server', args)
    end
end

-- Receive mod data from server to update for the client.
---@param args		table
ZomboidForge.Commands.ZF_ModData.ModData_Server2Client = function(args)
    -- skip if client receiving mod data is the one who sent it
    if args.playerID and getPlayerByOnlineID(args.playerID) ~= getPlayer() then
        local ModData = ModData.getOrCreate(args.modData)

        -- Add data to mod data
        -- If data = table then add every entries else add just the data to the key
        if type(args.data) == "table" then
            for k,v in pairs(args.data) do
                ModData[args.category][args.key][k] = v
            end
        else
            ModData[args.category][args.key] = args.data
        end
    end
end

--#endregion