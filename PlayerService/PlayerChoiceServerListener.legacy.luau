local RoomChoiceEvent = game.ReplicatedStorage.Remotes.RoomChoiceEvent
local CashOutEvent = game.ReplicatedStorage.Remotes.CashOutEvent
local ContinueEvent = game.ReplicatedStorage.Remotes.ContinueEvent
local EndGameEvent = game.ReplicatedStorage.Remotes.EndGameEvent

local RoomGenerator = require(game.ServerScriptService.RoomSystem.RoomGenerator)
local RoomCatalog = require(game.ServerScriptService.RoomSystem.RoomCatalog)
local PlayerProgressService = require(game.ServerScriptService.PlayerService.PlayerProgressService)

local function ClaimReward(player)
	print("reward claimed")	
end

local function ReturnToSpawn(player)
	player.Character.HumanoidRootPart.CFrame = game.Workspace.SpawnLocation.CFrame + Vector3.new(0, 2, 0)
end

local function CashOut(player)
	ReturnToSpawn(player)
	ClaimReward(player)
	CashOutEvent:FireClient(player)
	
	EndGameEvent:FireClient(player)
end

local function Continue(player)
	local roomIndex = PlayerProgressService:GetRoomIndex(player)
	local roomModel = RoomGenerator.GetRoomIndex(roomIndex)
	
	if roomModel then
		local roomType = roomModel:GetAttribute("RoomType")
		
		local roomModule = RoomCatalog[roomType]
		if roomModule then
			local RoomClass = require(roomModule)
			local room = RoomClass.new()
			room:StartRoom(roomIndex, player)
		end
	end
	
	ContinueEvent:FireClient(player)
end

CashOutEvent.OnServerEvent:Connect(CashOut)
ContinueEvent.OnServerEvent:Connect(Continue)