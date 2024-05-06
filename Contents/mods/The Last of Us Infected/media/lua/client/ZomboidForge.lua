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
local Long = Long --Long for pID

--- import module from ZomboidForge
local ZomboidForge = require "ZomboidForge_module"

--- OnLoad function to initialize the mod
ZomboidForge.OnLoad = function()
    -- initialize ModData
    local ZFModData = ModData.getOrCreate("ZomboidForge")
    if not ZFModData.PersistentZData then
        ZFModData.PersistentZData = {}
    end

    -- reset non persistent data
    ZomboidForge.NonPersistentZData = {}

    -- calculate total chance
    ZomboidForge.TotalChance = 0
    for _,ZombieTable in pairs(ZomboidForge.ZTypes) do
        ZomboidForge.TotalChance = ZomboidForge.TotalChance + ZombieTable.chance
    end
end

--- OnLoad function to initialize the mod
ZomboidForge.OnGameStart = function()
    -- Update tickUpdater with Sandbox settings
    ZomboidForge.counter = SandboxVars.ZomboidForge.tickUpdater

    -- Zomboid (base game zombies)
	if SandboxVars.ZomboidForge.ZomboidSpawn then
		ZomboidForge.ZTypes.ZF_Zomboid = {
            -- base informations
            name = "IGUI_ZF_Zomboid",
            chance = SandboxVars.ZomboidForge.ZomboidChance,
            outfit = {},
            reanimatedPlayer = false,
            skeleton = false,
            hair = {},
            hairColor = {},
            beard = {},
            beardColor = {},

            -- stats
            walktype = 1,
            strength = 2,
            toughness = 2,
            cognition = 3,
            memory = 2,
            sight = 2,
            hearing = 2,

            noteeth = false,
            transmission = false,

            -- UI
            color = {255, 255, 255,},
            outline = {0, 0, 0,},

            -- attack functions
            funcattack = {},
            funconhit = {},

            -- custom behavior
            onDeath = {},
            customBehavior = {},

            customData = {},
        }
	end
end

--- Initialize a zombie. `fullResetZ` will completely wipe the zombie data while
-- `rollZType` rolls a new ZType.
---@param zombie        IsoZombie
---@param fullResetZ    boolean
---@param rollZType     boolean
ZomboidForge.ZombieInitiliaze = function(zombie,fullResetZ,rollZType)
    -- get zombie data
    local trueID = ZomboidForge.pID(zombie)
    local ZFModData = ModData.getOrCreate("ZomboidForge")
    local PersistentZData = ZFModData.PersistentZData[trueID]

    -- fully reset the stats of the zombie
    if fullResetZ then
        ZFModData.PersistentZData[trueID] = {}
        ZomboidForge.NonPersistentZData[trueID] = {}
        PersistentZData = {}
    end

    -- attribute zombie type if not set by weighted random
    if rollZType then
        local ZType = PersistentZData.ZType
        if not ZType or not ZomboidForge.ZTypes[ZType] then
            ZomboidForge.RollZType(zombie)
        end
    end

    -- set zombie age
    if zombie:getAge() ~= -1 then
		zombie:setAge(-1)
	end
end

--- Main function:
-- 
-- Handles everything about the Zombies.
-- Steps of Zombie update:
--
--      `Initialize zombie type`
--      `Update zombie data and stats`
--      `Run custom behavior`
--      `Run zombie attack function`
---@param zombie        IsoZombie
ZomboidForge.ZombieUpdate = function(zombie)
    -- get zombie data
    local trueID = ZomboidForge.pID(zombie)
    local ZFModData = ModData.getOrCreate("ZomboidForge")
    local PersistentZData = ZFModData.PersistentZData[trueID]

    -- check if zombie is initialized
    if not PersistentZData or not PersistentZData.ZType then
        ZomboidForge.ZombieInitiliaze(zombie,true,true)
        return
    end

    local ZType = PersistentZData.ZType
    local ZombieTable = ZomboidForge.ZTypes[ZType]

    if not ZombieTable then return end

    -- run custom behavior functions for this zombie
    for i = 1,#ZombieTable.customBehavior do
        ZomboidForge[ZombieTable.customBehavior[i]](zombie,ZType)
    end

    -- run zombie attack functions
    if zombie:isAttacking() then
        ZomboidForge.ZombieAttack(zombie,ZType)
    end
end

