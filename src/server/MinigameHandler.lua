-- // Module
local MiniGameHandler = {}

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
local function PickMiniGame()
	while true do
		local newMiniGame = math.random(1, #MiniGames)
		if not lastMinigame or lastMinigame ~= newMiniGame then
			lastMinigame = newMiniGame
			return newMiniGame
		end
	end
end

--// Module Functions
function MiniGameHandler.StartMiniGame()
	if #WorkSpace.Minigames:GetChildren() == 0 then
		playersJoiningMiniGame = {}
		local pickedMinigame = PickMiniGame()
		ReplicatedStorage.Remotes.RemoteEvents.JoinMiniGame:FireAllClients(MiniGames[pickedMinigame][2])
		task.wait(17)
		if #playersJoiningMiniGame > 1 then
			MiniGames[pickedMinigame][1].Start(playersJoiningMiniGame)
		else
			task.wait(17)
			MiniGameHandler.StartMiniGame()
		end
	end
end

function MiniGameHandler.PlayerJoinMiniGame(player)
	table.insert(playersJoiningMiniGame, player)
end

--// Return Statement
return MiniGameHandler
