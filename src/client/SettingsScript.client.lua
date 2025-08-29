--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--// Variables
local playerGui = Players.LocalPlayer.PlayerGui
local settingUi = playerGui:WaitForChild("Main").Settings
local SettingsContainer = settingUi.Container

--// Local Functions
local function LerpColorSequence(startSequence, endSequence, alpha)
	local startColor = startSequence.Keypoints[1].Value
	local endColor = endSequence.Keypoints[1].Value
	local startColor2 = startSequence.Keypoints[2].Value
	local endColor2 = endSequence.Keypoints[2].Value

	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, startColor:Lerp(endColor, alpha)),
		ColorSequenceKeypoint.new(1, startColor2:Lerp(endColor2, alpha)),
	})
end

local function ToggleSwitchAnimation(switch: Frame)
	local goal
	local startSequence
	local endSequence
	local output
	local gradient = switch.Parent.UIGradient

	if switch.Position ~= UDim2.new(0.5, 0, 0.5, 0) then
		goal = { Position = UDim2.new(0.5, 0, 0.5, 0) }
		startSequence = gradient.Color
		endSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(175, 255, 89)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 255, 183)),
		})
		output = true
	else
		goal = { Position = UDim2.new(0, 0, 0.5, 0) }
		startSequence = gradient.Color
		endSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("ff2647")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("d10467")),
		})
		output = false
	end

	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local positionTween = TweenService:Create(switch, tweenInfo, goal)
	positionTween:Play()

	local startTime = tick()
	local duration = tweenInfo.Time

	local connection
	connection = RunService.Heartbeat:Connect(function()
		local alpha = math.clamp((tick() - startTime) / duration, 0, 1)
		gradient.Color = LerpColorSequence(startSequence, endSequence, alpha)

		if alpha >= 1 then
			connection:Disconnect()
		end
	end)
	return output
end
--// Events
for _, settingFrame in SettingsContainer:GetChildren() do
	if settingFrame:IsA("Frame") then
		settingFrame.Toggle.Activated:Connect(function()
			ToggleSwitchAnimation(settingFrame.Toggle.Slider)
		end)
	end
end
