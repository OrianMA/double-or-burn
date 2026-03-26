local RaceStartedEvent = game.ReplicatedStorage.Remotes.RaceStartedEvent
local RoomChoiceEvent = game.ReplicatedStorage.Remotes.RoomChoiceEvent
local EndGameEvent = game.ReplicatedStorage.Remotes.EndGameEvent
local WarningLavaRiseEvent = game.ReplicatedStorage.Remotes.WarningLavaRiseEvent

local RoomGenerator = require(script.Parent.RoomGenerator)
local RoomCatalog = require(script.Parent.RoomCatalog)
local PlayerProgressService = require(script.Parent.Parent.PlayerService.PlayerProgressService)
local LavaRise = require(game.ServerScriptService.LavaRise)

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

local PlayersRegistered = {}

local RoomManager = {}

function RoomManager.Init(player)
	RoomGenerator:Init()
end

local function DiscardPlayerFromRace(player)
	table.remove(PlayersRegistered, table.find(PlayersRegistered, player))
	LavaRise:UpdatePlayerNumber(RoomManager.GetPlayerLeft())
end

local function EndGame(player)
	PlayerProgressService:ClearRoomProgression(player)
	DiscardPlayerFromRace(player)
end

EndGameEvent.OnServerEvent:Connect(EndGame)


function RoomManager.EndRoomtrigger(player)
	PlayerProgressService:IncrementRoom(player)
	local reward = RoomManager.GetReward(player)
	local riskValue = RoomManager.GetRisk(player)
	local roomIndex = PlayerProgressService:GetRoomIndex(player)
	local nextRoomModel = RoomGenerator.GetRoomIndex(roomIndex + 1)
	local isFinalRoom = nextRoomModel == nil
	RoomChoiceEvent:FireClient(player, reward, riskValue, isFinalRoom)
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

function RoomManager.ResetRace(player)
	task.wait(RoomGenerator.ClearAll())
	RoomGenerator:CreateRace()
end

function RoomManager.RegisterPlayerFromRace(player)
	table.insert(PlayersRegistered, player)
end

function RoomManager.IsPlayerRegistered(player)
	return table.find(PlayersRegistered, player) ~= nil
end

function RoomManager.GetPlayerLeft()
	return #PlayersRegistered
end

function RoomManager.RiseLava()
	if #PlayersRegistered == 0 then return end
	
	for _, player in ipairs(PlayersRegistered) do
		WarningLavaRiseEvent:FireClient(player)
	end
	
	LavaRise:UpdatePlayerNumber(RoomManager.GetPlayerLeft())
	LavaRise:Rise()
end

return RoomManager
