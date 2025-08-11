--!strict

export type MiniGameData = {
	Map:Model,
	PlayerTable: {Player}
}

--// Services
local Workspace = game:GetService("Workspace")

--// Module Declaration
local MiniGameModule = {
	Water = Workspace.Water
}

--// Local Functions
local function getPositonForCircle(center: Vector3, playerIndex: number, numberOfPlayers: number, distanceFromCeneter: number): Vector3
	local angle = 360 / numberOfPlayers * playerIndex

	local angleFromCenter = CFrame.new(center) * CFrame.Angles(0,math.rad(angle),0)
	local direction = CFrame.new(0,0,distanceFromCeneter or 25)

	return (angleFromCenter * direction).Position
end

--// Module Functions
MiniGameModule.MovePlayers = function(miniGameData: MiniGameData, distanceFromCeneter)
	for index, player : Player in miniGameData.PlayerTable do

		local root = ((player.Character :: Model).PrimaryPart :: Part)
		local startingHight = miniGameData.Map.WorldPivot.Position 
			+ Vector3.new(0,miniGameData.Map:GetExtentsSize().Y/4,0);

		root.Position = getPositonForCircle(startingHight,index,#miniGameData.PlayerTable,distanceFromCeneter)
	end
end

return MiniGameModule