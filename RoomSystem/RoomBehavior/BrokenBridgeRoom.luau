local BaseRoom = require(script.Parent.BaseRoom)
local PlayerStatsService = require(game.ServerScriptService.PlayerService.PlayerStatsService)

local BrokenBridgeRoom = {}
BrokenBridgeRoom.__index = BrokenBridgeRoom
setmetatable(BrokenBridgeRoom, {__index = BaseRoom})

local WinPercentage = {
	90,
	80,
	68,
	56,
	44,
	32,
	24,
	18,
	13,
	9,
	6,
	3,
	1
}

nextSpawnPointPath = {
	"SafeZone",
	"NextRoomPoint"
}

function BrokenBridgeRoom.new()
	local self = BaseRoom.new()
	setmetatable(self, BrokenBridgeRoom)

	self.SpawnPointPath = nextSpawnPointPath -- spécifique à cette room
	return self
end

function BrokenBridgeRoom:StartRoom(index, player)
	BaseRoom:StartRoom(index, player)
	local isWin = PlayerStatsService:TriggerChanceRoom(player, self:GetWinPercentage(index, player))
	print("BrokenBridge, win:", self:GetWinPercentage(index, player), "%, isWin:", isWin)
end

-- Override de GetWinPercentage pour utiliser les valeurs spécifiques de BrokenBridgeRoom
function BrokenBridgeRoom:GetWinPercentage(index, player)
	return WinPercentage[index] + PlayerStatsService:GetAdditionnalChance(player)
end

-- Si vous voulez appeler la fonction parent (BaseRoom) depuis une autre fonction :
-- Utilisez BaseRoom.GetWinPercentage(self, index) ou self:GetWinPercentage(index)

return BrokenBridgeRoom
