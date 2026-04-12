local roomChoiceEvent = game.ReplicatedStorage.Remotes.RoomChoiceEvent
local ContinueEvent = game.ReplicatedStorage.Remotes.ContinueEvent
local CashOutEvent = game.ReplicatedStorage.Remotes.CashOutEvent
local endGameEvent = game.ReplicatedStorage.Remotes.EndGameEvent

local Frame = script.Parent
local Player = game.Players

--references
local CashOutButton = Frame.CashOutButton
local ContinueButton = Frame.ContinueButton
local RiskLabel = Frame.RiskLabel
local RewardLabel = Frame.RewardLabel

local _reward = 0

roomChoiceEvent.OnClientEvent:Connect(function(reward, riskValue, isFinalRoom)
	
	local human = Player.LocalPlayer.Character:WaitForChild("Humanoid")

	if human:GetState() == Enum.HumanoidStateType.Dead then
		print("dioufhnozedfhbn")
		Frame.Visible = false
		return
	end
	
	_reward = reward
	RewardLabel.Text = tostring(reward)
	RiskLabel.Text = tostring(riskValue) .. "%"
	Frame.Visible = true
end)

CashOutButton.MouseButton1Click:Connect(function()
	Frame.Visible = false
	CashOutEvent:FireServer(_reward)
end)

ContinueButton.MouseButton1Click:Connect(function()
	Frame.Visible = false
	ContinueEvent:FireServer()
end)

endGameEvent.OnClientEvent:Connect(function()
	Frame.Visible = false
end)

