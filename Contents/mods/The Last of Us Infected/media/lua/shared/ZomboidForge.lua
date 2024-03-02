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

--- main module for use in storing informations and pass along other files
--local ZomboidForge = {}

--- import module from ZomboidForge
local ZomboidForge = require "ZomboidForge_module"

--- Stats for each zombies. `key` of `Stats` are the variable to 
-- define with `key` value from `returnValue`. The `value` of `returnValue` 
-- associated to a `key` is the compared one with what the game returns 
-- from `isoZombie class fields`.
ZomboidForge.Stats = {
    -- defines walk speed of zombie
    walktype = {
        setSandboxOption = "ZombieLore.Speed",
        --classField = "speedType",
        returnValue = {
            [1] = 1, -- sprinter
            [2] = 2, -- fast shambler
            [3] = 3, -- shambler
            -- [4] crawlers speed doesn't matter
        },
    },

    -- defines the sight setting
    sight = {
        setSandboxOption = "ZombieLore.Sight",
        classField = "sight",
        returnValue = {
            [1] = 1, -- Eagle
            [2] = 2, -- Normal 
            [3] = 3, -- Poor
            --[4] = ZomboidForge.coinFlip(),
        },
    },

    -- defines the sight setting
    hearing = {
        setSandboxOption = "ZombieLore.Hearing",
        classField = "hearing",
        returnValue = {
            [1] = 1, -- Pinpoint
            [2] = 2, -- Normal 
            [3] = 3, -- Poor
            --[4] = ZomboidForge.coinFlip(),
        },
    },

    -- defines cognition aka navigation of zombie
    --
    -- navigate = basic navigate.
    -- It's a lie from the base game so doesn't matter which one
    -- you chose
    cognition = {
        setSandboxOption = "ZombieLore.Cognition",
        classField = "cognition",
        returnValue = {
            [1] = 1, -- can open doors
            [2] = -1, -- navigate 
            [3] = -1, -- basic navigate
            --[4] = ZomboidForge.coinFlip(),
        },
    },

    --- UNVERIFIABLE STATS
    -- these stats can't be checked if already updated because
    -- of how the fields are updated or if they don't have any
    -- class fields to check them.
    
    -- defines the memory setting
    memory = {
        setSandboxOption = "ZombieLore.Memory",
        --classField = "memory",
        returnValue = {
            [1] = 1250, -- long
            [2] = 800, -- normal 
            [3] = 500, -- short
            [4] = 25, -- none
        },
    },

    -- defines strength of zombie
    -- undefined, causes issues when toughness is modified
    strength = {
        setSandboxOption = "ZombieLore.Strength",
        --classField = "strength",
        returnValue = {
            [1] = 5, -- Superhuman
            [2] = 3, -- Normal
            [3] = 1, -- Weak
        },
    },

    -- defines toughness of zombie
    -- undefined
    toughness = {
        setSandboxOption = "ZombieLore.Toughness",
        --classField = missing,
        returnValue = {
            [1] = 1,
            [2] = 2,
            [3] = 3,
        },
    },

    -- defines the transmission setting
    transmission = {
        setSandboxOption = "ZombieLore.Transmission",
        --classField = missing,
        returnValue = {
            [1] = 1, -- can open doors
            [2] = 2, -- navigate 
            [3] = 3, -- basic navigate
            --[4] = ZomboidForge.coinFlip(),
        },
    },
}

--- OnLoad function to initialize the mod
ZomboidForge.OnLoad = function()
    -- initialize ModData
    local ZFModData = ModData.getOrCreate("ZomboidForge")
    if not ZFModData.PersistentZData then
        ZFModData.PersistentZData = {}
    end

    -- get numbers of Zombie Types
    --ZomboidForge.TotalZTypes = #ZomboidForge.ZTypes

    -- calculate total chance
    ZomboidForge.TotalChance = 0
    for ZTypes,ZombieTable in pairs(ZomboidForge.ZTypes) do
    --for i = 1,ZomboidForge.TotalZTypes do
        ZomboidForge.TotalChance = ZomboidForge.TotalChance + ZombieTable.chance
    end
end


