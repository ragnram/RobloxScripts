--!strict

local ServerScriptService = game:GetService("ServerScriptService")

local RagdallModule = require(ServerScriptService.RagdallModule)
local PhysicsService = game:GetService("PhysicsService")

PhysicsService:RegisterCollisionGroup("A")
PhysicsService:RegisterCollisionGroup("B")
PhysicsService:CollisionGroupSetCollidable("A", "B", false)

local RE = game.ReplicatedStorage.Remotes.RemoteEvents

local function targetCFrame(player, target)
	local TargetPart = target.PrimaryPart :: BasePart
	return (TargetPart.Position - player.Character.PrimaryPart.Position).Unit * 12000
end

local hitServer = {}

RE.HitPlayer.OnServerEvent:Connect(function(player, target: Model)
	if hitServer[target] == true then
		return
	end
	hitServer[target] = true

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = targetCFrame(player, target)
	bodyVelocity.Parent = target.PrimaryPart :: BasePart
	bodyVelocity.MaxForce = targetCFrame(player, target)
	RagdallModule.Bot(target)

	task.wait(0.05)
	bodyVelocity:Destroy()

	task.wait(3)

	hitServer[target] = nil
end)

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		char:WaitForChild("Humanoid")
		RagdallModule.Joints(char)
	end)
end)
