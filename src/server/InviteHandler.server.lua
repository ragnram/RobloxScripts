--// Module \\--
local InviteModule = {}

--// Services \\--
local Players = game:GetService("Players")

--// Variable \\--
local remotes = game.ReplicatedStorage.Remotes.RemoteEvents
local remotePartyUpdate = remotes.UpdateParty
local parties = {}

--// Local Functions
local function playerReady(char)
	for i in parties do
		for player in parties[i] do
			if parties[i][player] == char then
				remotePartyUpdate:FireClient(char, parties[i])
			end
		end
	end
end

local function sendInvite(player, send)
	remotes.Invite:FireClient(players[send], player)
end

local function addToParty(player, host)
	local theHost = players[host]
	InviteModule.removed(player)
	for number, party in parties do
		for _, member in party do
			if theHost == member then
				table.insert(parties[number], player)
				for _, v in parties[number] do
					remotePartyUpdate:FireClient(v, parties[number])
				end
			end
		end
	end
end

local function kickPlayer(host, player)
	InviteModule.removed(player)
	InviteModule.added(player)
end

--// Module Functions
function InviteModule.removed(char)
	for partyNumber, v in parties do
		for index, player in v do
			if player == char then
				if #v == 1 then
					parties[partyNumber] = nil
				else
					table.remove(parties[partyNumber], index)
					for _ in parties[partyNumber] do
						remotePartyUpdate:FireClient(v, parties[partyNumber])
					end
				end
			end
		end
	end
end

function InviteModule.added(char: Player)
	table.insert(parties, { char })
	remotePartyUpdate:FireClient(char, { char })
end

--// Events
remotes.kick.OnServerEvent:Connect(kickPlayer)
remotes.Invite.OnServerEvent:Connect(sendInvite)
remotes.AddToParty.OnServerEvent:Connect(addToParty)
remotes.ScriptsReady.OnServerEvent:Connect(playerReady)
Players.PlayerAdded:Connect(InviteModule.added)
Players.PlayerRemoving:Connect(InviteModule.removed)

return InviteModule
