local module = {}

local players = game:GetService("Players")
local player = players.LocalPlayer

--// GUI
local UI = player.PlayerGui:WaitForChild("Main").Invite
local sFrame = UI.Frame.ScrollingFrame
local card = game.ReplicatedStorage.GUI.EntryTemplate

--// Remotes
local re = game.ReplicatedStorage.Remotes.RemoteEvents
local remote = re.Invite
local updateEvent = re.UpdateParty

function clearoldPLayers()
	for _, v in sFrame:GetChildren() do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
end

function getPlayerIcon(char)
	local userId = char.UserId
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size420x420
	return players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
end

function createCard(char)
	local Newcard = card:clone()
	local info = Newcard.Info
	local icon = getPlayerIcon(char)
	info.ImageLabel.Image = icon
	info.PlayerName.Text = char.Name
	Newcard.Invite.Activated:Connect(function()
		if Newcard.Invite.Text == "INVITE" then
			remote:FireServer(info.PlayerName.Text)
			Newcard.Invite.Text = "SENDING"
			Newcard.Invite.BackgroundColor3 = Color3.new(71 / 255 * 0.5, 162 / 255 * 0.5, 255 / 255 * 0.5)
			task.wait(5)
			if Newcard.Invite.Text == "SENDING" then
				Newcard.Invite.Text = "INVITE"
			end
			Newcard.Invite.BackgroundColor3 = Color3.fromRGB(71, 162, 255)
		end
	end)
	return Newcard
end

function updatePlayers()
	clearoldPLayers()
	for _, v in players:GetChildren() do
		if player ~= v then
			local playerCard = createCard(v)
			playerCard.Parent = sFrame
		end
	end
end

function newParty(partyMembers)
	updatePlayers()
	for index in partyMembers do
		for _, v in sFrame:GetChildren() do
			if v:IsA("Frame") then
				if partyMembers[index].Name == v.Info.PlayerName.Text then
					v.Invite.Text = "IN PARTY"
				end
			end
		end
	end
end

updatePlayers()
updateEvent.OnClientEvent:Connect(newParty)
players.PlayerAdded:Connect(updatePlayers)

return module
