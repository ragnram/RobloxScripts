--// Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorkSpace = game:GetService("Workspace")
local Players = game:GetService("Players")

--// Modules
local PlayerDataModule = require(ServerScriptService.PlayerDataModule)
local MiniGameHandler = require(ServerScriptService.MinigameHandler)
local SoccerMinigame = require(ServerScriptService.MinigameModules.SoccerModule)
local SpleefMinigame = require(ServerScriptService.MinigameModules.SpleefModule)
local BombMinigame = require(ServerScriptService.MinigameModules.BombModule)
local SlapBattleMinigame = require(ServerScriptService.MinigameModules.SlapBattleModule)
--// Events
ReplicatedStorage.Remotes.RemoteEvents.JoinMiniGame.OnServerEvent:Connect(MiniGameHandler.PlayerJoinMiniGame)
WorkSpace.Minigames.ChildRemoved:Connect(MiniGameHandler.StartMiniGame)

--// Calls
PlayerDataModule.StartServer()
MiniGameHandler.StartMiniGame()
