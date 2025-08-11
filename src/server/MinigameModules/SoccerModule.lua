--!strict

--// Module Table
local SoccerModule = {}

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

--// OtherModules
local MiniGameModule = require(ServerScriptService.MiniGameModule)
local roundHandlerModule = require(ServerScriptService.RoundModule)

--// Type
type MiniGameData = MiniGameModule.MiniGameData
type TeamData = {
	RedTeam: { Player },
	BlueTeam: { Player },
	RedScore: number,
	BlueScore: number,
}

--// Varuables
local BlueTouch: RBXScriptConnection, RedTouch: RBXScriptConnection
local TouchWaterConnection: RBXScriptConnection
local BluePoints, RedPoints = 0, 0
local RedTeam, BlueTeam

--// Local Functions
local function GetMap()
	local map = ReplicatedStorage.Minigames.SoccerMinigame:Clone()
	map.Parent = Workspace.Minigames
	return map
end

local function SetTeams(miniGameData: MiniGameData)
	local redTeam = {}
	local blueTeam = {}

	for index, player: Player in miniGameData.PlayerTable do
		local character = player.Character :: Model

		for _, v: Instance | Part in character:GetChildren() do
			if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part") then
				(v :: BasePart).CanCollide = true
			end
		end

		local teamHighLight = Instance.new("Highlight", character)
		teamHighLight.FillTransparency = 1

		if index % 2 == 1 then
			teamHighLight.OutlineColor = Color3.new(1, 0, 0)
			table.insert(redTeam, player)
		else
			teamHighLight.OutlineColor = Color3.new(0, 0, 1)
			table.insert(blueTeam, player)
		end
	end

	RedTeam, BlueTeam = redTeam, blueTeam
end

local function SetUpNets(miniGameData: MiniGameData)
	local BlueNet = miniGameData.Map:WaitForChild("GoalBlue"):WaitForChild("HitBox") :: Part
	local RedNet = miniGameData.Map:WaitForChild("GoalRed"):WaitForChild("HitBox") :: Part

	local BallStartPosition = Vector3.new(-381.353, 55.219, -156.859)

	local scored = false

	local function InNet(part: BasePart)
		local function Particels(bool)
			if part:IsA("BasePart") and part:FindFirstChildOfClass("Attachment") then
				for _, effect: Instance in part:FindFirstChildOfClass("Attachment"):GetChildren() do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = bool
					end
				end
			end
		end

		if part.Name == "Ball" and not scored then
			scored = true
			Particels(true)
			task.wait(1)
			Particels(false)
			task.wait(0.5)
			part.Position = BallStartPosition
			scored = false
		end
	end

	BlueTouch = BlueNet.Touched:Connect(function(part)
		InNet(part)
		RedPoints += 1
	end)

	RedTouch = RedNet.Touched:Connect(function(part)
		InNet(part)
		BluePoints += 1
	end)
end

local function SetUpBall(miniGameData: MiniGameData)
	local ball = miniGameData.Map:WaitForChild("Ball") :: MeshPart
	ball.Touched:Connect(function(Part)
		local character = Part:FindFirstAncestorOfClass("Model")
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			ball:SetNetworkOwner(player)
		end
	end)
end

local function SetUpWater()
	return Workspace.Water.Touched:Connect(function(Part)
		local character = Part:FindFirstAncestorOfClass("Model")
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			local rootPart = character.PrimaryPart :: Part
			rootPart.Position = Vector3.new(-381.353, 55.219, -156.859)
		end
	end)
end

--// Module Functions
SoccerModule.endRound = function()
	BlueTouch:Disconnect()
	RedTouch:Disconnect()
	TouchWaterConnection:Disconnect()
	if RedPoints > BluePoints then
		roundHandlerModule.win(RedTeam)
		roundHandlerModule.lose(BlueTeam)
	elseif RedPoints < BluePoints then
		roundHandlerModule.win(BlueTeam)
		roundHandlerModule.lose(RedTeam)
	end
	Workspace.Minigames:ClearAllChildren()
end

SoccerModule.start = function(playerTable: { Player })
	local self = {
		Map = GetMap(),
		PlayerTable = playerTable,
	} :: MiniGameData

	BluePoints, RedPoints = 0, 0

	SetTeams(self)
	MiniGameModule.MovePlayers(self, 30)
	SetUpNets(self)
	SetUpBall(self)
	TouchWaterConnection = SetUpWater()

	roundHandlerModule.startTimer("Bomb Game")

	if #playerTable <= 0 then
		task.wait(5)
		--SoccerModule.endRound()
		return
	end
end

return SoccerModule
