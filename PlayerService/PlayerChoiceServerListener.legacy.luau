local RoomChoiceEvent = game.ReplicatedStorage.Remotes.RoomChoiceEvent
local CashOutEvent = game.ReplicatedStorage.Remotes.CashOutEvent
local ContinueEvent = game.ReplicatedStorage.Remotes.ContinueEvent
local EndGameEvent = game.ReplicatedStorage.Remotes.EndGameEvent

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
	ContinueEvent:FireClient(player)
end

CashOutEvent.OnServerEvent:Connect(CashOut)
ContinueEvent.OnServerEvent:Connect(Continue)