--- Initialize a zombie if he's needed
--
--          `Zombie stats`
--          `Zombie outfit`
--          `Set Zombie to skeleton`
--          `Zombie hair`
--          `Zombie hair color`
--          `Zombie beard`
--          `Zombie beard color`
--
---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
ZomboidForge.ZombieInitiliaze = function(zombie)
    local trueID = ZomboidForge.pID(zombie)

    local ZFModData = ModData.getOrCreate("ZomboidForge")
    ZFModData.PersistentZData[trueID] = ZFModData.PersistentZData[trueID] or {}
    local PersistentZData = ZFModData.PersistentZData[trueID]

    ZFModData.test = true

    -- attribute zombie type if not set
    local ZType = PersistentZData.ZType
    if not ZType or not ZomboidForge.ZTypes[ZType] then
    --if not PersistentZData.ZType or not ZomboidForge.ZTypes[PersistentZData.ZType] then
        local rand = ZombRand(ZomboidForge.TotalChance)
        for ZTypes,ZombieTable in pairs(ZomboidForge.ZTypes) do
        --for i = 1,ZomboidForge.TotalZTypes do
            rand = rand - ZombieTable.chance
            if rand <= 0 then
                PersistentZData.ZType = ZTypes
                break
            end
        end
        ZType = PersistentZData.ZType
    end

    local ZombieTable = ZomboidForge.ZTypes[ZType]

    -- become reanimated zombie
    if ZombieTable.reanimatedPlayer and not zombie:isReanimatedPlayer() then
        zombie:setReanimatedPlayer(true)
    end

    -- set zombie age and reset emitters
    if zombie:getAge() ~= -1 then
		zombie:setAge(-1)
	end

    ZomboidForge.PersistentOutfitID[trueID].IsInitialized = true
end

--- Used to set the various data of a zombie, skipping the unneeded parts or already done. Order of data set:
--
--          `Zombie stats`
--          `Zombie outfit`
--          `Set Zombie to skeleton`
--          `Zombie hair`
--          `Zombie hair color`
--          `Zombie beard`
--          `Zombie beard color`
--
---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
---@param ZType integer     --Zombie Type ID
ZomboidForge.SetZombieData = function(zombie,ZType)
    local trueID = ZomboidForge.pID(zombie)
    local nonPersistentZData = ZomboidForge.PersistentOutfitID[trueID]
    local IsSet = 0

    -- get ZType data
    local ZombieTable = ZomboidForge.ZTypes[ZType]
    -- update zombie stats
    if not nonPersistentZData.GlobalCheck then
        ZomboidForge.CheckZombieStats(zombie,ZType)
    else
        IsSet = IsSet + 1
    end

    -- set zombie clothing
    if #ZombieTable.outfit > 0 then
        local currentOutfit = zombie:getOutfitName()
        local outfitChoice = ZomboidForge.RandomizeTable(ZombieTable,"outfit",currentOutfit)
        if outfitChoice then
            zombie:dressInNamedOutfit(outfitChoice)
	        zombie:reloadOutfit()
        else
            IsSet = IsSet + 1
        end
    else
        IsSet = IsSet + 1
    end

    -- update zombie visuals
    -- set to skeleton
    if ZombieTable.skeleton and not zombie:isSkeleton() then
        zombie:setSkeleton(true)
    elseif zombie:isSkeleton() then
        IsSet = IsSet + 1
    end

    -- set hair
    if ZombieTable.hair then
        local key = "male"
        if zombie:isFemale() then
            key = "female"
        end
        local ZDataTable = ZombieTable.hair
        local zombieVisual = zombie:getHumanVisual()
        local currentHair = zombieVisual:getHairModel()
        --local hairChoice = false
        local hairChoice = false
        if ZDataTable[key] then
            hairChoice = ZomboidForge.RandomizeTable(ZDataTable,key,currentHair)
        end
        if hairChoice then
            zombieVisual:setHairModel(hairChoice)
            zombie:resetModel()
        else
            IsSet = IsSet + 1
        end
    else
        IsSet = IsSet + 1
    end

    -- set hair color
    if #ZombieTable.hairColor > 0 then
        local zombieVisual = zombie:getHumanVisual()
        local currentHairColor = zombieVisual:getHairColor()
        local hairColorChoice = ZomboidForge.RandomizeTable(ZombieTable,"hairColor",currentHairColor)
        if hairColorChoice then
            zombieVisual:setHairColor(hairColorChoice)
            zombie:resetModel()
        else
            IsSet = IsSet + 1
        end
    else
        IsSet = IsSet + 1
    end

    -- set beard if male
    if #ZombieTable.beard > 0 and not zombie:isFemale() then
        local zombieVisual = zombie:getHumanVisual()
        local currentBeard = zombieVisual:getBeardModel()
        local beardChoice = ZomboidForge.RandomizeTable(ZombieTable,"beard",currentBeard)
        if beardChoice then
            zombieVisual:setBeardModel(beardChoice)
            zombie:resetModel()
        else
            IsSet = IsSet + 1
        end
    else
        IsSet = IsSet + 1
    end

    -- set beard color if male
    if #ZombieTable.beardColor > 0 and not zombie:isFemale() then
        local zombieVisual = zombie:getHumanVisual()
        local currentBeardColor = zombieVisual:getHairColor()
        local beardColorChoice = ZomboidForge.RandomizeTable(ZombieTable,"beardColor",currentBeardColor)
        if beardColorChoice or true then
            zombieVisual:setHairColor(beardColorChoice)
            zombie:resetModel()
        else
            IsSet = IsSet + 1
        end
    else
        IsSet = IsSet + 1
    end

    if ZombieTable.HP and not (ZombieTable.HP == 1) then
    
    else
        IsSet = IsSet + 1
    end

    -- update IsDataSet
    if IsSet >= 8 then
        nonPersistentZData.IsDataSet = true
    end
