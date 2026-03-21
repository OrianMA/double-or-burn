local BaseRoom = {}
BaseRoom.__index = BaseRoom

local description = "Template description"
local winPercentage = {
	100,100,100,100,100,
	100,100,100,100,100,
	100,100,100,
}

local baseSpawnPointPath = {
	"Room",
	"SafeZone",
	"NextRoomPoint"
}

-- Fonctions statiques accessibles via le module
local RoomBehavior = {}

function RoomBehavior.GetDescription()
	return description
end

function RoomBehavior.GetWinPercentage(roomIndex)
	return winPercentage[roomIndex]
end

-- Exporter RoomBehavior pour accès externe
BaseRoom.RoomBehavior = RoomBehavior

function BaseRoom.new()
	local self = setmetatable({}, BaseRoom)
	self.SpawnPointPath = baseSpawnPointPath -- default
	return self
end

function BaseRoom:GetWinPercentage(roomIndex)
	return winPercentage[roomIndex]
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

function BaseRoom:StartRoom()
	
	-- Override in derived classes
end

return BaseRoom
