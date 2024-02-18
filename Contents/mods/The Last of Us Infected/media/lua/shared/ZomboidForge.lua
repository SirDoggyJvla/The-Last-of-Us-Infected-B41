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
local ZomboidForge = {}

-- initialize variables within ZomboidForge
ZomboidForge.ZTypes = {}
ZomboidForge.ShowNametag = {}

--- OnLoad function to initialize the mod
ZomboidForge.OnLoad = function()
    ZomboidForge.TotalZTypes = #ZomboidForge.ZTypes

    ZomboidForge.TotalChance = 0
    for i = 1,ZomboidForge.TotalZTypes do
        ZombieTable = ZomboidForge.ZTypes[i]
        if not ZombieTable.spawn then
            ZombieTable.chance = 0
        end
        ZomboidForge.TotalChance = ZomboidForge.TotalChance + ZombieTable.chance
    end

    
    if SandboxVars.ZomboidForge.nametags then
        Events.OnTick.Add(ZomboidForge.UpdateNametag)
    end
    
end

Events.OnLoad.Add(ZomboidForge.OnLoad)


--- Initialize a zombie type
ZomboidForge.ZombieInitiliaze = function(zombie)
    -- attribute zombie type
    local rand = ZombRand(ZomboidForge.TotalChance)
    for i = 1,ZomboidForge.TotalZTypes do
        rand = rand - ZomboidForge.ZTypes[i].chance
        if rand <= 0 then
            zombie:getModData()['ZType'] = i
            break
        end
    end

    local ZType = zombie:getModData()['ZType']

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
        if zombie:isCrawling() then
            zombie:toggleCrawling()
        end
        zombie:setCanWalk(true)
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
    zombie:DoZombieStats()

    -- refresh stats
    zombie:makeInactive(true)
    zombie:makeInactive(false)
    
end

--- Main function:
-- meant to do every actions of a zombie
ZomboidForge.ZombieUpdate = function(zombie)
    local ZType = zombie:getModData()['ZType']
    -- initialize zombie type
    if not ZType then
        ZomboidForge.ZombieInitiliaze(zombie)
        return
    end
    local persistentOutfitID = zombie:getPersistentOutfitID()

    --print(persistentOutfitID)

    local ZombieTable = ZomboidForge.ZTypes[ZType]

    -- set zombie clothing, very limited
    if #ZombieTable.outfit > 0 then
        ZomboidForge.ZombieOutfit(zombie,ZType)
    end

    -- check zombie health
    if not zombie:getModData()['checkHP'] then
        ZomboidForge.CheckZombieHealth(zombie,ZType)
    end

    -- run custom behavior functions for this zombie
    for i = 1,#ZombieTable.customBehavior do
        ZomboidForge[ZombieTable.customBehavior[i]](zombie,ZType)
    end

    -- zombie attack
    if zombie:isAttacking() then
        ZomboidForge.ZombieAttack(zombie,ZType)
    end
end

Events.OnZombieUpdate.Add(ZomboidForge.ZombieUpdate)

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
        local ZType = victim:getModData()['ZType']
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

Events.OnWeaponHitCharacter.Add(ZomboidForge.OnHit)

--- OnDeath functions
ZomboidForge.OnDeath = function(zombie)
    local ZType = zombie:getModData()['ZType']
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

Events.OnZombieDead.Add(ZomboidForge.OnDeath)

--- Tools

-- check outfit
ZomboidForge.ZombieOutfit = function(zombie,ZType)
    local ZombieTable = ZomboidForge.ZTypes[ZType]
    local outfits = ZombieTable.outfit; if not outfits then return end
    local sizeOutfits = #ZombieTable.outfit
    local currentOutfit = zombie:getOutfitName()

    local outfitCheck = false
    --[[
    for i = 1,sizeOutfits do
        if currentOutfit == outfits[i] then
            outfitCheck = true
            break
        end
    end
    ]]
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
                            local ZType = zombie:getModData()['ZType']
							if ZomboidForge.ZTypes[ZType] and player:CanSee(zombie) then
								local ZID = ZomboidForge.GetZombieID(zombie)
                                --[[
								if not ZomboidForge.ShowNametag[ZID] then
									TLOU_CheckZombieType(zombie,ZID,ModData.getOrCreate("CZList"))
								end
                                ]]
								ZomboidForge.ShowNametag[ZID] = {zombie,100}
							end
						end
					end
				end
			end
		end
	end
end

Events.OnPlayerUpdate.Add(ZomboidForge.GetZombieOnPlayerMouse)

-- show zombie Nametag
ZomboidForge.UpdateNametag = function()
    local TLOU=ModData.getOrCreate("CZ")
	for ZID,ZData in pairs(ZomboidForge.ShowNametag) do
		local zombie = ZData[1]
		local interval = ZData[2]

        local ZType = zombie:getModData()['ZType']
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

return ZomboidForge