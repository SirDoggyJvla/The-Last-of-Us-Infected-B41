--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

The Clicker behavior is written in this file

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
local TLOU_infected = require "TLOU_infected"

-- localy initialize mod data
local TLOU_ModData = ModData.getOrCreate("TLOU_Infected")
local function initTLOU_ModData()
	TLOU_ModData = ModData.getOrCreate("TLOU_Infected")
end
Events.OnInitGlobalModData.Remove(initTLOU_ModData)
Events.OnInitGlobalModData.Add(initTLOU_ModData)


-- clicker attacks a player
function ZomboidForge.ClickerAttack(ZType,player,zombie)
	if player and player:isAlive() then
		--clicker grabs player
		if SandboxVars.TLOU_infected.GrabbyClickers and not player:isGodMod() then
			player:setSlowFactor(1)
			player:setSlowTimer(1)
		end

		-- kill player if oneshot clickers
		if SandboxVars.TLOU_infected.OneShotClickers then
			if player:hasHitReaction() and not player:isGodMod() then
				--player:setDeathDragDown(true)
				player:Kill(zombie)
			end
		end
	end
end

-- Replace fungi hat clothing with fungi hat food type on a `Clicker`'s death.
---@param zombie 		IsoZombie
---@param _		 		string   	--Zombie Type ID
ZomboidForge.OnClickerDeath = function(zombie,_)
	-- add fungi hat food type to inventory
	local inventory = zombie:getInventory()
	inventory:AddItems("Hat_Fungi_Loot",1)
end

-- Set `Clicker` sounds.
---@param zombie 		IsoZombie
---@param _		 		string   	--Zombie Type ID
ZomboidForge.SetClickerSounds = function(zombie,_)
	if not zombie:getEmitter():isPlaying("Zombie/Voice/FemaleC")then
		zombie:getEmitter():stopAll()
		zombie:getEmitter():playVocals("Zombie/Voice/FemaleC")
	end
end

--#region Custom behavior: `SetClickerClothing`

-- clothing priority to replace
TLOU_infected.ClothingPriority = {
	["Hat"] = 1,
	["Mask"] = 2,
	["Eyes"] = 3,
	["LeftEye"] = 4,
	["RightEye"] = 5,
	["Nose"] = 6,
	["BellyButton"] = 7,
	["Right_MiddleFinge"] = 8,
	["Left_MiddleFinger"] = 9,
	["Right_RingFinger"] = 10,
	["Left_RingFinger"] = 11,
	["Ears"] = 12,
	["EarTop"] = 13,
	["Necklace"] = 14,
	["Necklace_Long"] = 15,
	["UnderwearTop"] = 16,
	["UnderwearBottom"] = 17,
	["UnderwearExtra1"] = 18,
	["UnderwearExtra2"] = 19,
	["Underwear"] = 20,
	["Socks"] = 21,
	["RightWrist"] = 22,
	["LeftWrist"] = 23,
	["Tail"] = 24,

	["Hands"] = 25,
	["Belt"] = 26,
	["BeltExtra"] = 27,
	["AmmoStrap"] = 28,
	["Scarf"] = 29,
	["Neck"] = 30,
	["TorsoExtra"] = 31,
	["TankTop"] = 32,
	["Tshirt"] = 33,
	["ShortSleeveShirt"] = 34,
	["Shirt"] = 35,
	["Sweater"] = 36,
	["TorsoExtraVest"] = 37,
	["Pants"] = 38,
	["Skirt"] = 39,
	["Torso1Legs1"] = 40,
	["Legs1"] = 41,
	["Shoes"] = 42,
	["Jacket"] = 43,
}

-- Set clicker clothing by visually replacing one of its clothing based on the priority list of clothings to replace.
---@param zombie 		IsoZombie
---@param _		 		string   	--Zombie Type ID
ZomboidForge.SetClickerClothing = function(zombie,_)
	-- get clothing visuals from zombie
	local visual = zombie:getItemVisuals()
	if not visual then return end

	-- scroll through every clothing and replace it
	local hasHat_Fungi = false
	if visual:size() > 0 then
		local priority = 100
		local itemReset = nil
		for i = 0, visual:size()-1 do
			local item = visual:get(i)
			if not item then
				break
			end
			local bodyLocation = item:getScriptItem():getBodyLocation()
			local priorityTest = TLOU_infected.ClothingPriority[bodyLocation]
			if item:getItemType() == "Base.Hat_Fungi" then
				hasHat_Fungi = true
				break
			elseif priorityTest and priorityTest < priority then
				-- if not, then add one to the item
				priority = priorityTest
				itemReset = item
				hasHat_Fungi = false
			end
		end
		if not hasHat_Fungi and itemReset then
			itemReset:setItemType("Base.Hat_Fungi")
			itemReset:setClothingItemName("Hat_Fungi")
			zombie:resetModel()
		end

	-- if no visuals were found then add a visual item which is the Hat Fungi
	else
		local itemVisual = ItemVisual.new()
		itemVisual:setItemType("Base.Hat_Fungi")
		itemVisual:setClothingItemName("Hat_Fungi")
		visual:add(itemVisual)

		zombie:resetModel()
	end
end

--#endregion

--#region Custom behavior: `ClickerAgro`

-- Manage Clicker agro to change their animation when 
-- they run after a player.
---@param zombie 		IsoZombie
---@param ZType 		string   	     --Zombie Type ID
ZomboidForge.ClickerAgro = function(zombie,ZType)
	local target = zombie:getTarget()
	if target and not zombie:getVariableBoolean("ClickerAgro") then
		zombie:setVariable("ClickerAgro",'true')
	elseif not target and zombie:getVariableBoolean("ClickerAgro") then
		zombie:setVariable("ClickerAgro",'false')
	end
end
--#endregion


-- custom targeting of Clickers to make them attack other zombies when blind
--[[

if storeZombie and storeZombie ~= zombie and zombie:getTarget() ~= storeZombie then
	zombie:setTarget(storeZombie)
	zombie:setAttackedBy(storeZombie)
	print("setting target")
end
storeZombie = zombie
zombie:addLineChatElement(tostring(zombie:getTarget()))
]]