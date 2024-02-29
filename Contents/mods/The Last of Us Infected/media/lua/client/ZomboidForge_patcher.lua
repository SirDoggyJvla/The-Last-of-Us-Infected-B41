--- import module from ZomboidForge
local ZomboidForge = require "ZomboidForge_module"

ZomboidForge.Patcher = {}
ZomboidForge.Patcher.DebugContextMenu = {}
ZomboidForge.Patcher.AdminContextMenu = {}

ZomboidForge.Patcher.DebugContextMenu.OnRemoveAllZombies = DebugContextMenu.OnRemoveAllZombies
ZomboidForge.Patcher.DebugContextMenu.OnRemoveAllZombiesClient = DebugContextMenu.OnRemoveAllZombiesClient

ZomboidForge.Patcher.AdminContextMenu.OnRemoveAllZombiesClient = AdminContextMenu.OnRemoveAllZombiesClient


-- Remove all emitters of every zombies getting deleted.
ZomboidForge.Patcher.RemoveAllEmitters = function()
    local zombies = getCell():getObjectList()
    for i=zombies:size()-1,0,-1 do
         local zombie = zombies:get(i)
         if instanceof(zombie, "IsoZombie") then
              zombie:getEmitter():stopAll()
         end
    end
end

function DebugContextMenu.OnRemoveAllZombies(zombie)
    ZomboidForge.Patcher.RemoveAllEmitters()

    ZomboidForge.Patcher.DebugContextMenu.OnRemoveAllZombies(zombie)
end
function DebugContextMenu.OnRemoveAllZombiesClient(zombie)
    ZomboidForge.Patcher.RemoveAllEmitters()

    ZomboidForge.Patcher.DebugContextMenu.OnRemoveAllZombiesClient(zombie)
end
function AdminContextMenu.OnRemoveAllZombiesClient(zombie)
    ZomboidForge.Patcher.RemoveAllEmitters()

    ZomboidForge.Patcher.AdminContextMenu.OnRemoveAllZombiesClient(zombie)
end


ZomboidForge.Patcher.ISSpawnHordeUI = {}

ZomboidForge.Patcher.ISSpawnHordeUI.onRemoveZombies = ISSpawnHordeUI.onRemoveZombies

-- Remove emitters of zombies in radius getting deleted.
function ISSpawnHordeUI:onRemoveZombies()
	local radius = self:getRadius() + 1;
	for x=self.selectX-radius, self.selectX + radius do
		for y=self.selectY-radius, self.selectY + radius do
			local sq = getCell():getGridSquare(x,y,self.selectZ);
			if sq then
				for i=sq:getMovingObjects():size()-1,0,-1 do
					local testZed = sq:getMovingObjects():get(i);
					if instanceof(testZed, "IsoZombie") then
                        testZed:getEmitter():stopAll()
					end
				end
			end
		end
	end

    ZomboidForge.Patcher.ISSpawnHordeUI.onRemoveZombies(self)
end