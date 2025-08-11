--!strict

--// Constants
local SoundId = "rbxassetid://18694762392"

--// Varuables
local PlayersLeft: {Player}
local TouchConnection: RBXScriptConnection

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

--// OtherModules
local roundHandlerModule = require(ServerScriptService.RoundModule)
local MiniGameModule = require(ServerScriptService.MiniGameModule)

--// Types
type MiniGameData = MiniGameModule.MiniGameData

--// Workspace Varubles
local bombSuff = Workspace.BombSuff
local bombRange = bombSuff.BombRange
local allBombs = ReplicatedStorage.BombModels

--// Main Module
local BombModule = {
	Parent = bombSuff.Bombs,
	SpawnSettings = {
		distanceFromCenenter = 50
	}
}

local function GetRandomCFrame(miniGameData: MiniGameData) : CFrame | boolean
	local allParts : {Instance} = miniGameData.Map:GetDescendants()
	local PartsLeft = true
	local number = math.random(1,#allParts)
	while not allParts[number]:IsA("Part") and not allParts[number]:IsA("MeshPart") do
		number = math.random(1,#allParts)
		for _ ,part in allParts do
			PartsLeft = false
			if part:IsA("Part") or part:IsA("MeshPart")  then
				PartsLeft = true
				break
			end
		end
		if PartsLeft == false then
			return false
		end
	end
	return CFrame.new((allParts[number] :: BasePart).Position + Vector3.new(0, 30, 0))
end

local function GetRandomBomb() : Model
	return allBombs:GetChildren()[math.random(1, #allBombs:GetChildren())]:Clone()
end

local function MoveBomb(Model: Model , miniGameData: MiniGameData) : boolean
	Model.Parent = BombModule.Parent
	
	local position = GetRandomCFrame(miniGameData)
	if position then
		Model:PivotTo(position :: CFrame)
	else
		return false
	end
	return true
end

local function UnAncker (bomb)
	for _, part : BasePart | any in bomb:GetChildren() do
		if part:IsA("BasePart") then
			(part :: BasePart).Anchored = false
		end
	end
end

local function MakeBombExplosion(miniGameData : MiniGameData, bomb : Model)
	local explosion = Instance.new("Explosion")
	explosion.Parent = bombRange
	if not bomb then return end
	explosion.Position = (bomb.PrimaryPart :: BasePart).Position
	explosion.BlastRadius = 20
	explosion.BlastPressure =  0
	explosion.Hit:Connect(function(part, distance)
		local parentModel  = part:FindFirstAncestorOfClass("Model")
		if not parentModel then return end
		local player = Players:FindFirstChild(parentModel.Name)
		if player then
			local Humaniod = parentModel:FindFirstChild("Humanoid") :: Humanoid
			Humaniod:TakeDamage(1000/distance)
			if Humaniod.Health >= 0 then
				table.remove(PlayersLeft,table.find(PlayersLeft, player))
				roundHandlerModule.lose({player})
			end
		elseif parentModel:FindFirstAncestorOfClass("Model") == miniGameData.Map then
			part:Destroy()
		end
	end)
end

local function PlayerBombSound(bomb)
	local explosionSound = Instance.new("Sound")
	explosionSound.Parent = bomb
	explosionSound.RollOffMaxDistance = 500
	explosionSound.SoundId = SoundId
	explosionSound:Play()
	explosionSound.Ended:Wait()
end

local function PlayerFellOff() : RBXScriptConnection
	return Workspace.Water.Touched:Connect(function(part : BasePart)
		local character = part:FindFirstAncestorOfClass("Model") :: Model
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end
		table.remove(PlayersLeft,table.find(PlayersLeft, player))
		
		if #PlayersLeft <= 1 then
			BombModule.endRound()
		end

		roundHandlerModule.lose({player})
	end)
end

--// Module Functions
BombModule.endRound = function()
		roundHandlerModule.win(PlayersLeft)
		TouchConnection:Disconnect()
		Workspace.Minigames:ClearAllChildren()
	end

BombModule.getPlayersLeft = function()
	return PlayersLeft
end


BombModule.start = function(playerTable : {Player})
	local self = {
		PlayerTable = playerTable,
		Map = ReplicatedStorage.Minigames.BombMinigame:Clone()
	} :: MiniGameData

	self.Map.Parent = Workspace.Minigames
	TouchConnection = PlayerFellOff()
	MiniGameModule.MovePlayers(self,30)

	PlayersLeft = playerTable
	local loop = true
	
	roundHandlerModule.startTimer("Bomb Game")

	if #playerTable <= 0 then
		task.wait(5)
		BombModule.endRound()
		return
	end
	
	while task.wait(1.5) and loop and #PlayersLeft > 1 do -- testing
		task.spawn(function()
			local bomb : Model = GetRandomBomb()

			loop = MoveBomb(bomb,self) 
			UnAncker(bomb)

			task.wait(3.5)
			MakeBombExplosion(self, bomb)

			PlayerBombSound(bomb)

			bomb:Destroy()
		end)
	end
	BombModule.endRound()
end

return BombModule


