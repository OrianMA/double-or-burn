local RoomCatalog = require(script.Parent.RoomCatalog)
local EndRoomTriggerManager = require(game.ServerScriptService.RoomSystem.EndRoomTriggerManager)

local roomParent = workspace.Rooms
local firstRoom = workspace.Rooms.FirstRoom
local roomPoolSize = 13
local roomPool = {}
local lastInstantiateRoom

--room prefabs--
local safeRoom = game.ServerStorage.Room.SafeRoom
local BrokenBridgeRoom = game.ServerStorage.Room.BrokenBridgeRoom
local NumbersPrefab = game.ServerStorage.Numbers
local roomPrefabs = {
	safeRoom,
	BrokenBridgeRoom
}

local RoomGenerator = {}

local NumberSpawnPointPath = {
	"SafeZone",
	"NumbersSpawnPoint"
}

local function InitNumberRoom(instantiateRoom, roomIndex)
	local current = instantiateRoom
	for _, name in ipairs(NumberSpawnPointPath) do
		current = current:WaitForChild(name)
	end
	
	local currentNumbers = NumbersPrefab:Clone()
	currentNumbers.Parent = current
	currentNumbers:PivotTo(current.WorldCFrame)
	
	local numberClass = require(currentNumbers.RoomNumbersBehavior)
	numberClass:Init(roomIndex)
end

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

	-- Setup du trigger avec le callback passé par RoomManager
	if onRoomEndCallback then
		EndRoomTriggerManager.SetupRoomTrigger(instantiateRoom, onRoomEndCallback)
	end

	table.insert(roomPool, instantiateRoom)
end

-- Appelé par RoomManager pour injecter le callback
function RoomGenerator.SetOnRoomEndCallback(callback)
	onRoomEndCallback = callback
end

function RoomGenerator.ClearAll()
	for _, room in ipairs(roomPool) do
		room:Destroy()
		task.wait(0.2)
	end
	table.clear(roomPool)
end

function RoomGenerator:CreateRace()
	CreateRoom(firstRoom)
	InitNumberRoom(lastInstantiateRoom, 2)

	for i = 1, roomPoolSize-2 do
		CreateRoom(lastInstantiateRoom)
		InitNumberRoom(lastInstantiateRoom, i+2)
		task.wait(0.2)
	end
end

function RoomGenerator:Init()
	if onRoomEndCallback then
		EndRoomTriggerManager.SetupRoomTrigger(firstRoom, onRoomEndCallback)
	end
	
	InitNumberRoom(firstRoom, 1)
	self:CreateRace()
end

function RoomGenerator.GetRoomIndex(index)
	local room = roomPool[index]
	return room
end



return RoomGenerator