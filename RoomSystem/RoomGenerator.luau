local RoomCatalog = require(script.Parent.RoomCatalog)

local roomParent = workspace.Rooms
local firstRoom = workspace.FirstRoom
local roomPoolSize = 13
local roomPool = {}
local lastInstantiateRoom

--room prefabs--
local safeRoom = game.ServerStorage.Room.SafeRoom
local BrokenBridgeRoom = game.ServerStorage.Room.BrokenBridgeRoom
local roomPrefabs = {
	safeRoom,
	BrokenBridgeRoom
}

local RoomGenerator = {}

local function GetChildrenNextPositionRoom(instantiateRoom)

	local roomType = instantiateRoom:GetAttribute("RoomType")
	assert(roomType, "RoomType manquant sur la room")

	local moduleScript = RoomCatalog[roomType]
	assert(moduleScript, "RoomType inconnu : " .. tostring(roomType))

	local RoomClass = require(moduleScript)
	local room = RoomClass.new()

	local nextRoomPoint = room:GetNextSpawnPointPosition(instantiateRoom)
	return nextRoomPoint.CFrame
end

local function CreateRoom(previousRoom)
	local randomRoom = roomPrefabs[math.random(1, #roomPrefabs)]
	local instantiateRoom = randomRoom:Clone()
	instantiateRoom.Parent = roomParent
	instantiateRoom:PivotTo(GetChildrenNextPositionRoom(previousRoom))
	lastInstantiateRoom = instantiateRoom
	
	table.insert(roomPool, instantiateRoom)
end

function RoomGenerator.ClearAll()
	for _, room in ipairs(roomPool) do
		room:Destroy()
	end
	table.clear(roomPool)
end

function RoomGenerator.Init()
	CreateRoom(firstRoom)
	
	for i = 1, roomPoolSize-2 do
		CreateRoom(lastInstantiateRoom)
	end
end

function RoomGenerator.GetRoomIndex(index)
	local room = roomPool[index]
	return room
end



return RoomGenerator