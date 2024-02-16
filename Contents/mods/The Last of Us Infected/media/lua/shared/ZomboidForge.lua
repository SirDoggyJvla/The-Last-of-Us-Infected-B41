
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

    print(#ZomboidForge.ZTypes)
    print(ZomboidForge.TotalZTypes)

    print(ZomboidForge.ZTypes[1])
    print(ZomboidForge.ZTypes[1].name)

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
    print("start initialize")
    local rand = ZombRand(ZomboidForge.TotalChance)
    print(rand)
    for i = 1,ZomboidForge.TotalZTypes do
        print(i)
        print(ZomboidForge.ZTypes[i].chance)
        rand = rand - ZomboidForge.ZTypes[i].chance
        print(rand)
        if rand <= 0 then
            print("setting name")
            local name = ZomboidForge.ZTypes[i].name
            zombie:getModData()['name'] = name
            print(name)
            break
        else
            zombie:getModData()['name'] = "no name"
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

        ZomboidForge[ZombieTable.onZombieUpdate[i]]()
    end

    local name = zombie:getModData()['name']
    --print(name)
end

Events.OnZombieUpdate.Add(ZomboidForge.ZombieUpdate)
--Events.OnCreatePlayer.Add(ZomboidForge.OnLoad)
Events.OnGameStart.Add(ZomboidForge.OnLoad)

return ZomboidForge