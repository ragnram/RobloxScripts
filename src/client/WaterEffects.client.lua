--Not sure how efficient this'd be so definitely modify it later on, also should be converted into a module once your main
--local script systems are complete.

local folder = game.Workspace:WaitForChild("TerrainFolder")
local waterPart = folder:WaitForChild("Water"):WaitForChild("Ocean")
local texture = waterPart:FindFirstChildOfClass("Texture")
local speed = 1

game:GetService("RunService").RenderStepped:Connect(function(dt)
	if texture then
		texture.OffsetStudsU = math.sin(tick() * speed) * 2
	end
end)