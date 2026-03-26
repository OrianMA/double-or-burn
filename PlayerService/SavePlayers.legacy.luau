local Players = game:GetService("Players")
local DataManager = require(script.Parent.DataManager)

Players.PlayerAdded:Connect(function(player)
	DataManager:InitPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
	DataManager:Save(player)
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		DataManager:Save(player)
	end
end)