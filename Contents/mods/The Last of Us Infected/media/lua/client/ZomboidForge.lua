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
    --for i = 1,ZomboidForge.TotalZTypes do
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
        }
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
---@param zombie        IsoZombie
ZomboidForge.ZombieInitiliaze = function(zombie)
    local trueID = ZomboidForge.pID(zombie)

    local ZFModData = ModData.getOrCreate("ZomboidForge")
    ZFModData.PersistentZData[trueID] = ZFModData.PersistentZData[trueID] or {}
    local PersistentZData = ZFModData.PersistentZData[trueID]
    if not PersistentZData then return end

    -- attribute zombie type if not set by weighted random
    local ZType = PersistentZData.ZType
    if not ZType or not ZomboidForge.ZTypes[ZType] then
        -- chose a random number based on max total weight
        local rand = ZombRand(ZomboidForge.TotalChance)

        -- test one by one each types and attribute if pass
        for testingZType,ZombieTable in pairs(ZomboidForge.ZTypes) do
            rand = rand - ZombieTable.chance
            if rand <= 0 then
                -- attribute a ZType to the zombie
                PersistentZData.ZType = testingZType

                ZomboidForge.ModData_Client2Server(
                    {
                        modData = "ZomboidForge",
                        category = "PersistentZData",
                        key = trueID,
                        data = {
                            ZType = testingZType,
                        },
                    }
                )
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

    ZomboidForge.NonPersistentZData[trueID].IsInitialized = true
end

local timeStatCheck = 500
--- Used to set the various data of a zombie, skipping the unneeded parts or already done. 
--
-- Order of data set:
--
--          `Zombie stats`
--          `Zombie outfit`
--          `Set Zombie to skeleton`
--          `Zombie hair`
--          `Zombie hair color`
--          `Zombie beard`
--          `Zombie beard color`
--          `HP`
--          `Zombie animation variable`
--
---@param zombie        IsoZombie
---@param ZType         integer|nil [opt] Zombie Type ID
ZomboidForge.SetZombieData = function(zombie,ZType)
    local trueID = ZomboidForge.pID(zombie)
    local nonPersistentZData = ZomboidForge.NonPersistentZData[trueID]

    -- if no ZType given, access it
    if not ZType then
        local PersistentZData = ModData.getOrCreate("ZomboidForge").PersistentZData[trueID]
        if not PersistentZData then return end
        ZType = PersistentZData.ZType
    end

    -- if still no ZType then skip again
    if not ZType or not nonPersistentZData then return end

    -- get ZType data
    local ZombieTable = ZomboidForge.ZTypes[ZType]
    -- update zombie stats
    if not nonPersistentZData.GlobalCheck then
        ZomboidForge.CheckZombieStats(zombie,ZType)
    end

    -- set zombie clothing
    if #ZombieTable.outfit > 0 then
        local currentOutfit = zombie:getOutfitName()
        local outfitChoice = ZomboidForge.RandomizeTable(ZombieTable,"outfit",currentOutfit)
        if outfitChoice then
            zombie:dressInNamedOutfit(outfitChoice)
	        zombie:reloadOutfit()
        end
    end

    --- update zombie visuals
    -- set to skeleton
    if ZombieTable.skeleton and not zombie:isSkeleton() then
        zombie:setSkeleton(true)
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
        local hairChoice = nil
        if ZDataTable[key] then
            hairChoice = ZomboidForge.RandomizeTable(ZDataTable,key,currentHair)
        end
        if hairChoice then
            zombieVisual:setHairModel(hairChoice)
            zombie:resetModel()
        end
    end

    -- set hair color
    if #ZombieTable.hairColor > 0 then
        local zombieVisual = zombie:getHumanVisual()
        local currentHairColor = zombieVisual:getHairColor()
        local hairColorChoice = ZomboidForge.RandomizeTable(ZombieTable,"hairColor",currentHairColor)
        if hairColorChoice then
            zombieVisual:setHairColor(hairColorChoice)
            zombie:resetModel()
        end
    end

    -- set beard if male
    if #ZombieTable.beard > 0 and not zombie:isFemale() then
        local zombieVisual = zombie:getHumanVisual()
        local currentBeard = zombieVisual:getBeardModel()
        local beardChoice = ZomboidForge.RandomizeTable(ZombieTable,"beard",currentBeard)
        if beardChoice then
            zombieVisual:setBeardModel(beardChoice)
            zombie:resetModel()
        end
    end

    -- set beard color if male
    if #ZombieTable.beardColor > 0 and not zombie:isFemale() then
        local zombieVisual = zombie:getHumanVisual()
        local currentBeardColor = zombieVisual:getHairColor()
        local beardColorChoice = ZomboidForge.RandomizeTable(ZombieTable,"beardColor",currentBeardColor)
        if beardColorChoice or true then
            zombieVisual:setHairColor(beardColorChoice)
            zombie:resetModel()
        end
    end

    -- set zombie HP extremely high to make sure it doesn't get oneshoted if it has custom
    -- HP, handled via the attack functions
    if ZombieTable.HP and ZombieTable.HP ~= 1 and zombie:isAlive() then
        if zombie:getHealth() ~= 1000 then
            zombie:setHealth(1000)
        end
    end

    -- custom animation variable
    if ZombieTable.animationVariable then
        if not zombie:getVariableBoolean(ZombieTable.animationVariable) then
            zombie:setVariable(ZombieTable.animationVariable,'true')
            if isClient() then
                sendClientCommand('AnimationHandler', 'SetAnimationVariable', {animationVariable = ZombieTable.animationVariable, zombie = zombie:getOnlineID()})
            end
        end
    end