end

--- Randomly choses a `Zombie` `ZData` within a ZType data table.
---@param ZDataTable table  --Zombie Table to randomize
---@param ZData string      --Chosen data in ZType table
---@param current any       --Used to verify `current` from `Zombie` is not in table
---@return any              --Random choice within ZData
ZomboidForge.RandomizeTable = function(ZDataTable,ZData,current)
    --local ZombieTable = ZomboidForge.ZTypes[ZType]
    local ZDataTable_check = ZDataTable[ZData]; if not ZDataTable_check then return end
    local size = #ZDataTable_check

    local check = false
    for i = 1,size do
        if current == ZDataTable_check[i] then
            check = true
            break
        end
    end
    if not check then
        local rand = ZombRand(1,size)
        return ZDataTable_check[rand]
    end
    return false
end

local timeStatCheck = 500
-- Updates stats of `Zombie`.
-- Stats are checked and updated if needed 10 times. They are updated every `timeStatCheck` ticks.
--
-- Some stats can be checked like walktype or sight, those are verifiable stats and 
-- are not updated every check.
-- The other stats can't be checked so they are updated every checks, they are unverifiable stats.
--
-- Once every stats went through the 10 checks and are actually correct then
---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
---@param ZType integer     --Zombie Type ID
ZomboidForge.CheckZombieStats = function(zombie,ZType)
    -- get zombie info
    local trueID = ZomboidForge.pID(zombie)
    local nonPersistentZData = ZomboidForge.PersistentOutfitID[trueID]

    -- GlobalCheck, if true then stats are already checked
    if nonPersistentZData.GlobalCheck then return end

    -- counter to update
    local UpdateCounter = nonPersistentZData.UpdateCounter
    if UpdateCounter and UpdateCounter > 0 then
        -- start counting
        nonPersistentZData.UpdateCounter = UpdateCounter - 1
        return
    elseif UpdateCounter then
        -- back to start
        nonPersistentZData.UpdateCounter = timeStatCheck
    elseif not UpdateCounter then
        -- to have a first check instantly
        nonPersistentZData.UpdateCounter = -1
    end

    -- get info if stat already checked for each stats
    -- else initialize it
    local statChecked = nonPersistentZData.statChecked
    if not statChecked then
        nonPersistentZData.statChecked = {}
        statChecked = nonPersistentZData.statChecked
    end

    -- multiCheck for unverifiable stats
    local multiCheck = nonPersistentZData.multiCheck
    if not multiCheck then
        nonPersistentZData.multiCheck = {}
        multiCheck = nonPersistentZData.multiCheck
    end

    -- for every stats available to update
    local ZombieTable = ZomboidForge.ZTypes[ZType]
    local ready = 0
    for k,_ in pairs(ZomboidForge.Stats) do
        if not statChecked[k] then
            local classField = ZomboidForge.Stats[k].classField
            -- verifiable stats
            if classField then
                local stat = zombie[classField]
                local value = ZomboidForge.Stats[k].returnValue[ZombieTable[k]]
                if k == "walktype" and ZombieTable[k] and ZombieTable[k] == 4 then
                    if zombie:isCanWalk() then
                        zombie:setCanWalk(false)
                    end
                    if not zombie:isProne() then
                        zombie:setFallOnFront(true)
                    end
                    if not zombie:isCrawling() then
                        zombie:toggleCrawling()
                    end
                end
                if not (stat == value) and ZombieTable[k] then
                    local sandboxOption = ZomboidForge.Stats[k].setSandboxOption
                    getSandboxOptions():set(sandboxOption,ZombieTable[k])
                    zombie:makeInactive(true)
                    zombie:makeInactive(false)
                end

            -- unverifiable stats
            elseif not classField then
                local sandboxOption = ZomboidForge.Stats[k].setSandboxOption
                getSandboxOptions():set(sandboxOption,ZombieTable[k])
                zombie:makeInactive(true)
                zombie:makeInactive(false)

            end
            -- do multiCheck
            if not multiCheck[k] then
                multiCheck[k] = 0
            end
            if multiCheck[k] and multiCheck[k] < 10 then
                multiCheck[k] = multiCheck[k] + 1
            elseif multiCheck[k] and multiCheck[k] == 10 then
                statChecked[k] = true
                ready = ready + 1
            end
        else
            ready = ready + 1
        end
    end

    -- if every stats are checked
    if ready == 8 then
        nonPersistentZData.GlobalCheck = true
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
---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
ZomboidForge.ZombieUpdate = function(zombie)
    -- get persistentOutfitID aka trueID
    local trueID = ZomboidForge.pID(zombie)

    -- persistentData
    local ZFModData = ModData.getOrCreate("ZomboidForge")

    -- get nonPersistentZData checked at every save reload and initialize it if not already done
    local nonPersistentZData = ZomboidForge.PersistentOutfitID[trueID]
    if not nonPersistentZData then
        ZomboidForge.PersistentOutfitID[trueID] = {}
        nonPersistentZData = ZomboidForge.PersistentOutfitID[trueID]
    end

    -- check if zombie IsInitialized
    if not nonPersistentZData.IsInitialized then
        nonPersistentZData.IsInitialized = false
        ZomboidForge.ZombieInitiliaze(zombie)
        return
    end

    local PersistentZData = ZFModData.PersistentZData[trueID]
    local ZType = PersistentZData.ZType
    local ZombieTable = ZomboidForge.ZTypes[ZType]

    if not ZombieTable then return end

    -- set zombie data
    local IsDataSet = nonPersistentZData.IsDataSet
    if not IsDataSet then
        ZomboidForge.SetZombieData(zombie,ZType)
    end

    -- run custom behavior functions for this zombie
    for i = 1,#ZombieTable.customBehavior do
        ZomboidForge[ZombieTable.customBehavior[i]](zombie,ZType)
    end

    -- run zombie attack functions
    if zombie:isAttacking() then
        ZomboidForge.ZombieAttack(zombie,ZType)
    end
