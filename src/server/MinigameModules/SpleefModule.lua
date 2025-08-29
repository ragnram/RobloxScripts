--!strict

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

--// Modules
local roundHandlerModule = require(ServerScriptService.RoundModule)
local MiniGameModule = require(ServerScriptService.MiniGameModule)

type MiniGameData = MiniGameModule.MiniGameData

--// Module
local spleefModule = {
	--// Settings
	SpawnSettings = {
		distanceFromCenenter = 50,
	},
	PartBreakSettings = {
		TimeToBreak = 50,
	},
}

--// Varubles
local gameStats = false
local PlayersLeft: {}
local TouchConnection: RBXScriptConnection
local hitPlayers = {}

--// Local Functions

local function AnckerPlayers(playerTable, bool)
	for _, player: Player in playerTable do
		local character = player.Character :: Model
		local rootPart = character.PrimaryPart
		if rootPart then
			rootPart.Anchored = bool
		end
	end
end

local function TouchedPart(part: BasePart)
	for i = 1, spleefModule.PartBreakSettings.TimeToBreak, 1 do
		task.wait(0)
		part.Transparency = i / spleefModule.PartBreakSettings.TimeToBreak
	end
	part:Destroy()
end

local function MakePartsBreakOnTouch(Map: Model)
	for _, Floor: Instance | Model in Map:GetChildren() do
		if Floor.Name == "SpleefFloor" then
			for _, Part: Instance | BasePart in Floor:GetChildren() do
				if Part:IsA("BasePart") then
					Part.Touched:Connect(function()
						TouchedPart(Part)
					end)
				end
			end
		end
	end
end

local function PlayerFellOff(): RBXScriptConnection
	return Workspace.Water.Touched:Connect(function(part: BasePart)
		local character = part:FindFirstAncestorOfClass("Model") :: Model
		local player = Players:GetPlayerFromCharacter(character)
		if hitPlayers[player.UserId] == true then
			return
		end
		hitPlayers[player.UserId] = true
		roundHandlerModule.lose({ player })

		table.remove(PlayersLeft, table.find(PlayersLeft, player))

		if #PlayersLeft <= 1 then
			spleefModule.endRound()
		end
	end)
end

--// Module Functions
spleefModule.getPlayersLeft = function()
	return PlayersLeft
end

spleefModule.endRound = function()
	if gameStats then
		gameStats = false
		roundHandlerModule.win(PlayersLeft)
		TouchConnection:Disconnect()
		Workspace.Minigames:ClearAllChildren()
	end
end

spleefModule.Start = function(playerTable: { Player })
	local self = {
		Map = ReplicatedStorage.Minigames.SpleefMinigame:Clone(),
		PlayerTable = playerTable,
	} :: MiniGameData
	hitPlayers = {}
	PlayersLeft = playerTable
	gameStats = true
	TouchConnection = PlayerFellOff()

	self.Map.Parent = Workspace.Minigames
	MakePartsBreakOnTouch(self.Map)

	MiniGameModule.MovePlayers(self, 30)

	AnckerPlayers(playerTable, true)
	task.wait(5)
	AnckerPlayers(playerTable, false)
	roundHandlerModule.startTimer("SpeefModule")
	spleefModule.endRound()
end

return spleefModule
