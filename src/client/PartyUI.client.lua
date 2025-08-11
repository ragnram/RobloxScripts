local module = {}

local UpdateParty = game.ReplicatedStorage.Remotes.RemoteEvents.UpdateParty
local localPlayer = game:GetService("Players").LocalPlayer
local PartyList = localPlayer.PlayerGui:WaitForChild("Main").PartyList
local Container = PartyList.Container

local partylist = {
	Container["1"],
	Container["2"],
	Container["3"],
	Container["4"],
}

function clear()
	for _, cards in partylist do
		cards.Visible = false
	end
end

function addCard(number, player)
	partylist[number].Visible = true
	if partylist[number]:FindFirstChild("PlayerName") then
		partylist[number]:FindFirstChild("PlayerName").Text = player.Name
	end
end

function playerCount(number)
	if PartyList:FindFirstChild("Footer") then
		PartyList.Footer.MemberCount.Text = tostring(number) .. "/4"
	end
end

function updateParty(party)
	clear()
	for i, v in party do
		addCard(i, v)
		playerCount(i)
	end
end

UpdateParty.OnClientEvent:Connect(updateParty)

return module
