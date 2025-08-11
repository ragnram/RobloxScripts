--!strict

local RemoteEvents = game.ReplicatedStorage.Remotes.RemoteEvents
local player = game.Players.LocalPlayer

local function WatchForTool()
	player.Character.ChildAdded:Connect(function(tool: Tool)
		if tool:HasTag("Slap") then
			local connect: RBXScriptConnection
			local hit = {}
			local Handle = tool:FindFirstChild("Handle") :: BasePart

			connect = Handle.Touched:Connect(function(part)
				local character = part:FindFirstAncestorOfClass("Model")
				if hit[character] then
					return
				end
				hit[character] = true
				if character and character:FindFirstChildOfClass("Humanoid") then
					RemoteEvents.HitPlayer:FireServer(character)
				end
				task.wait(4)
				hit[character] = nil
			end)

			tool.Unequipped:Connect(function()
				connect:Disconnect()
			end)
		end
	end)
end

player.CharacterAdded:Connect(WatchForTool)
