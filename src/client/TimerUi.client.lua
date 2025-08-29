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
local miniGameTimer

--// Local Functions
local function startTimer(MinigameName)
	miniGameTimer = MinigameName
	if miniGameTimer then
		timerName.Text = MinigameName
		timerFrame.Visible = true
		for i = 60 * 3, 0, -1 do
			if miniGameTimer ~= MinigameName then
				return
			end
			local mins = math.floor(i / 60)
			local seconds = tostring(i - mins * 60)

			if string.len(seconds) == 1 then
				seconds = "0" .. seconds
			end

			timerTime.Text = mins .. ":" .. seconds
			task.wait(1)
		end
		timerFrame.Visible = false
	else
		timerFrame.Visible = false
	end
end

--// Events
ReplicatedStorage.Remotes.RemoteEvents.StartTimer.OnClientEvent:Connect(startTimer)
