local Players = game:GetService("Players")

local PlayerStatsService = {}
PlayerStatsService.__index = PlayerStatsService

local stats = {}

function PlayerStatsService:InitPlayer(player)
	stats[player] = {
		additionnalChance = 0,
	}
end

Players.PlayerAdded:Connect(function(player)
	PlayerStatsService:InitPlayer(player)
end)

function PlayerStatsService:TriggerChanceRoom(player, chance)
	if (math.random(0, 100) > chance + stats[player].additionnalChance) then
		return false
	end
	return true
end

function PlayerStatsService:AddAdditionnalChance(player, chance)
	stats[player].additionnalChance = math.max(0, math.min(100, stats[player].additionnalChance + chance))
end

function PlayerStatsService:GetAdditionnalChance(player)
	return stats[player].additionnalChance
end

return PlayerStatsService