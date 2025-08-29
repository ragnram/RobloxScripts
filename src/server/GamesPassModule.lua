--// Module \\--
local GamePassModule = {}

--// Services \\--
local MarketplaceService = game:GetService("MarketplaceService")

--// Varubles \\--
local pendingPurchases = {}

--// Local Functions \\--

local function CompletePerchase(player, _, wasPurchased)
	if wasPurchased then
		pendingPurchases[player.UserId] = true
	end
end

function WaitForPurchase(player)
	local userId = player.UserId
	pendingPurchases[userId] = false

	local start = tick()
	while tick() - start < 30 do -- timeout after 30 seconds
		if pendingPurchases[userId] == true then
			pendingPurchases[userId] = nil
			return true
		elseif pendingPurchases[userId] == "cancelled" then
			pendingPurchases[userId] = nil
			return false
		end
		task.wait(0.2)
	end

	pendingPurchases[userId] = nil
	return false
end

local function MakeReceipt(player, gamePassId)
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		if player.UserId == receiptInfo.PlayerId then
			if receiptInfo.ProductId == gamePassId and pendingPurchases[player.UserId] ~= nil then
				pendingPurchases[player.UserId] = true
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

--// Module Functions \\--
GamePassModule.getGamePass = function(player, gamePassId)
	MakeReceipt(player, gamePassId)

	MarketplaceService:PromptGamePassPurchase(player, gamePassId)

	return WaitForPurchase(player)
end

GamePassModule.getDevProduct = function(player, productId)
	MakeReceipt(player, productId)

	MarketplaceService:PromptProductPurchase(player, productId)

	return WaitForPurchase(player)
end

--// Events \\--
MarketplaceService.PromptGamePassPurchaseFinished:Connect(CompletePerchase)
MarketplaceService.PromptProductPurchaseFinished:Connect(CompletePerchase)

--// Return Statement \\--
return GamePassModule
