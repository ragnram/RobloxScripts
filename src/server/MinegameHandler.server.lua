--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local WorkSpace = game:GetService("Workspace")

--// Modules
local BombModule = require(ServerScriptService.MinigameModules.BombModule)
local SlapBattleModule = require(ServerScriptService.MinigameModules.SlapBattleModule)
local SoccerModule = require(ServerScriptService.MinigameModules.SoccerModule)
local SpleefModule = require(ServerScriptService.MinigameModules.SpleefModule)

--// Varubles
local playersJoiningMiniGame = {}
local MiniGames = {
	{ BombModule, "Bomb Game" },
	{ SlapBattleModule, "Slap Game" },
	{ SoccerModule, "Soccer Game" },
	{
		SpleefModule,
		"Spleef Game",
	},
}

local lastMinigame

--// Local Functions
local function PlayerJoinMiniGame(player)
	table.insert(playersJoiningMiniGame, player)
end

local function PickMiniGame()
	while true do
		local newMiniGame = math.random(1, #MiniGames)
		if not lastMinigame or lastMinigame ~= newMiniGame then
			lastMinigame = newMiniGame
			return newMiniGame
		end
	end
end

local function StartMiniGame()
	if #WorkSpace.Minigames:GetChildren() == 0 then
		playersJoiningMiniGame = {}
		ReplicatedStorage.Remotes.RemoteEvents.JoinMiniGame:FireAllClients(MiniGames[PickMiniGame()][2])
		task.wait(17)
		MiniGames[PickMiniGame()][1].start(playersJoiningMiniGame)
	end
end

--// Events
ReplicatedStorage.Remotes.RemoteEvents.JoinMiniGame.OnServerEvent:Connect(PlayerJoinMiniGame)
WorkSpace.Minigames.ChildRemoved:Connect(StartMiniGame)

--// Calls
task.wait(1)
StartMiniGame()
