local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local RE = game.ReplicatedStorage.Remotes.RemoteEvents.Ragdoll

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local H = char:WaitForChild("Humanoid")
local Inp = false

local function set()
	workspace.CurrentCamera.CameraSubject = char.Head
	H:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
	H:ChangeState(Enum.HumanoidStateType.Ragdoll)
	for _, v in pairs(H:GetPlayingAnimationTracks()) do
		v:Stop(0)
	end
	char.Animate.Disabled = true
end

local function rest()
	plr.CameraMode = Enum.CameraMode.Classic
	plr.CameraMinZoomDistance = 10
	plr.CameraMinZoomDistance = 0.5
	workspace.CurrentCamera.CameraSubject = H
	char.Animate.Disabled = false
	char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
	char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

RE.OnClientEvent:Connect(function(bool)
	if bool == true then
		set()
	else
		rest()
	end
end)
