local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local dataStore = DataStoreService:GetDataStore("PlayerStats_v1")
local SyncDataEvent = game.ReplicatedStorage.Remotes.SyncDataEvent
local GetData = game.ReplicatedStorage.GetData
local Players = game:GetService("Players")

local DataManager = {}

local WINS_PASS_ID = 1775250373
local LUCKY_PASS_ID = 1775654509

local DEFAULT_DATA = {
	chance = 0,
	wins = 0,
	unlockedPlates = {},
	equippedPlate = nil,
	winsMultiplier = 1,
	chanceMultiplier = 1,
}

local sessionData = {}

local function HasGamePass(player, gamePassId)
	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
	end)

	if success then
		return result
	else
		warn("Erreur check gamepass:", result)
		return false
	end
end

local function ApplyGamePasses(player, stats)
	if HasGamePass(player, WINS_PASS_ID) then
		stats.winsMultiplier = 2
	else
		stats.winsMultiplier = 1
	end

	if HasGamePass(player, LUCKY_PASS_ID) then
		stats.chanceMultiplier = 2
	else
		stats.chanceMultiplier = 1
	end
end

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

function DataManager:SyncClient(player)
	local data = sessionData[player.UserId]
	if not data then return end
	SyncDataEvent:FireClient(player, {
		wins = data.wins,
		chance = data.chance,
		unlockedPlates = data.unlockedPlates,
		equippedPlate = data.equippedPlate,
		gamePasses = data.gamePasses,
		winsMultiplier = data.winsMultiplier,
		chanceMultiplier = data.chanceMultiplier,
	})
end

-- Modifie Add et Set pour sync automatiquement :
function DataManager:Add(player, statName, amount)
	local data = sessionData[player.UserId]
	if not data then return end
	data[statName] = (data[statName] or 0) + amount
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local stat = leaderstats:FindFirstChild(statName)
		if stat then stat.Value = data[statName] end
	end
	self:SyncClient(player) -- ✅
end

function DataManager:Set(player, statName, value)
	local data = sessionData[player.UserId]
	if not data then return end
	data[statName] = value
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local stat = leaderstats:FindFirstChild(statName)
		if stat then stat.Value = value end
	end
	self:SyncClient(player) -- ✅
	self:Save(player)
end

GetData.OnServerInvoke = function(player)
	return sessionData[player.UserId]
end

local DISPLAYED_STATS = { chance = true, wins = true }

function DataManager:InitPlayer(player)
	self:Load(player)
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	folder.Parent = player
	for statName, value in pairs(sessionData[player.UserId]) do
		if type(value) == "number" and DISPLAYED_STATS[statName] then
			local int = Instance.new("IntValue")
			int.Name = statName
			int.Value = value
			int.Parent = folder
			int.Changed:Connect(function(newValue)
				sessionData[player.UserId][statName] = newValue
			end)
		end
	end
end
-- AUTOSAVE
task.spawn(function()
	while true do
		task.wait(120)
		for _, player in ipairs(Players:GetPlayers()) do
			DataManager:Save(player)
			DataManager:UpdateWinsLeaderboard(player)
		end
	end
end)

local winsOrderedStore = DataStoreService:GetOrderedDataStore("WinsLeaderboard")

function DataManager:UpdateWinsLeaderboard(player)
	local wins = self:Get(player, "wins")
	if not wins or wins <= 0 then return end
	local suc, err = pcall(function()
		winsOrderedStore:SetAsync("wins_" .. player.UserId, wins)
	end)
	if not suc then warn("Leaderboard sync error:", err) end
end

return DataManager