local BaseRoom = require(script.Parent.BaseRoom)
local TweenService = game:GetService("TweenService")

local BrokenBridgeRoom = {}
BrokenBridgeRoom.__index = BrokenBridgeRoom
setmetatable(BrokenBridgeRoom, {__index = BaseRoom})

BrokenBridgeRoom.winPercentage = {
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
	1,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
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
	local isWin = BaseRoom:StartRoom(index, player)
	print(tostring(isWin) .. " " .. BrokenBridgeRoom.winPercentage[index])
	if isWin == false then
		spawn(function()
			BreakBridge(roomModel)
		end)
	end
end

function BreakBridge(roomModel)
	
	local delayTime = math.random(1.5, 3)

	task.wait(delayTime)
	for _, obj in ipairs(roomModel:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "Breakable" then
			--task.spawn(function()
				table.insert(breakablePart, {
					part = obj,
					position = obj.Position,
					rotation = obj.Orientation -- ou obj.CFrame si tu veux tout
				})
				obj.Anchored = false
				task.wait(0.01)
			--end)
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

return BrokenBridgeRoom