end

--- Randomly choses a `Zombie` `ZData` within a ZType data table if current is not already in the table.
---@param ZDataTable    table       --Zombie Table to randomize
---@param ZData         string      --Chosen data in ZType table
---@param current       any         --[opt] Used to verify `current` from `Zombie` is not in table
---@return any                      --Random choice within ZData
ZomboidForge.RandomizeTable = function(ZDataTable,ZData,current)
    local ZDataTable_get = ZDataTable[ZData]; if not ZDataTable_get then return end
    local size = #ZDataTable_get

    local check = false
    if current then
        for i = 1,size do
            if current == ZDataTable_get[i] then
                check = true
                break
            end
        end
    end
    if not check then
        return ZDataTable_get[ZombRand(1,size)]
    end
    return false
end

-- Updates stats of `Zombie`.
-- Stats are checked and updated if needed 10 times. They are updated every `timeStatCheck` ticks.
--
-- Some stats can be checked like walktype or sight, those are verifiable stats and 
-- are not updated every check.
-- The other stats can't be checked so they are updated every checks, they are unverifiable stats.
--
-- Once every stats went through the 10 checks and are actually correct then
---@param zombie        IsoZombie
---@param ZType         integer     --Zombie Type ID
ZomboidForge.CheckZombieStats = function(zombie,ZType)
    -- get zombie info
    local trueID = ZomboidForge.pID(zombie)
    local nonPersistentZData = ZomboidForge.NonPersistentZData[trueID]

    -- GlobalCheck, if true then stats are already checked
    if nonPersistentZData.GlobalCheck then return end

    -- get info if stat already checked for each stats
    -- else initialize it
    local statChecked = nonPersistentZData.statChecked
    if not statChecked then
        nonPersistentZData.statChecked = {}
        statChecked = nonPersistentZData.statChecked
    end

    -- for every stats available to update
    local ZombieTable = ZomboidForge.ZTypes[ZType]
    for k,_ in pairs(ZomboidForge.Stats) do
        local classField = ZomboidForge.Stats[k].classField
        -- verifiable stats
        if classField then
            -- for walktype, 4 = crawler
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

            -- verify current stats are the correct one, else update them
            local stat = zombie[classField]
            local value = ZomboidForge.Stats[k].returnValue[ZombieTable[k]]
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
    end

    -- update multiCheck counter for each stats
    local multiCheck = nonPersistentZData.multiCheck
    if not multiCheck then
        multiCheck = 0
    end
    if multiCheck >= 10 then
        -- stop checking stats for this zombie
        nonPersistentZData.GlobalCheck = true
        nonPersistentZData.multiCheck = nil
    else
        -- increment multiCheck counter
        multiCheck = multiCheck + 1
        nonPersistentZData.multiCheck = multiCheck
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
    -- get persistentOutfitID aka trueID
    local trueID = ZomboidForge.pID(zombie)

    -- persistentData
    local ZFModData = ModData.getOrCreate("ZomboidForge")

    -- get nonPersistentZData checked at every save reload and initialize it if not already done
    local nonPersistentZData = ZomboidForge.NonPersistentZData[trueID]
    if not nonPersistentZData then
        ZomboidForge.NonPersistentZData[trueID] = {}
        nonPersistentZData = ZomboidForge.NonPersistentZData[trueID]
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

                ZomboidForge.ModData_Client2Server(
                    {
                        modData = "ZomboidForge",
                        category = "PersistentZData",
                        key = trueID,
                        data = {
                            HP = HP,
                        },
                    }
                )
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

    ZomboidForge.ModData_Client2Server(
        {
            modData = "ZomboidForge",
            category = "PersistentZData",
            key = trueID,
            data = nil,
        }
    )

    ZomboidForge.NonPersistentZData[trueID] = nil
