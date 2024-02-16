--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

This file defines the core of the mod of The Last of Us Infected Fork

]]--
--[[ ================================================ ]]--

--- main module for use in storing informations and pass along other files
local ZomboidForge = {}

-- initialize variables within ZomboidForge
ZomboidForge.ZTypes = {}

--- OnLoad function to initialize the mod
ZomboidForge.OnLoad = function()
    print("load mod TLOU")
    ZomboidForge.TotalZTypes = #ZomboidForge.ZTypes


    ZomboidForge.TotalChance = 0
    for i = 1,ZomboidForge.TotalZTypes do
        print(i)
        print(ZomboidForge.TotalChance)
        ZomboidForge.TotalChance = ZomboidForge.TotalChance + ZomboidForge.ZTypes[i].chance
    end


    print("Total ZomboidForge chances")
    print(ZomboidForge.TotalChance)
end

--- Initialize a zombie type
ZomboidForge.ZombieInitiliaze = function(zombie)
    local size = #ZomboidForge.ZTypes

    local rand = ZombRand(ZomboidForge.TotalChance)
    for i = 1,ZomboidForge.TotalZTypes do
        rand = rand - ZomboidForge.ZTypes[i].chance
        if rand <= 0 then
            
            local name = ZomboidForge.ZTypes[i].name
            zombie:getModData()['name'] = name
            print("setting name")
            print(name)
            break
        end
    end
end


--- Main function:
-- meant to do every actions of a zombie
ZomboidForge.ZombieUpdate = function(zombie)

    -- Initialize zombie type
    if zombie:getModData()['name'] == nil then
        ZomboidForge.ZombieInitiliaze(zombie)
    else
        --print(zombie:getModData()['name'])
    end


    for i = 1,ZomboidForge.TotalZTypes do
        ZombieTable = ZomboidForge.ZTypes[i]
        ZombieType = ZombieTable.name
        --print(ZombieType)

        ZomboidForge[ZombieTable.onZombieUpdate[1]]()
    end

    local name = zombie:getModData()['name']
    --print(name)
end

Events.OnZombieUpdate.Add(ZomboidForge.ZombieUpdate)
--Events.OnCreatePlayer.Add(ZomboidForge.OnLoad)
Events.OnLoad.Add(ZomboidForge.OnLoad)

return ZomboidForge