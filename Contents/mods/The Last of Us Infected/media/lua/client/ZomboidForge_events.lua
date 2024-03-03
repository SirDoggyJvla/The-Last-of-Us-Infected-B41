--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the events used by Zomboid Forge

]]--
--[[ ================================================ ]]--

--- import module
local ZomboidForge = require "ZomboidForge_module"

--- Local module
local ZFEvents = {}

--- Events added OnLoad
ZFEvents.OnLoad = function()
    -- Adds the nametag update event if activated in sandbox settings
    if SandboxVars.ZomboidForge.Nametags then
        Events.OnTick.Add(ZomboidForge.UpdateNametag)
    end
end
Events.OnLoad.Add(ZFEvents.OnLoad)

--- ZomboidForge functions
Events.OnLoad.Add(ZomboidForge.OnLoad)
Events.OnGameStart.Add(ZomboidForge.OnGameStart)
Events.OnZombieUpdate.Add(ZomboidForge.ZombieUpdate)
Events.OnWeaponHitCharacter.Add(ZomboidForge.OnHit)
Events.OnZombieDead.Add(ZomboidForge.OnDeath)
Events.OnPlayerUpdate.Add(ZomboidForge.GetZombieOnPlayerMouse)

Events.OnServerCommand.Add(ZomboidForge.OnServerCommand)
Events.OnClientCommand.Add(ZomboidForge.OnClientCommand)