--!strict

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Varubles
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local MainGUI = PlayerGui:WaitForChild("Main"):WaitForChild("Notifications")

--// Remotes
local inviteRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteEvents"):WaitForChild("Invite")
local addToPartyRemote =
	ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteEvents"):WaitForChild("AddToParty")

-- Store original position exactly as it was in Studio
local originalPosition = MainGUI.Position
local hiddenPosition = UDim2.new(2, 0, originalPosition.Y.Scale, originalPosition.Y.Offset)

-- Tween helper
local function tweenTo(position, direction, onComplete)
	local tween = TweenService:Create(MainGUI, TweenInfo.new(0.3, Enum.EasingStyle.Quad, direction), {
		Position = position,
	})
	tween:Play()
	if onComplete then
		tween.Completed:Once(onComplete)
	end
end

-- Get player avatar
local function getPlayerIcon(char)
	local userId = char.UserId
	return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
end

-- Close function
local function close(notification)
	tweenTo(hiddenPosition, Enum.EasingDirection.In, function()
		notification:Destroy()
	end)
end

-- Open invite
local function open()
	local notification = ReplicatedStorage.GUI.Notification:Clone()
	notification.Parent = MainGUI
	notification.ImageLabel.Image = getPlayerIcon(player)
	notification.PlayerName.Text = "Invite from " .. player.Name
	tweenTo(originalPosition, Enum.EasingDirection.Out)
	
	local function joinParty()
		local fullText = MainGUI.PlayerName.Text
		local playerName = string.sub(fullText, 13)
		addToPartyRemote:FireServer(playerName)
		close(notification)
	end;
	(notification.Accept :: GuiButton).Activated:Connect(joinParty);
	(notification.Decline :: GuiButton).Activated:Connect(function()
		close(notification)
	end);

	task.wait(4)
	close(notification)
end

-- Button events
inviteRemote.OnClientEvent:Connect(open)
