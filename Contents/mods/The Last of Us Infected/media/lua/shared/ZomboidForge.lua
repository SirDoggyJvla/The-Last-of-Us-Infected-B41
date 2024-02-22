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
local ipairs = ipairs -- ipair function
local ZombRand = ZombRand -- java function
local print = print -- print function

--- main module for use in storing informations and pass along other files
--local ZomboidForge = {}

--- import module from ZomboidForge
local ZomboidForge = require "ZomboidForge_module"

-- initialize variables within ZomboidForge
--ZomboidForge.ZTypes = ZomboidForge.ZTypes or {}
--ZomboidForge.ShowNametag = ZomboidForge.ShowNametag or {}
--[[
ZomboidForge.ClassFields = {
    walktype = "public int zombie.characters.IsoZombie.speedType",
}
]]

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
    ZomboidForge.TotalZTypes = #ZomboidForge.ZTypes

    -- calculate total chance
    ZomboidForge.TotalChance = 0
    for i = 1,ZomboidForge.TotalZTypes do
        ZombieTable = ZomboidForge.ZTypes[i]
        if not ZombieTable.spawn then
            ZombieTable.chance = 0
        end
        ZomboidForge.TotalChance = ZomboidForge.TotalChance + ZombieTable.chance
    end
end


--- Initialize a zombie type
ZomboidForge.ZombieInitiliaze = function(zombie)
    local trueID = ZomboidForge.pID(zombie)

    local ZFModData = ModData.getOrCreate("ZomboidForge")
    ZFModData.PersistentZData[trueID] = ZFModData.PersistentZData[trueID] or {}
    local PersistentZData = ZFModData.PersistentZData[trueID]

    -- attribute zombie type if not set
    if not PersistentZData.ZType then
        local rand = ZombRand(ZomboidForge.TotalChance)
        for i = 1,ZomboidForge.TotalZTypes do
            rand = rand - ZomboidForge.ZTypes[i].chance
            if rand <= 0 then
                PersistentZData.ZType = i
                --zombie:getModData()['ZType'] = i
                break
            end
        end
    end

    local ZType = PersistentZData.ZType
    local ZombieTable = ZomboidForge.ZTypes[ZType]

    -- makes sure stats get updated
    local nonPersistentZData = ZomboidForge.PersistentOutfitID[trueID]
    nonPersistentZData.StatCheck = {}


    -- become reanimated zombie
    if ZombieTable.reanimatedPlayer and not zombie:isReanimatedPlayer() then
        zombie:setReanimatedPlayer(true)
    end

    -- set zombie age
    if zombie:getAge() > -1 then	
		zombie:setAge(-1)
	end

    ZomboidForge.PersistentOutfitID[trueID].IsInitialized = true
end

--- Updates visual, stats etc if those aren't set already
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
        local outfitChoice = ZomboidForge.RandomizeTable(zombie,ZType,"outfit",currentOutfit)
        if outfitChoice then
            local old_trueID = trueID
            zombie:dressInNamedOutfit(outfitChoice)
	        zombie:reloadOutfit()
            trueID = ZomboidForge.pID(zombie)
            if not (old_trueID == trueID) then
                print("trueID was changed")
                print("old = "..old_trueID)
                print("new = "..trueID)
            end
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
    if #ZombieTable.hair > 0 then
        local zombieVisual = zombie:getHumanVisual()
        local currentHair = zombieVisual:getHairModel()
        local hairChoice = ZomboidForge.RandomizeTable(zombie,ZType,"hair",currentHair)
        if hairChoice then
            zombieVisual:setHairModel(hairChoice)
        else
            IsSet = IsSet + 1
        end
    else
        IsSet = IsSet + 1
    end

    -- set beard
    if #ZombieTable.beard > 0 then
        local zombieVisual = zombie:getHumanVisual()
        local currentBeard = zombieVisual:getBeardModel()
        local beardChoice = ZomboidForge.RandomizeTable(zombie,ZType,"beard",currentBeard)
        if beardChoice then
            zombieVisual:setBeardModel(beardChoice)
        else
            IsSet = IsSet + 1
        end
    else
        IsSet = IsSet + 1
    end

    -- update IsDataSet
    if IsSet == 5 then
        nonPersistentZData.IsDataSet = true
    end
end

--- Initialize a zombie type
ZomboidForge.RandomizeTable = function(zombie,ZType,ZData,current)
    local ZombieTable = ZomboidForge.ZTypes[ZType]
    local ZDataTable = ZombieTable[ZData]; if not ZDataTable then return end
    local size = #ZDataTable

    local check = false
    for i = 1,size do
        if current == ZDataTable[i] then
            check = true
            break
        end
    end
    if not check then
        local rand = ZombRand(1,size)
        return ZDataTable[rand]
    else
        return false
    end
end

