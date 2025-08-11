local module = {}
local HttpService = game:GetService("HttpService")

--local update = "https://robloxtop50gamesapi.onrender.com/update"
local gameList = "https://robloxtop50gamesapi.onrender.com/games"

local function getAPIData()
	local data = HttpService:GetAsync(gameList)
	module.allGames = HttpService:JSONDecode(data)
end

task.spawn(function()
	while true do
		getAPIData()
		task.wait(21600)
	end
end)

local count = 0

module.move = function(char)
	repeat
		task.wait(0.1)
		if count > 50 then
			getAPIData()
		end
	until module.allGames

	count = 0

	module.theGame = module.allGames[math.random(1, #module.allGames)]

	local player = game.Players[char.Name]
	local TeleportService = game:GetService("TeleportService")

	local sucsess = pcall(function()
		TeleportService:TeleportAsync(module.theGame, { player })
	end)
	if not sucsess then
		module.move(char)
	end
end

return module
