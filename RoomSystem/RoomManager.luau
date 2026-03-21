local RaceStartedEvent = game.ReplicatedStorage.Remotes.RaceStartedEvent
local RoomChoiceEvent = game.ReplicatedStorage.Remotes.RoomChoiceEvent
local EndGameEvent = game.ReplicatedStorage.Remotes.EndGameEvent

local RoomGenerator = require(script.Parent.RoomGenerator)
local RoomCatalog = require(script.Parent.RoomCatalog)
local PlayerProgressService = require(script.Parent.Parent.PlayerService.PlayerProgressService)
local AuraCoinRewards = {
	1,
	2,
	4,
	8,
	20,
	125,
	250,
	500,
	1250,
	6000,
	12000,
	30000,
	67000
}


local RoomManager = {}

function RoomManager.Init(player)
	print("init")
	RoomGenerator.Init()
end

local function EndGame(player)
	PlayerProgressService:ClearRoomProgression(player)
end

EndGameEvent.OnServerEvent:Connect(EndGame)


function RoomManager.EndRoomtrigger(player)
	PlayerProgressService:IncrementRoom(player)
	local reward = RoomManager.GetReward(player)
	local riskValue = RoomManager.GetRisk(player)
	RoomChoiceEvent:FireClient(player, reward, riskValue)
end

function RoomManager.GetReward(player)
	local roomIndex = PlayerProgressService:GetRoomIndex(player)
	return AuraCoinRewards[roomIndex] or 0
end

function RoomManager.GetRisk(player)
	local roomIndex = PlayerProgressService:GetRoomIndex(player)
	local nextRoomModel = RoomGenerator.GetRoomIndex(roomIndex)
	
	-- Récupérer le type de room et le module correspondant
	local roomType = nextRoomModel:GetAttribute("RoomType")
	local roomModule = RoomCatalog[roomType]
	
	if roomModule then
		local RoomClass = require(roomModule)
		return RoomClass:GetWinPercentage(roomIndex, player)
	end
	
	return 0
end

return RoomManager
