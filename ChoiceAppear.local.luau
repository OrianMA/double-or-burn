local roomChoiceEvent = game.ReplicatedStorage.Remotes.RoomChoiceEvent
local ContinueEvent = game.ReplicatedStorage.Remotes.ContinueEvent
local CashOutEvent = game.ReplicatedStorage.Remotes.CashOutEvent

local Frame = script.Parent

--references
local CashOutButton = Frame.CashOutButton
local ContinueButton = Frame.ContinueButton
local RiskLabel = Frame.RiskLabel
local RewardLabel = Frame.RewardLabel

local reward = 0

roomChoiceEvent.OnClientEvent:Connect(function(reward, riskValue, isFinalRoom)
	RewardLabel.Text = tostring(reward)
	RiskLabel.Text = tostring(riskValue) .. "%"
	Frame.Visible = true
end)

CashOutButton.MouseButton1Click:Connect(function()
	Frame.Visible = false
	CashOutEvent:FireServer(reward)
end)

ContinueButton.MouseButton1Click:Connect(function()
	Frame.Visible = false
	ContinueEvent:FireServer()
end)