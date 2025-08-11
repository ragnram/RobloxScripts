--!strict

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--// Objects
local NotificationUI = Players.LocalPlayer.PlayerGui:WaitForChild("Main").Minigames

--// Varubles
local events

--// Local Functions
local function SlideDownNotificaton()
	NotificationUI.Visible = true
	
	local defaultPosition = NotificationUI.Position
	NotificationUI.Position = defaultPosition - UDim2.new(0,0,0,150)
	
	local goal = {}
	goal.Position = defaultPosition

	local tweenInfo = TweenInfo.new(0.8)

	local tween = TweenService:Create(NotificationUI, tweenInfo, goal)

	tween:Play()
end

local function Close()
	NotificationUI.Visible = false
	for _, event in events do
		event:Disconnect()
	end
end

local function Dicline()
	Close()
end

local function Accept()
	ReplicatedStorage.Remotes.RemoteEvents.JoinMiniGame:FireServer()
	Close()
end

local function CountDown()
	for count = 15, 0, -1 do
		NotificationUI.TimeLeft.Text = count
		task.wait(1)
	end
	Close()
end

--// Module Functions
local function notification(name)
	
	NotificationUI.CurrentMinigame.Text = name

	SlideDownNotificaton()
	
	events = {
		NotificationUI.Dismiss.Activated:Connect(Dicline),
		NotificationUI.Join.Activated:Connect(Accept)
	}
	
	CountDown()
end

--// Events
ReplicatedStorage.Remotes.RemoteEvents.JoinMiniGame.OnClientEvent:Connect(notification)