end

--#region Tools

-- Based on Chuck's and I work. Outputs the `trueID` of a `Zombie`.
-- Thx to the help of Shurutsue, Albion and probably others.
--
-- When hat of a zombie falls off, it changes it's `persistentOutfitID` but those two `pIDs` are linked.
-- This allows to access the trueID of a `Zombie` (the original pID with hat) from both pIDs.
-- The trueID is stored to improve performances and is accessed from the fallen hat pID and the pID sent
-- through this function detects if it's the trueID.
---@param zombie        IsoZombie
---@return integer      trueID
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


local zombieList
ZomboidForge.zeroTick = 0
-- Global counter that is used by the framework to delay updates on specific stuff like stats but can be used
-- by other addons to delay update some stuff.
--
-- Added to `OnTick`
--
-- The part updating one zombie per tick was made by Albion.
---@param tick          int
ZomboidForge.OnTick = function(tick)
    -- Update counter
    ZomboidForge.counterUpdater()

    if not zombieList then
        zombieList = getPlayer():getCell():getZombieList()
    end

    -- Update zombie stats
    local zombieIndex = tick - ZomboidForge.zeroTick
    if zombieList:size() > zombieIndex then
        local zombie = zombieList:get(zombieIndex)
        ZomboidForge.SetZombieData(zombie,nil)
    else
        ZomboidForge.zeroTick = tick + 1
    end
end

-- Global counter that is used by the framework to delay updates on specific stuff like stats but can be used
-- by other addons to delay update some stuff.
-- Added to OnTick
ZomboidForge.counterUpdater = function()
    ZomboidForge.counter = ZomboidForge.counter - 1
    if ZomboidForge.counter < 0 then
        ZomboidForge.counter = SandboxVars.ZomboidForge.tickUpdater
    end
end
--#endregion

--#region Nametag handling

-- Shows `Zombie` name with this command, can be triggered anytime. 
-- Can also be called outside of the framework by addons.
---@param player        IsoPlayer
---@param zombie        IsoZombie
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
---@param player        IsoPlayer
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
						if zombie and instanceof(zombie, "IsoZombie") and zombie:isAlive() then
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
-- Could probably be improved upon since currently the behavior is possibly not perfect in multiplayer.
-- Specifically with `ShowZombieName`.
--
-- From CDDA Zombies
ZomboidForge.UpdateNametag = function()
	for trueID,ZData in pairs(ZomboidForge.ShowNametag) do
		local zombie = ZData[1]
		local interval = ZData[2]

        --local trueID = ZomboidForge.pID(zombie)
        local ZFModData = ModData.getOrCreate("ZomboidForge")
        local PersistentZData = ZFModData.PersistentZData[trueID]

        if not PersistentZData then
            ZomboidForge.ShowNametag[trueID] = nil
            return
        end

        local ZType = PersistentZData.ZType
        local ZombieTable = ZomboidForge.ZTypes[ZType]
		if interval>0 and ZombieTable then
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
        else
            ZomboidForge.ShowNametag[trueID] = nil
		end
	end
end

--#endregion
