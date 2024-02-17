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
        ZomboidForge.TotalChance = ZomboidForge.TotalChance + ZomboidForge.ZTypes[i].chance
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
            
            print("setting name")
            local name = ZomboidForge.ZTypes[i].name
            print(name)
            break
        end
    end

    local ZType = zombie:getModData()['ZType']

    -- update stats
    ZomboidForge.SetZombieStats(zombie,ZType)
end

--- Initialize a zombie type
ZomboidForge.SetZombieStats = function(zombie,ZType)
    local ZombieTable = ZomboidForge.ZTypes[ZType]
    local TLOU = ModData.getOrCreate("CZ")
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

    if ZombieTable.skeleton and not zombie:isSkeleton() then
        zombie:setSkeleton(true)
        zombie:getHumanVisual():setHairModel("")
        zombie:getHumanVisual():setBeardModel("")
    end

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
end

--- Main function:
-- meant to do every actions of a zombie
ZomboidForge.ZombieUpdate = function(zombie)

    local ZType = zombie:getModData()['ZType']
    -- initialize zombie type
    if zombie:getModData()['ZType'] == nil then
        ZomboidForge.ZombieInitiliaze(zombie)
        return
    end

    local ZombieTable = ZomboidForge.ZTypes[ZType]

    -- run onZombieUpdate functions for this ZType
    for i = 1,#ZombieTable.onZombieUpdate do
        local ZombieTable = ZomboidForge.ZTypes[i]
        ZomboidForge[ZombieTable.onZombieUpdate[i]]()
    end

    -- zombie attack
    if zombie:isAttacking() then
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
end

Events.OnZombieUpdate.Add(ZomboidForge.ZombieUpdate)

--- player attacking zombie
ZomboidForge.OnHit = function(attacker, victim, handWeapon, damage)
    if victim:isZombie() then
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

--- Tools
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

Events.OnTick.Add(ZomboidForge.UpdateNametag)

return ZomboidForge