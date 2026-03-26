local DataManager = require(game.ServerScriptService.PlayerService.DataManager)

local BaseRoom = {}
BaseRoom.__index = BaseRoom

local description = "Template description"


local baseSpawnPointPath = {
	"SafeZone",
	"NextRoomPoint"
}

-- Fonctions statiques accessibles via le module
local RoomBehavior = {}

BaseRoom.winPercentage = {
	100,100,100,100,100,
	100,100,100,100,100,
	100,100,100,
}

function RoomBehavior.GetDescription()
	return description
end

function RoomBehavior.GetWinPercentage(roomIndex, player)
	local additionnalChance = DataManager:Get(player, "chance")
	return RoomBehavior.winPercentage[roomIndex] + additionnalChance
end

-- Exporter RoomBehavior pour accès externe
BaseRoom.RoomBehavior = RoomBehavior

function BaseRoom.new()
	local self = setmetatable({}, BaseRoom)
	self.SpawnPointPath = baseSpawnPointPath -- default
	return self
end

function BaseRoom:GetWinPercentage(roomIndex, player)
	local additionnalChance = DataManager:Get(player, "chance")
	return BaseRoom.winPercentage[roomIndex] + additionnalChance
end

function BaseRoom:GetSpawnPointPath()
	return self.SpawnPointPath
end

function BaseRoom:GetNextSpawnPointPosition(roomModel)
	local current = roomModel
	for _, name in ipairs(self.SpawnPointPath) do
		current = current:WaitForChild(name)
	end
	return current
end

function BaseRoom:Destroy()
	if self.Model then
		self.Model:Destroy()
		self.Model = nil
	end
end

function BaseRoom:StartRoom(index, player, roomModel)
	if (math.random(0, 100) > self:GetWinPercentage(index, player)) then
		return false
	end
	return true
	-- Override in derived classes
end

return BaseRoom