local zombieList
local zeroTick = 0
-- Handles the updating of the stats of every zombies as well as initializing them. zombieList is initialized
-- for the client and doesn't need to be changed after. The code goes through every zombie index and updates
-- the stats of each zombies at a rate of 1/tick. A higher update rate for zombies shouldn't be needed as you
-- update 60 zombies for every ticks and you will rarely play x16 population with this mod.
--
-- The part updating one zombie per tick was made by `Albion`.
--
-- Added to `OnTick`.
---@param tick          int
ZomboidForge.OnTick = function(tick)
    -- initialize zombie list
    if not zombieList then
        zombieList = getPlayer():getCell():getZombieList()
    end

    -- Update zombie stats
    local zombieIndex = tick - zeroTick
    if zombieList:size() > zombieIndex then
        local zombie = zombieList:get(zombieIndex)
        ZomboidForge.SetZombieData(zombie,nil)
    else
        zeroTick = tick + 1
    end
end

--- `Zombie` attacking `Player`. 
-- 
-- Trigger `funcattack` of `Zombie` depending on `ZType`.
---@param zombie        IsoZombie
---@param ZType         integer     --Zombie Type ID
ZomboidForge.ZombieAttack = function(zombie,ZType)
    local target = zombie:getTarget()
    if target and target:isCharacter() then
        local ZombieTable = ZomboidForge.ZTypes[ZType]
        if instanceof(target, "IsoPlayer") then
            ---@cast target IsoPlayer
            ZomboidForge.ShowZombieName(target, zombie)
        end
        if ZombieTable.funcattack then
            for i=1,#ZombieTable.funcattack do
                ZomboidForge[ZombieTable.funcattack[i]](target,zombie,ZType)
            end
        end
    end
end

--- `Player` attacking `Zombie`. 
-- 
-- Trigger `funconhit` of `Zombie` depending on `ZType`.
--
-- Handles the custom HP of zombies and apply custom damage depending on the customDamage function.
---@param attacker      IsoPlayer
---@param victim        IsoZombie
ZomboidForge.OnHit = function(attacker, victim, handWeapon, damage)
    if victim:isZombie() then
        local trueID = ZomboidForge.pID(victim)
        local ZFModData = ModData.getOrCreate("ZomboidForge")
        local PersistentZData = ZFModData.PersistentZData[trueID]
        if not PersistentZData then return end

        local ZType = PersistentZData.ZType
        local ZombieTable = ZomboidForge.ZTypes[ZType]

        if ZType then
            if ZombieTable and ZombieTable.funconhit then
                for i=1,#ZombieTable.funconhit do
                    ZomboidForge[ZombieTable.funconhit[i]](attacker, victim, handWeapon, damage)
                end
            end
            ZomboidForge.ShowZombieName(attacker, victim)
        end

        -- skip if no HP stat or HP is 1
        if ZombieTable.HP and ZombieTable.HP ~= 1 and handWeapon:getFullType() ~= "Base.BareHands" then
            -- get or set HP amount
            local HP = PersistentZData.HP or ZombieTable.HP

            -- get damage if exists
            if ZombieTable.customDamage then
                damage = ZomboidForge[ZombieTable.customDamage](attacker, victim, handWeapon, damage)
            end
            HP = HP - damage

            -- set zombie health or kill zombie
            if (HP <= 0) then
                victim:setOnlyJawStab(false)
                victim:Kill(attacker)
            else
                -- Makes sure the Zombie doesn't get oneshoted by whatever bullshit weapon
                -- someone might use.
                -- Updates the HP counter of PersistentZData
                victim:setHealth(1000)
                PersistentZData.HP = HP
            end
        end
    end
end

--- OnDeath functions
---@param zombie        IsoZombie
ZomboidForge.OnDeath = function(zombie)
    local trueID = ZomboidForge.pID(zombie)
    local ZFModData = ModData.getOrCreate("ZomboidForge")
    local PersistentZData = ZFModData.PersistentZData[trueID]
    if not PersistentZData then return end

    local ZType = PersistentZData.ZType
    -- initialize zombie type
    -- only a security for mods that insta-kill zombies on spawn
    if not ZType then
        ZomboidForge.ZombieInitiliaze(zombie,true,true)
    end

    local ZombieTable = ZomboidForge.ZTypes[ZType]

    -- run custom behavior functions for this zombie
    for i = 1,#ZombieTable.onDeath do
        ZomboidForge[ZombieTable.onDeath[i]](zombie,ZType)
    end
    -- reset emitters
    zombie:getEmitter():stopAll()

    -- delete zombie data
    ZFModData.PersistentZData[trueID] = nil
    ZomboidForge.NonPersistentZData[trueID] = nil
end
