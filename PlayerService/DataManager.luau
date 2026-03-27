local DataStoreService = game:GetService("DataStoreService")
local GetData = game.ReplicatedStorage.GetData
local Players = game:GetService("Players")

local DataManager = {}

local dataStore = DataStoreService:GetDataStore("PlayerStats_v1")

local DEFAULT_DATA = {
	chance = 0,
	wins = 0
}

local sessionData = {}

-- copie propre
local function DeepCopy(tbl)
	local copy = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			copy[k] = DeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

-- LOAD
function DataManager:Load(player)
	local userId = player.UserId
	local key = "player_" .. userId

	local success, data = pcall(function()
		return dataStore:GetAsync(key)
	end)

	if success and data then
		sessionData[userId] = data
	else
		sessionData[userId] = DeepCopy(DEFAULT_DATA)
		if not success then
			warn("Load error:", player.Name)
		end
	end
end

-- SAVE
function DataManager:Save(player)
	local userId = player.UserId
	local key = "player_" .. userId

	local data = sessionData[userId]
	if not data then return end

	local success, err = pcall(function()
		dataStore:SetAsync(key, data)
	end)

	if not success then
		warn("Save error:", player.Name, err)
	end
end

-- GET
function DataManager:Get(player, statName)
	local data = sessionData[player.UserId]
	if not data then return nil end
	return data[statName]
end

-- SET
function DataManager:Set(player, statName, value)
	local data = sessionData[player.UserId]
	if not data then return end
	data[statName] = value

	-- Sync leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local stat = leaderstats:FindFirstChild(statName)
		if stat then
			stat.Value = value
		end
	end
end

-- ADD
function DataManager:Add(player, statName, amount)
	local data = sessionData[player.UserId]
	if not data then return end
	data[statName] = (data[statName] or 0) + amount

	-- Sync leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local stat = leaderstats:FindFirstChild(statName)
		if stat then
			stat.Value = data[statName]
		end
	end

	DataManager:Save(player)
end

GetData.OnServerInvoke = function(player)
	return sessionData[player.UserId]
end

-- INIT PLAYER
function DataManager:InitPlayer(player)
	self:Load(player)

	-- Leaderstats (optionnel mais pratique)
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	folder.Parent = player

	for statName, value in pairs(sessionData[player.UserId]) do
		local int = Instance.new("IntValue")
		int.Name = statName
		int.Value = value
		int.Parent = folder

		-- sync auto quand ça change
		int.Changed:Connect(function(newValue)
			sessionData[player.UserId][statName] = newValue
		end)
	end
end

-- AUTOSAVE
task.spawn(function()
	while true do
		task.wait(120)
		for _, player in ipairs(Players:GetPlayers()) do
			DataManager:Save(player)
		end
	end
end)

return DataManager