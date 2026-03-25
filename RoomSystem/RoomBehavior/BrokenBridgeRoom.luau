local BaseRoom = require(script.Parent.BaseRoom)
local PlayerStatsService = require(game.ServerScriptService.PlayerService.PlayerStatsService)
local TweenService = game:GetService("TweenService")

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

local breakablePart = {}

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

function BrokenBridgeRoom:StartRoom(index, player, roomModel)
	BaseRoom:StartRoom(index, player)
	local isWin = PlayerStatsService:TriggerChanceRoom(player, self:GetWinPercentage(index, player))
	print(roomModel)
	print("BrokenBridge, win:", self:GetWinPercentage(index, player), "%, isWin:", isWin)
	
	if isWin == false then
		spawn(function()
			BreakBridge(roomModel)
		end)
	end
end

-- Override de GetWinPercentage pour utiliser les valeurs spécifiques de BrokenBridgeRoom
function BrokenBridgeRoom:GetWinPercentage(index, player)
	return WinPercentage[index] + PlayerStatsService:GetAdditionnalChance(player)
end

function BreakBridge(roomModel)
	
	local delayTime = math.random(0, 1)

	for _, obj in ipairs(roomModel:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "Breakable" then
			task.spawn(function()
				table.insert(breakablePart, {
					part = obj,
					position = obj.Position,
					rotation = obj.Orientation -- ou obj.CFrame si tu veux tout
				})
				task.wait(delayTime)
				obj.Anchored = false
			end)
		end
	end
	
	task.wait(6)
	
	for _, obj in breakablePart do
		task.spawn(function()
			task.wait(math.random(1000,3000)/1000)
			
			local tweenInfo = TweenInfo.new(1)
			
			local goal = {}
			goal.Position = obj.position
			goal.Orientation = obj.rotation
			goal.Anchored = true
			
			local tween = TweenService:Create(obj.part, tweenInfo, goal)
			
			tween:Play()
		end)

	end
end

-- Si vous voulez appeler la fonction parent (BaseRoom) depuis une autre fonction :
-- Utilisez BaseRoom.GetWinPercentage(self, index) ou self:GetWinPercentage(index)

return BrokenBridgeRoom
