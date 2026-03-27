local EndGameEvent = game.ReplicatedStorage.Remotes.EndGameEvent
local Players = game:GetService("Players")
local EndRoomTriggerManager = {}

function EndRoomTriggerManager.SetupRoomTrigger(room, onPlayerTriggered)
	local trigger = room:WaitForChild("SafeZone"):WaitForChild("RoomTrigger")
	local triggeredPlayers = {}

	trigger.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then return end
		
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then return end
		
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end
		
		if triggeredPlayers[player] then return end
		
		triggeredPlayers[player] = true
		onPlayerTriggered(player)
	end)

	EndGameEvent.OnServerEvent:Connect(function(player)
		if player then triggeredPlayers[player] = nil end
	end)

	Players.PlayerRemoving:Connect(function(player)
		triggeredPlayers[player] = nil
	end)
end

return EndRoomTriggerManager