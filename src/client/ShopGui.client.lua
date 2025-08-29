--!strict
local ShopModule = {}

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local algorithms = require(ReplicatedStorage.Algorithms)

--// Varubles
local playerGui = Players.LocalPlayer.PlayerGui
local shopGui = playerGui:WaitForChild("Main").Shop
local tabs = shopGui.Tabs
local featuredTab = shopGui.FeaturedTab
local defaultShop = shopGui.DefaultShop
local buyButton = defaultShop.ItemDisplay.Buy
local selectedItem
local buyButtonColor = buyButton.BackgroundColor3

--// Local Functions
local function ChangeTab(CloseTab, OpenTab)
	for _, frame: Frame in CloseTab:GetChildren() do
		frame.Visible = false
	end
	for _, frame: Frame in OpenTab:GetChildren() do
		frame.Visible = true
	end
end

local function ChangeButtonStyle(style: string)
	if style == "owned" then
		buyButton.TextLabel.Text = "OWNED"
		buyButton.UIGradient.Enabled = false
		buyButton.BackgroundColor3 = Color3.new(1, 0.94902, 0)
	elseif style == "buy" then
		buyButton.TextLabel.Text = "BUY"
		buyButton.BackgroundColor3 = buyButtonColor
		buyButton.UIGradient.Enabled = true
	elseif style == "fail" then
		buyButton.TextLabel.TextScaled = true
		buyButton.TextLabel.Text = "Get More Money"
		buyButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		buyButton.UIGradient.Enabled = false
		task.wait(1)
		buyButton.TextLabel.TextScaled = false
		buyButton.TextLabel.Text = "BUY"
		buyButton.UIGradient.Enabled = true
		buyButton.BackgroundColor3 = buyButtonColor
	end
end
local function GetItems(folder)
	for _, Ui in defaultShop.ScrollingFrame:GetChildren() do
		if Ui:IsA("TextButton") then
			Ui:Destroy()
		end
	end
	local undwartedItems = folder:GetChildren()
	algorithms.quicksort(undwartedItems, 1, #undwartedItems)
	for Index, Item: Model in undwartedItems do
		local price = Item:GetAttribute("Price")
		local image = Item:GetAttribute("Image")
		local name = Item.Name
		local description = Item:GetAttribute("Description")
		local frame = ReplicatedStorage.GUI.Item:Clone()
		frame.Parent = defaultShop.ScrollingFrame
		frame.ItemName.Text = name
		frame.ItemPrice.Text = price
		frame.DisplayImage.Image = image

		local display = defaultShop.ItemDisplay

		local function SetDisplay()
			local invontory = ReplicatedStorage.Remotes.RemoteFunction.GetInventory:InvokeServer()
			display.ItemName.Text = name
			display.ItemDescription.Text = description
			selectedItem = Item
			ChangeButtonStyle("buy")
			for index in invontory do
				if invontory[index][1] == name then
					ChangeButtonStyle("owned")
					break
				end
			end
		end

		frame.Activated:Connect(SetDisplay)

		if Index == 1 then
			SetDisplay()
		end
	end
end

local function OpenAurasTab()
	ChangeTab(featuredTab, defaultShop)
	GetItems(ReplicatedStorage.ShopAssests.Auras)
end

local function OpenEmotesTab()
	ChangeTab(featuredTab, defaultShop)
	GetItems(ReplicatedStorage.ShopAssests.Emotes)
end

local function OpenFeaturedTab()
	ChangeTab(defaultShop, featuredTab)
end

local function OpenMountsTab()
	ChangeTab(featuredTab, defaultShop)
	GetItems(ReplicatedStorage.ShopAssests.Mounts)
end

local function Close()
	repeat
		task.wait()
	until shopGui.Visible == false
	ChangeTab(defaultShop, featuredTab)
end

local function BuySelected()
	if buyButton.TextLabel.Text == "BUY" then
		if game.ReplicatedStorage.Remotes.RemoteFunction.BuyItem:InvokeServer(selectedItem) then
			ChangeButtonStyle("owned")
		else
			ChangeButtonStyle("fail")
		end
	end
end

--// Events
shopGui.Exit.Activated:Connect(Close)
tabs.Auras.Activated:Connect(OpenAurasTab)
tabs.Emotes.Activated:Connect(OpenEmotesTab)
tabs.Featured.Activated:Connect(OpenFeaturedTab)
tabs.Mounts.Activated:Connect(OpenMountsTab)
buyButton.Activated:Connect(BuySelected)

return ShopModule
