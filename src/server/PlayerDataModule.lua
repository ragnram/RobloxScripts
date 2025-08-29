--!strict

--// Module
local playerDataModule = {}

--// Services
local players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Varubles
local money = 1
local playTime = 2
local inventory = 3
local equippedEmotes = 4
local DataStore = DataStoreService:GetDataStore("PlayerData")
local playerData = {}

--// Local Functions
local function formatPlaytime(seconds: number): string
	if seconds then
		local minutes = math.floor(seconds / 60)
		if minutes < 60 then
			return tostring(minutes) .. "m"
		else
			local hours = math.floor(minutes / 60)
			return tostring(hours) .. "h"
		end
	end
	return tostring(0)
end

local function StartTimer(player: Player)
	while playerData[player.UserId] and task.wait(1) do
		playerData[player.UserId][playTime] += 1
		player["leaderstats"]["Play Time"].Value = formatPlaytime(playerData[player.UserId][playTime])
	end
end

local function UpdatePlayerMoney(player: Player)
	playerData[player.UserId][money] = player.leaderstats.Money.Value
end

local function newPlayer(player: Player)
	local leaderBoardFolder = Instance.new("Folder")
	leaderBoardFolder.Parent = player
	leaderBoardFolder.Name = "leaderstats"

	local moneyValue = Instance.new("IntValue")
	moneyValue.Parent = leaderBoardFolder
	moneyValue.Name = "Money"

	local stringTimeValue = Instance.new("StringValue")
	stringTimeValue.Parent = leaderBoardFolder
	stringTimeValue.Name = "Play Time"

	local success, playerTable = pcall(function()
		return DataStore:GetAsync(player.UserId)
	end)

	if false and success and playerTable then
		playerData[player.UserId] = playerTable
	else
		playerData[player.UserId] = { 0, 0, {}, {} }
	end

	moneyValue.Value = playerData[player.UserId][money]

	moneyValue.Changed:Connect(function()
		UpdatePlayerMoney(player)
	end)
	StartTimer(player)
end

local function removedPlayer(player)
	local succes, errorMessage = pcall(function()
		DataStore:SetAsync(player.UserId, {
			table.unpack(playerData[player.UserId]),
		})
	end)

	if not succes then
		warn(errorMessage)
	end
end

local function GiveInventory(player: Player)
	return playerData[player.UserId][inventory]
end

local function BuyItem(player: Player, item: Model)
	if playerData[player.UserId][money] >= item:GetAttribute("Price") then
		playerData[player.UserId][money] -= item:GetAttribute("Price")
		if item:IsA("Model") then
			local data = {
				item.Name,
				item:GetAttribute("Price") :: string,
				(item.Parent :: Folder).Name,
				item:GetAttribute("Image") :: string,
				item:GetAttribute("Description") :: string,
				{ 1, 1, 1 },
				item:GetAttribute("Rarity") :: string,
			}
			table.insert(playerData[player.UserId][inventory], data)
			return true
		end
	end
	return false
end

local function GiveEquippedEmotes(player)
	return playerData[player.UserId][equippedEmotes]
end

local function EquippedEmotes(player, emoteName, removeOrAdd)
	if removeOrAdd then
		table.insert(playerData[player.UserId][equippedEmotes], emoteName)
	else
		for index in playerData[player.UserId][equippedEmotes] do
			if playerData[player.UserId][equippedEmotes][index] == emoteName then
				playerData[player.UserId][equippedEmotes][index] = nil
			end
		end
	end
end

--// Module Functions
playerDataModule.RemoveFromInventory = function(player: Player, item)
	for index in playerData[player.UserId][inventory] do
		if playerData[player.UserId][inventory][index] == item then
			playerData[player.UserId][inventory][index] = nil
			break
		end
	end
end

playerDataModule.StartServer = function()
	players.PlayerAdded:Connect(newPlayer)
	players.PlayerRemoving:Connect(removedPlayer)
	ReplicatedStorage.Remotes.RemoteFunction.GetInventory.OnServerInvoke = GiveInventory
	ReplicatedStorage.Remotes.RemoteFunction.BuyItem.OnServerInvoke = BuyItem
	ReplicatedStorage.Remotes.RemoteFunction.GiveEquippedEmotes.OnServerInvoke = GiveEquippedEmotes
	ReplicatedStorage.Remotes.RemoteEvents.EquippedEmotes.OnServerEvent:Connect(EquippedEmotes)
end

--// Return Module
return playerDataModule