end

--- `Zombie` attacking `Player`. 
-- 
-- Trigger `funcattack` of `Zombie` depending on `ZType`.
---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
---@param ZType integer     --Zombie Type ID
ZomboidForge.ZombieAttack = function(zombie,ZType)
    local player = zombie:getTarget()
    if player and player:isCharacter() then
        local ZombieTable = ZomboidForge.ZTypes[ZType]
        ZomboidForge.ShowZombieName(player, zombie)
        if ZombieTable.funcattack then
            for i=1,#ZombieTable.funcattack do
                ZomboidForge[ZombieTable.funcattack[i]](player,zombie,ZType)
            end
        end
    end
end

--- `Player` attacking `Zombie`. 
-- 
-- Trigger `funconhit` of `Zombie` depending on `ZType`.
--
-- Handles the custom HP of zombies and apply custom damage depending on the customDamage function.
---@param attacker IsoPlayer|IsoLivingCharacter|IsoGameCharacter|IsoMovingObject|IsoObject
---@param victim IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
ZomboidForge.OnHit = function(attacker, victim, handWeapon, damage)
    if victim:isZombie() then
        local trueID = ZomboidForge.pID(victim)
        local ZFModData = ModData.getOrCreate("ZomboidForge")
        local PersistentZData = ZFModData.PersistentZData[trueID]

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
        if ZombieTable.HP and not (ZombieTable.HP == 1) then
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
---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
ZomboidForge.OnDeath = function(zombie)
    local trueID = ZomboidForge.pID(zombie)
    local ZFModData = ModData.getOrCreate("ZomboidForge")
    local PersistentZData = ZFModData.PersistentZData[trueID]
    
    local ZType = PersistentZData.ZType
    -- initialize zombie type
    -- only a security for mods that insta-kill zombies on spawn
    if not ZType then
        ZomboidForge.ZombieInitiliaze(zombie)
        return
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
    ZomboidForge.PersistentOutfitID[trueID] = nil
