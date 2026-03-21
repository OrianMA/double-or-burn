local EndGameEvent = game.ReplicatedStorage.Remotes.EndGameEvent
local lava = script.Parent

lava.Touched:Connect(function(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then return end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		EndGameEvent:FireClient(game.Players:GetPlayerFromCharacter(hit.Parent))
		humanoid.Health = 0
	end
end)