local timeStatCheck = 500
--- Check stats of zombie is set
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
            -- unverifiable stats
            elseif not classField then
                local sandboxOption = ZomboidForge.Stats[k].setSandboxOption
                getSandboxOptions():set(sandboxOption,ZombieTable[k])
                zombie:makeInactive(true)
                zombie:makeInactive(false)

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
-- meant to do every actions of a zombie
ZomboidForge.ZombieUpdate = function(zombie)
    -- get persistentOutfitID aka trueID
    local trueID = ZomboidForge.pID(zombie)

    -- persistentData
    local ZFModData = ModData.getOrCreate("ZomboidForge")

    --print("trueID = "..trueID)
    -- get nonPersistentZData checked at every save reload and initialize it if not already done
    local nonPersistentZData = ZomboidForge.PersistentOutfitID[trueID]
    if not nonPersistentZData then
        ZomboidForge.PersistentOutfitID[trueID] = {}
        nonPersistentZData = ZomboidForge.PersistentOutfitID[trueID]
    end

    -- check if zombie IsInitialized
    local IsInitialized = nonPersistentZData.IsInitialized
    if not IsInitialized then
        ZomboidForge.ZombieInitiliaze(zombie)
        return
    end
    local PersistentZData = ZFModData.PersistentZData[trueID]

    -- do trueID change for outfit changing

    local ZType = PersistentZData.ZType
    local ZombieTable = ZomboidForge.ZTypes[ZType]

    if not ZombieTable then return end

    -- set zombie data
    local IsDataSet = nonPersistentZData.IsDataSet
    if not IsDataSet then
        ZomboidForge.SetZombieData(zombie,ZType)
    end

    -- check zombie health
    if not zombie:getModData()['checkHP'] then
        ZomboidForge.CheckZombieHealth(zombie,ZType)
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

--- Check HP of zombie is set
ZomboidForge.CheckZombieHealth = function(zombie,ZType)
    local ZombieTable = ZomboidForge.ZTypes[ZType]
    if zombie:getHealth() ~= ZombieTable.HP then
        zombie:setHealth(ZombieTable.HP)
    end
    zombie:getModData()['checkHP'] = true
end

--- Zombie attacking player, trigger funcattack
ZomboidForge.ZombieAttack = function(zombie,ZType)
    local player = zombie:getTarget()
    if player and player:isCharacter() then
        ZomboidForge.ShowZombieName(player, zombie,ZType)
        if ZombieTable.funcattack then
            for i=1,#ZombieTable.funcattack do
                ZomboidForge[ZombieTable.funcattack[i]](player,zombie,ZType)
            end
        end
    end
end

--- player attacking zombie, trigger funconhit
ZomboidForge.OnHit = function(attacker, victim, handWeapon, damage)
    if victim:isZombie() then
        --print(victim:getHealth())
        local trueID = ZomboidForge.pID(victim)
        --print("trueID on hat lose = "..trueID)
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
            ZomboidForge.ShowZombieName(attacker, victim, ZType)
        end

    --player was just hit, not zombie
    --elseif victim:isPlayer() then
    end
end

--- OnDeath functions
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
end

--- Tools

--- Bitwise stuff from Chuck
-- https://discord.com/channels/908422782554107904/908459714248048730/1209705754517573752
-- https://stackoverflow.com/questions/5977654/how-do-i-use-the-bitwise-operator-xor-in-lua
ZomboidForge.bit = {}

function ZomboidForge.bit.Or(a,b)
    local p,c=1,0
    while a+b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>0 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

function ZomboidForge.bit.And(a,b)
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

function ZomboidForge.bit.Not(n)
    local p,c=1,0
    while n>0 do
        local r=n%2
        if r<1 then c=c+p end
        n,p=(n-r)/2,p*2
    end
    return c
end

-- based on Chuck's work
ZomboidForge.pID = function(zombie)
    local pID = zombie:getPersistentOutfitID()
    local bit = ZomboidForge.bit
    local pID_new = 0
    if pID < 0 then
        pID_new = bit.Not(-pID) + 1
    else
        pID_new = pID
    end

    local found = ZomboidForge.TrueID[pID]
    if found then return found end
    -- store bit.hat
    ZomboidForge.bit.hat = ZomboidForge.bit.hat or bit.Not(32768)
    local bitHat = ZomboidForge.bit.hat

    local trueID = bit.And(pID_new,bitHat)
    --local hatID = (trueID~=pID_new and pID_new) or bit.Or(pID_new,32768)

    print("pID = "..pID.."   trueID = "..trueID)

    ZomboidForge.TrueID[pID] = trueID
    return trueID
end

-- get Zombie ID
ZomboidForge.GetZombieID = function(zombie)
	if zombie and zombie:isZombie() then
		local id
		if isClient() or isServer() then
			id = zombie:getOnlineID()
		else
			id = zombie:getID()
		end
		return id
	else
		return 0
	end
end

-- show zombie name
ZomboidForge.ShowZombieName = function(player,zombie,ZType)
    local ZombieTable = ZomboidForge.ZTypes[ZType]
	if (ZombieForgeOptions and ZombieForgeOptions.NameTag)or(ZombieForgeOptions==nil) then
		if player:isLocalPlayer() then
			ZomboidForge.ShowNametag[ZomboidForge.GetZombieID(zombie)] = {zombie,100}
		end
    end
end

-- get nametag zombie 
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
								local ZID = ZomboidForge.GetZombieID(zombie)
                                --[[
								if not ZomboidForge.ShowNametag[ZID] then
									TLOU_CheckZombieType(zombie,ZID,ModData.getOrCreate("CZList"))
								end
                                ]]
                                --ZomboidForge.ShowNametag[trueID] = {zombie,100}
								ZomboidForge.ShowNametag[ZID] = {zombie,100}
							end
						end
					end
				end
			end
		end
	end
end

-- show zombie Nametag on player update
ZomboidForge.UpdateNametag = function()
	for ZID,ZData in pairs(ZomboidForge.ShowNametag) do
		local zombie = ZData[1]
		local interval = ZData[2]

        local trueID = ZomboidForge.pID(zombie)
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
				ZomboidForge.ShowNametag[ZID][2] = ZomboidForge.ShowNametag[ZID][2] - 1
			else
				ZomboidForge.ShowNametag[ZID] = nil
			end
		end
	end
end

--return ZomboidForge