end

--#region Tools

-- Based on Chuck's work. Outputs the `trueID` of a `Zombie`.
-- Thx to the help of Shurutsue.
--
-- When hat of a zombie falls off, it changes it's `persistentOutfitID` but those two `pIDs` are linked.
-- This allows to access the trueID of a `Zombie` (the original pID with hat) from both pIDs.
-- The trueID is stored to improve performances and is accessed from the fallen hat pID and the pID sent
-- through this function detects if it's the trueID.
---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
---@return integer trueID
ZomboidForge.pID = function(zombie)
    local pID = zombie:getPersistentOutfitID()

    local found = ZomboidForge.TrueID[pID] and pID or ZomboidForge.HatFallen[pID]
    if found then 
        --zombie:addLineChatElement("pID = "..tostring(pID)..
        --    "\npID table = "..tostring(found))
        return found
    end

    local bits = string.split(string.reverse(Long.toUnsignedString(pID, 2)), "")
    while #bits < 16 do bits[#bits+1] = 0 end

    -- trueID
    bits[16] = 0
    local trueID = Long.parseUnsignedLong(string.reverse(table.concat(bits, "")), 2)
    ZomboidForge.TrueID[trueID] = true

    -- hatFallenID
    bits[16] = 1
    ZomboidForge.HatFallen[Long.parseUnsignedLong(string.reverse(table.concat(bits, "")), 2)] = trueID


    ZomboidForge.TrueID[pID] = trueID
    return trueID
end

--#endregion

--#region Nametag handling

-- Shows `Zombie` name with this command, can be triggered anytime. 
-- Can also be called outside of the framework by addons.
---@param player IsoPlayer|IsoLivingCharacter|IsoGameCharacter|IsoMovingObject|IsoObject
---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
ZomboidForge.ShowZombieName = function(player,zombie)
	if (ZombieForgeOptions and ZombieForgeOptions.NameTag)or(ZombieForgeOptions==nil) then
		if player:isLocalPlayer() then
            local trueID = ZomboidForge.pID(zombie)
			ZomboidForge.ShowNametag[trueID] = {zombie,100}
		end
    end
end

