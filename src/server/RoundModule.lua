--!strict
local RoundHandlerModule = {}

--// Services
local WorkSpace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Varubles
local startTimerEvent = ReplicatedStorage.Remotes.RemoteEvents.StartTimer

--// Local Functions
local function MovePlayerToStart(player: Player)
	local character = player.Character :: Model

	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local rootPart = character.PrimaryPart :: BasePart

	if humanoid.Health > 0 then
		rootPart.Position = Vector3.new(-212.637, 64.588, -96.191)
	end
end

local function GivePlayerMoney(player: Player, amount: number)
	local leaderStats = player:FindFirstChild("leaderstats")
	if leaderStats and leaderStats:FindFirstChild("Money") then
		(leaderStats:FindFirstChild("Money") :: IntValue).Value += amount
	end
end

--// Module Functions
RoundHandlerModule.lose = function(players: { Player })
	for _, player: Player in players do
		MovePlayerToStart(player)
		GivePlayerMoney(player, 50)
	end
end

RoundHandlerModule.win = function(players: { Player })
	for _, player: Player in players do
		MovePlayerToStart(player)
		GivePlayerMoney(player, 100)
	end
	task.wait(3)
	WorkSpace.Minigames:ClearAllChildren()
end

RoundHandlerModule.startTimer = function(gameName)
	startTimerEvent:FireAllClients(gameName)
end

return RoundHandlerModule
