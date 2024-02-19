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
        classField = "speedType",
        returnValue = {
            [1] = 1, -- sprinter
            [2] = 2, -- fast shambler
            [3] = 3, -- shambler
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

    --- UNDEFINED STATS
    
    -- defines strength of zombie
    -- undefined
    strength = {
        setSandboxOption = "ZombieLore.Strength",
        --classField = "strength",
        returnValue = {
            [1] = 1,
            [2] = 2,
            [3] = 3,
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

    -- defines the memory setting
    memory = {
        setSandboxOption = "ZombieLore.Memory",
        --classField = missing,
        returnValue = {
            [1] = 1, -- can open doors
            [2] = 2, -- navigate 
            [3] = 3, -- basic navigate
            --[4] = ZomboidForge.coinFlip(),
        },
    },
}

ZomboidForge.coinFlip = function()
    -- Generate a random number between 0 and 1
    local randomNumber = ZombRand(2)

    -- Map the random number to either -1 or 1
    if randomNumber < 0.5 then
        return -1
    else
        return 1
    end
end
ZomboidForge.ClassFields = {
    walktype = "speedType",
    sight = "sight",
    hearing = "hearing",
}
ZomboidForge.SandboxOptions = {
    walktype = "ZombieLore.Speed",
    strength = "ZombieLore.Strength",
    toughness = "ZombieLore.Toughness",
    cognition = "ZombieLore.Cognition",
    transmission = "ZombieLore.Transmission",
    memory = "ZombieLore.Memory",
    sight = "ZombieLore.Sight",
    hearing = "ZombieLore.Hearing",
}

local javaFieldGetter = {}
javaFieldGetter.trackedFields = {}
---[classField] = placement

--- OnLoad function to initialize the mod
ZomboidForge.OnLoad = function()
    -- initialize ModData
    local ZombieData = ModData.getOrCreate("ZomboidForge")
    if not ZombieData.ZombieInfo then
        ZombieData.ZombieInfo = {}
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
    local persistentOutfitID = zombie:getPersistentOutfitID()
    local ZombieData = ModData.getOrCreate("ZomboidForge")
    ZombieData.ZombieInfo[persistentOutfitID] = {}
    local ZombieInfo = ZombieData.ZombieInfo[persistentOutfitID]

    -- attribute zombie type
    if not ZombieInfo.ZType then
        local rand = ZombRand(ZomboidForge.TotalChance)
        for i = 1,ZomboidForge.TotalZTypes do
            rand = rand - ZomboidForge.ZTypes[i].chance
            if rand <= 0 then
                ZombieInfo.ZType = i
                --zombie:getModData()['ZType'] = i
                break
            end
        end
    end

    local ZType = ZombieInfo.ZType
    local ZombieTable = ZomboidForge.ZTypes[ZType]
    
    -- become reanimated zombie
    if ZombieTable.reanimatedPlayer and not zombie:isReanimatedPlayer() then
        zombie:setReanimatedPlayer(true)
    end

    -- set zombie age
    if zombie:getAge() > -1 then	
		-- TLOU_updateZombieClothing(zombie,ZType)
		zombie:setAge(-1)
	end

    -- update stats
    ZomboidForge.SetZombieStats(zombie,ZType)
end

--- Initialize a zombie type
ZomboidForge.SetZombieStats = function(zombie,ZType)
    local ZombieTable = ZomboidForge.ZTypes[ZType]

    -- set walktype
    if ZombieTable.walktype and ZombieTable.walktype ~= 4 then
        getSandboxOptions():set("ZombieLore.Speed", ZombieTable.walktype)
        --[[
        if zombie:isCrawling() then
            zombie:toggleCrawling()
        end
        ]]
        zombie:setCanWalk(true)
        zombie:makeInactive(true)
        zombie:makeInactive(false)
    elseif ZombieTable.walktype == 4 then
        if zombie:isCanWalk() then
            zombie:setCanWalk(false)
        end
        if not zombie:isProne() then
            zombie:setFallOnFront(true)
        end
        if not zombie:isCrawling() then
            zombie:toggleCrawling()
        end
        zombie:makeInactive(true)
        zombie:makeInactive(false)
    end

    -- visual look
    if ZombieTable.skeleton and not zombie:isSkeleton() then
        zombie:setSkeleton(true)
    end
    if ZombieTable.hair then
        zombie:getHumanVisual():setHairModel("")
    end
    if ZombieTable.beard then
        zombie:getHumanVisual():setBeardModel("")
    end

    -- stats
    for k,v in pairs(ZomboidForge.SandboxOptions) do
        if ZombieTable[k] then
            getSandboxOptions():set(v,ZombieTable[k])
        end
    end
    --[[
    if ZombieTable.strength then
        getSandboxOptions():set("ZombieLore.Strength",ZombieTable.strength)
    end
    if ZombieTable.toughness then
        getSandboxOptions():set("ZombieLore.Toughness",ZombieTable.toughness)
    end
    if ZombieTable.cognition then
        getSandboxOptions():set("ZombieLore.Cognition",ZombieTable.cognition)
    end
    if ZombieTable.transmission then
        getSandboxOptions():set("ZombieLore.Transmission",ZombieTable.transmission)
    end
    if ZombieTable.memory then
        getSandboxOptions():set("ZombieLore.Memory",ZombieTable.memory)
    end
    if ZombieTable.sight then
        getSandboxOptions():set("ZombieLore.Sight",ZombieTable.sight)
    end
    if ZombieTable.hearing then
        getSandboxOptions():set("ZombieLore.Hearing",ZombieTable.hearing)
    end
    if ZombieTable.noteeth then
        zombie:setNoTeeth(ZombieTable.noteeth)
    end
    if ZombieTable.HP then
        zombie:setHealth(ZombieTable.HP)
    end
    ]]

    -- refresh stats
    zombie:DoZombieStats()

    -- refresh sandbox settings for this zombie
    zombie:makeInactive(true)
    zombie:makeInactive(false)
end

--- Main function:
-- meant to do every actions of a zombie
ZomboidForge.ZombieUpdate = function(zombie)
    --local ZType = zombie:getModData()['ZType']
    local persistentOutfitID = zombie:getPersistentOutfitID()
    local ZombieData = ModData.getOrCreate("ZomboidForge")

    -- initialize zombie type
    if not ZombieData.ZombieInfo[persistentOutfitID] or not ZombieData.ZombieInfo[persistentOutfitID].ZType then
        ZombieData.ZombieInfo[persistentOutfitID] = {}
        if not ZombieData.ZombieInfo[persistentOutfitID].ZType then
            ZomboidForge.ZombieInitiliaze(zombie)
            return
        end
    end
    
    local ZombieInfo = ZombieData.ZombieInfo[persistentOutfitID]

    --print(persistentOutfitID)
    local ZType = ZombieInfo.ZType
    local ZombieTable = ZomboidForge.ZTypes[ZType]

    if not ZombieTable then return end 

    -- set zombie clothing, very limited
    if #ZombieTable.outfit > 0 then
        ZomboidForge.ZombieOutfit(zombie,ZType)
    end

    --[[
    print(zombie.bRunning)
    print(zombie.speedType)
    print(zombie.walkVariant)
    print(zombie.SPEED_SPRINTER)
    print(zombie.SPEED_FAST_SHAMBLER)
    ]]

    --[[
    local classField = "public int zombie.characters.IsoZombie.speedType"
    local value = javaFieldGetter.getFieldValue(zombie,classField)
    print("speedType for this zombie")
    print(value)
    ]]

    --[[
    print("start")
    local fields = getmetatable(getmetatable(zombie).__index).fieldGetters
    for fieldName,getter in pairs(fields) do
        -- you can get the current value using this:
        local fieldVal = getter(zombie)
        print("fieldName: "..tostring(fieldName).." = "..tostring(fieldVal))
    end
    ]]

    -- update zombie stats
    ZomboidForge.CheckZombieStats(zombie,ZType)

    --print(ZomboidForge.coinFlip())
    --print(ZomboidForge.Stats.cognition.returnValue[4])

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

--- Check stats of zombie is set
ZomboidForge.CheckZombieStats = function(zombie,ZType)
    local ZombieTable = ZomboidForge.ZTypes[ZType]
    --[[
    for k,v in pairs(ZomboidForge.ClassFields) do
        --local stat = javaFieldGetter.getFieldValue(zombie,v)
        local stat = zombie[v]
        if not (stat == ZombieTable[k]) then
            --print("changing stats")
            local sandboxOption = ZomboidForge.SandboxOptions[k]
            getSandboxOptions():set(sandboxOption,ZombieTable[k])
            zombie:DoZombieStats()
            zombie:makeInactive(true)
            zombie:makeInactive(false)
        end
    end
    ]]

    for k,_ in pairs(ZomboidForge.Stats) do
        --local stat = javaFieldGetter.getFieldValue(zombie,v)
        local classField = ZomboidForge.Stats[k].classField
        if classField then
            local stat = zombie[classField]
            local value = ZomboidForge.Stats[k].returnValue[ZombieTable[k]]
            print(
                "stat name = "..tostring(k)..
                "    classFieldValue = "..tostring(stat)..
                "    returnValue = "..tostring(value))
            if not (stat == value) then
                print("updated")
                --print("changing stats")
                --local sandboxOption = ZomboidForge.SandboxOptions[k]
                local sandboxOption = ZomboidForge.Stats[k].setSandboxOption
                getSandboxOptions():set(sandboxOption,ZombieTable[k])
                zombie:DoZombieStats()
                zombie:makeInactive(true)
                zombie:makeInactive(false)
            end
        else
            local sandboxOption = ZomboidForge.Stats[k].setSandboxOption
            getSandboxOptions():set(sandboxOption,ZombieTable[k])
            zombie:DoZombieStats()
            zombie:makeInactive(true)
            zombie:makeInactive(false)
        end
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
        print(victim:getHealth())
        local persistentOutfitID = victim:getPersistentOutfitID()
        local ZombieData = ModData.getOrCreate("ZomboidForge")
        local ZombieInfo = ZombieData.ZombieInfo[persistentOutfitID]
        
        local ZType = ZombieInfo.ZType
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
    local persistentOutfitID = zombie:getPersistentOutfitID()
    local ZombieData = ModData.getOrCreate("ZomboidForge")
    local ZombieInfo = ZombieData.ZombieInfo[persistentOutfitID]
    
    local ZType = ZombieInfo.ZType
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

-- check outfit
ZomboidForge.ZombieOutfit = function(zombie,ZType)
    local ZombieTable = ZomboidForge.ZTypes[ZType]
    local outfits = ZombieTable.outfit; if not outfits then return end
    local sizeOutfits = #ZombieTable.outfit
    local currentOutfit = zombie:getOutfitName()

    local outfitCheck = false
    for i = 1,sizeOutfits do
        if currentOutfit == outfits[i] then
            outfitCheck = true
            break
        end
    end
    if not outfitCheck then
        local rand = ZombRand(1,sizeOutfits)
        zombie:dressInNamedOutfit(outfits[rand])
	    zombie:reloadOutfit()
        --ZomboidForge.SetZombieOutfit(zombie,ZType)
    end
end

--[[
-- set outfit
ZomboidForge.SetZombieOutfit = function(zombie,ZType)
    local ZombieTable = ZomboidForge.ZTypes[ZType]
    local outfits = ZombieTable.outfit; if not outfits then return end
    local sizeOutfits = #ZombieTable.outfit

    local rand = ZombRand(1,sizeOutfits)
    zombie:dressInNamedOutfit(outfits[rand])
	zombie:reloadOutfit()
end
]]

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
                            local persistentOutfitID = zombie:getPersistentOutfitID()
                            local ZombieData = ModData.getOrCreate("ZomboidForge")
                            local ZombieInfo = ZombieData.ZombieInfo[persistentOutfitID]
                            
                            local ZType = ZombieInfo.ZType
							if ZomboidForge.ZTypes[ZType] and player:CanSee(zombie) then
								local ZID = ZomboidForge.GetZombieID(zombie)
                                --[[
								if not ZomboidForge.ShowNametag[ZID] then
									TLOU_CheckZombieType(zombie,ZID,ModData.getOrCreate("CZList"))
								end
                                ]]
                                --ZomboidForge.ShowNametag[persistentOutfitID] = {zombie,100}
								ZomboidForge.ShowNametag[ZID] = {zombie,100}
							end
						end
					end
				end
			end
		end
	end
end

-- show zombie Nametag
ZomboidForge.UpdateNametag = function()
	for ZID,ZData in pairs(ZomboidForge.ShowNametag) do
		local zombie = ZData[1]
		local interval = ZData[2]

        local persistentOutfitID = zombie:getPersistentOutfitID()
        local ZombieData = ModData.getOrCreate("ZomboidForge")
        local ZombieInfo = ZombieData.ZombieInfo[persistentOutfitID]
        
        if not ZombieInfo then return end
        local ZType = ZombieInfo.ZType
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







--Example:  "public float zombie.inventory.types.HandWeapon.WeaponLength"
--          "public int zombie.characters.IsoZombie.speedType"
function javaFieldGetter.determineFieldPlacement(object, classField)
    --use the stored placement value for faster lookups
    if javaFieldGetter.trackedFields[classField] then return javaFieldGetter.trackedFields[classField] end
    
    local numClassFields = getNumClassFields(object)
    for i = 0, numClassFields - 1 do
        ---@type Field
        local javaField = getClassField(object, i)
        if javaField and tostring(javaField) == classField then
            javaFieldGetter.trackedFields[classField] = i
            return i
        end
    end
end

function javaFieldGetter.getFieldValue(object, classField)
    local fieldPlacement = javaFieldGetter.determineFieldPlacement(object, classField)
    local javaField = getClassField(object, fieldPlacement)
    local value = getClassFieldVal(object, javaField)
    --print("classField: "..tostring(classField).." = "..tostring(value))
    return value
end

--return ZomboidForge