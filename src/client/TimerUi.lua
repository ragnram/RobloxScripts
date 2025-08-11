--!strict

--// Service
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Varubles
local player = Players.localPlayer
local PlayerGui = player.PlayerGui
local timerFrame = PlayerGui:WaitForChild("Main").RoundTimer
local timerName = timerFrame.CurrentMinigame
local timerTime = timerFrame.TimeLeft

--// Local Functions
local function startTimer(MinigameName)
	timerFrame.Visible = true
	for i = 60 * 3, 0, -1 do
		task.wait(1)
		local mins = math.floor(i / 60)
		timerTime.Text = mins .. ":" .. i - mins * 60
	end
	timerFrame.Visible = false
end

--// Events
ReplicatedStorage.Remotes.RemoteEvents.StartTimer.OnClientEvent:Connect(startTimer)
