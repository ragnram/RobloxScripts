local module = {}
local movePlayer = require(script.Parent.TeleportModual)

local position:Vector3 = Vector3.new()
local waitTime = 1
local distance = math.huge

while task.wait(waitTime) do
	for _, v in pairs(game.Workspace:GetChildren()) do
		if v:IsA("Model") and v.PrimaryPart.Name == "HumanoidRootPart" and (v.PrimaryPart.Position - position).Magnitude < distance then
			movePlayer.move(v)
		end
	end
end

return module
