
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

--- main TLOU Infected module for use in storing informations and pass along other files
local ZomboidForge = {}
ZomboidForge.ZTypes = {}

ZomboidForge.OnLoad = function()
    ZomboidForge.TotalZTypes = #ZomboidForge.ZTypes

    for i = 1,ZomboidForge.TotalZTypes do
        ZomboidForge.TotalChance = ZomboidForge.TotalChance + ZomboidForge.ZTypes[i].chance
    end


    print("Total ZomboidForge chances")
    print(ZomboidForge.TotalChance)
end

ZomboidForge.ZombieInitiliaze = function(zombie)
    local size = #ZomboidForge.ZTypes

    for i = 1,ZomboidForge.TotalZTypes do


        ZomboidForge[ZombieTable.onZombieUpdate[1]]()
    end
end


ZomboidForge.ZombieUpdate = function(zombie)



    if zombie:getModData()['isInitialized'] == nil then
        ZomboidForge.ZombieInitiliaze(zombie)
    else
        print(zombie:getModData()['isInitialized'])
    end


    for i = 1,ZomboidForge.TotalZTypes do
        ZombieTable = ZomboidForge.ZTypes[i]
        ZombieType = ZombieTable.name
        --print(ZombieType)

        ZomboidForge[ZombieTable.onZombieUpdate[1]]()
    end
end

Events.OnZombieUpdate.Add(ZomboidForge.ZombieUpdate)
Events.OnGameStart.Add(ZomboidForge.OnLoad)

return ZomboidForge