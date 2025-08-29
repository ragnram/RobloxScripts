--!strict

--// Creat Module Table
local SlapBattleModule = {}

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

--// OtherModules
local roundHandlerModule = require(ServerScriptService.RoundModule)
local MiniGameModule = require(ServerScriptService.MiniGameModule)

--// Types
type MiniGameData = MiniGameModule.MiniGameData

--// Varubles
local TouchedWaterConnection: RBXScriptConnection
local PlayersLeft: { Player }
local hitPlayers = {}
--// Local Functions

local function RemoveSlapTool()
	local playersTable = Players:GetDescendants()
	local workspaceTable = workspace:GetDescendants()

	local function FindSlapTool(Table: { any })
		for _, instance: Instance in Table do
			if instance:IsA("Tool") then
				local tagTable = instance:GetTags()
				for _, tag in tagTable do
					if tag == "Slap" then
						instance:Destroy()
					end
				end
			end
		end
	end

	FindSlapTool(playersTable)
	FindSlapTool(workspaceTable)
end

local function SetUpWater()
	return Workspace.Water.Touched:Connect(function(part)
		local character = part:FindFirstAncestorOfClass("Model")
		local player = Players:GetPlayerFromCharacter(character)
		if player and not hitPlayers[player.UserId] then
			hitPlayers[player.UserId] = true
			roundHandlerModule.lose({ player })
			table.remove(PlayersLeft, table.find(PlayersLeft, player))
			if #PlayersLeft <= 1 then
				SlapBattleModule.endRound()
			end
		end
	end)
end

local function GetMap()
	local Map = ReplicatedStorage.Minigames.SumoMinigame:Clone()
	Map.Parent = Workspace.Minigames
	return Map
end

local function GiveTool(miniGameData: MiniGameData)
	for _, player: Player in miniGameData.PlayerTable do
		local Tool = ReplicatedStorage.MiniGameTools.SlapTool:Clone()
		Tool.Parent = player.Backpack
	end
end

--// Module Functions
SlapBattleModule.endRound = function()
	roundHandlerModule.win(PlayersLeft)
	TouchedWaterConnection:Disconnect()
	RemoveSlapTool()
	Workspace.Minigames:ClearAllChildren()
end

SlapBattleModule.Start = function(playerTable: { Player })
	local self = {
		PlayerTable = playerTable,
		Map = GetMap(),
	} :: MiniGameData
	hitPlayers = {}
	PlayersLeft = playerTable
	MiniGameModule.MovePlayers(self, 30)
	TouchedWaterConnection = SetUpWater()
	GiveTool(self)

	roundHandlerModule.startTimer("Slap Game")
end

return SlapBattleModule