-- Get `Zombie` on `Player` cursor.
-- If `Zombie` found then update `ShowZombieName`.
---@param player IsoPlayer|IsoLivingCharacter|IsoGameCharacter|IsoMovingObject|IsoObject
ZomboidForge.GetZombieOnPlayerMouse = function(player)
	if (ZombieForgeOptions and ZombieForgeOptions.NameTag)or(ZombieForgeOptions==nil) then
		if player:isLocalPlayer() and player:isAiming() then
			local playerX = player:getX()
			local playerY = player:getY()
			local playerZ = player:getZ()
			local mouseX, mouseY = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), 0);
			local targetMouseX = mouseX+1.5;
			local targetMouseY = mouseY+1.5;
			local direction = (math.atan2(targetMouseY-playerY, targetMouseX-playerX));

			local feetDirection = player:getDir():toAngle();
			if feetDirection < 2 then
				feetDirection = -(feetDirection+(math.pi*0.5))
			else
				feetDirection = (math.pi*2)-(feetDirection+(math.pi*0.5))
			end
			if math.cos(direction - feetDirection) < math.cos(67.5) then
				if math.sin(direction - feetDirection) < 0 then
					direction = feetDirection - (math.pi/4)
				else
					direction = feetDirection + (math.pi/4)
				end
			end --Avoids an aiming angle pointing behind the person
			local cell = getWorld():getCell();
			local square = cell:getGridSquare(math.floor(targetMouseX), math.floor(targetMouseY), playerZ);
			if playerZ > 0 then
				for i=math.floor(playerZ), 1, -1 do
					square = cell:getGridSquare(math.floor(mouseX+1.5)+(i*3), math.floor(mouseY+1.5)+(i*3), i);
					if square and square:isSolidFloor() then
						targetMouseX = mouseX+1.5+i;
						targetMouseY = mouseY+1.5+i;
						break
					end
				end
			end
			if square then
				local movingObjects = square:getMovingObjects();
				if (movingObjects ~= nil) then
					for i=0, movingObjects:size()-1 do
						local zombie = movingObjects:get(i)
						if zombie and instanceof(zombie, "IsoZombie") then
                            local trueID = ZomboidForge.pID(zombie)
                            local ZFModData = ModData.getOrCreate("ZomboidForge")
                            local PersistentZData = ZFModData.PersistentZData[trueID]

                            local ZType = PersistentZData.ZType
							if ZomboidForge.ZTypes[ZType] and player:CanSee(zombie) then
								ZomboidForge.ShowNametag[trueID] = {zombie,100}
							end
						end
					end
				end
			end
		end
	end
end


-- Updates zombie tag showing for each players. 
-- Could probably be improved upon since currently the behavior is not perfect in multiplayer.
-- Specifically with `ShowZombieName`.
ZomboidForge.UpdateNametag = function()
	for trueID,ZData in pairs(ZomboidForge.ShowNametag) do
		local zombie = ZData[1]
		local interval = ZData[2]

        --local trueID = ZomboidForge.pID(zombie)
        local ZFModData = ModData.getOrCreate("ZomboidForge")
        local PersistentZData = ZFModData.PersistentZData[trueID]
        
        if not PersistentZData then return end
        local ZType = PersistentZData.ZType
        local ZombieTable = ZomboidForge.ZTypes[ZType]
		if interval>0 and ZomboidForge.ZTypes and ZombieTable then
			local player = getPlayer()
			if zombie:isAlive() and player:CanSee(zombie) then
				zombie:getModData().userName = zombie:getModData().userName or TextDrawObject.new()
				zombie:getModData().userName:setDefaultColors(ZombieTable.color[1]/255,ZombieTable.color[2]/255,ZombieTable.color[3]/255,interval/100)
				zombie:getModData().userName:setOutlineColors(ZombieTable.outline[1]/255,ZombieTable.outline[2]/255,ZombieTable.outline[3]/255,interval/100)
				zombie:getModData().userName:ReadString(UIFont.Small, getText(ZombieTable.name), -1)
				local sx = IsoUtils.XToScreen(zombie:getX(), zombie:getY(), zombie:getZ(), 0);
				local sy = IsoUtils.YToScreen(zombie:getX(), zombie:getY(), zombie:getZ(), 0);
				sx = sx - IsoCamera.getOffX() - zombie:getOffsetX();
				sy = sy - IsoCamera.getOffY() - zombie:getOffsetY();
				if ZombieForgeOptions and ZombieForgeOptions.TextHeight then
					sy = sy - 228 + 48*ZombieForgeOptions.TextHeight + 20*ZombieForgeOptions.HeightOffset
				else
					sy = sy - 180
				end
				sx = sx / getCore():getZoom(0)
				sy = sy / getCore():getZoom(0)
				sy = sy - zombie:getModData().userName:getHeight()
				zombie:getModData().userName:AddBatchedDraw(sx, sy, true)
				ZomboidForge.ShowNametag[trueID][2] = ZomboidForge.ShowNametag[trueID][2] - 1
			else
				ZomboidForge.ShowNametag[trueID] = nil
			end
		end
	end
end

--#endregion

--return ZomboidForge