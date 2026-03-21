local event = game.ReplicatedStorage.Remotes.RoomChoiceEvent

event.OnServerEvent:Connect(function(player, roomId)
	print("Room choisie :", roomId)
	event:FireClient("RoomChoiceEvent")
end)