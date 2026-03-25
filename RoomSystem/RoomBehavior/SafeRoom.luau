local BaseRoom = require(script.Parent.BaseRoom)

local SafeRoom = {}
SafeRoom.__index = SafeRoom
setmetatable(SafeRoom, {__index = BaseRoom})

local WinPercentage = {
	100,100,100,100,100,
	100,100,100,100,100,
	100,100,100
}

local baseSpawnPointPath = {
	"SafeZone",
	"NextRoomPoint"
}


function SafeRoom.new()
	local self = BaseRoom.new()
	setmetatable(self, SafeRoom)

	self.SpawnPointPath = baseSpawnPointPath -- spécifique à cette room
	return self
end

function SafeRoom:GetWinPercentage(index)
	return WinPercentage[index]
end



return SafeRoom
