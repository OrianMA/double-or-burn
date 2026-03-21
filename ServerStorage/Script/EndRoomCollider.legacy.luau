local event = game.ReplicatedStorage.Remotes.RoomChoiceEvent
local EndGameEvent = game.ReplicatedStorage.Remotes.EndGameEvent
local RoomManager = require(game.ServerScriptService.RoomSystem.RoomManager)

script.Parent.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid") and script.Parent.CanTouch == true then
		script.Parent.CanTouch = false
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			RoomManager.EndRoomtrigger(player)
		end
	end
end)

local function EndGame()
	script.Parent.CanTouch = true
end

EndGameEvent.OnServerEvent:Connect(EndGame)
