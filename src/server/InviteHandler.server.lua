local module = {}
local players = game:GetService("Players")
local rm = game.ReplicatedStorage.Remotes.RemoteEvents
local remote = rm.Invite
local addToPartyRemote = rm.AddToParty
local remotePartyUpdate = rm.UpdateParty
local remotekick = rm.kick
local scriptReady = rm.ScriptsReady
local parties = {}

function module.added(char: Player)
	table.insert(parties, { char })
	remotePartyUpdate:FireClient(char, { char })
end

function playerReady(char)
	for i in parties do
		for player in parties[i] do
			if parties[i][player] == char then
				remotePartyUpdate:FireClient(char, parties[i])
			end
		end
	end
end

function module.removed(char)
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

function sendInvite(player, send)
	remote:FireClient(players[send], player)
end

function addToParty(player, host)
	local theHost = players[host]
	module.removed(player)
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

function kickPlayer(host, player)
	module.removed(player)
	module.added(player)
end

remotekick.OnServerEvent:Connect(kickPlayer)
remote.OnServerEvent:Connect(sendInvite)
addToPartyRemote.OnServerEvent:Connect(addToParty)
scriptReady.OnServerEvent:Connect(playerReady)
players.PlayerAdded:Connect(module.added)
players.PlayerRemoving:Connect(module.removed)

return module
