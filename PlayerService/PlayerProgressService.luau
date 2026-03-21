local Players = game:GetService("Players")

local PlayerProgressService = {}
PlayerProgressService.__index = PlayerProgressService

local progress = {} -- [player] = { roomIndex = number, bestRoom = number }

function PlayerProgressService:InitPlayer(player)
	progress[player] = {
		roomIndex = 0,
		bestRoom = 0,
	}
end

function PlayerProgressService:RemovePlayer(player)
	progress[player] = nil
end

function PlayerProgressService:GetRoomIndex(player)
	local p = progress[player]
	return p and p.roomIndex or 0
end

function PlayerProgressService:SetRoomIndex(player, value)
	local p = progress[player]
	if not p then return end
	value = math.max(1, math.floor(value))

	p.roomIndex = value
	p.bestRoom = math.max(p.bestRoom, value)
end

function PlayerProgressService:IncrementRoom(player)
	self:SetRoomIndex(player, self:GetRoomIndex(player) + 1)
end

function PlayerProgressService:ClearRoomProgression(player)
	self:SetRoomIndex(player, 0)
	print(PlayerProgressService:GetRoomIndex(player))
end

-- wiring Players
Players.PlayerAdded:Connect(function(player)
	PlayerProgressService:InitPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
	PlayerProgressService:RemovePlayer(player)
end)

return PlayerProgressService