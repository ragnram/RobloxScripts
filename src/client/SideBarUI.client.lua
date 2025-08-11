--!strict

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local screenGUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")
local invitePanel = screenGUI:WaitForChild("Invite")
local shopPanel = screenGUI:WaitForChild("Shop")
local inventory = screenGUI:WaitForChild("Inventory")

local ui = screenGUI:WaitForChild("Sidebar")

-- Tween settings
local slideTime = 0.3
local easingStyle = Enum.EasingStyle.Quad
local easingOut = Enum.EasingDirection.Out
local easingIn = Enum.EasingDirection.In

-- Store original positions
local inviteVisiblePos = invitePanel.Position
local shopVisiblePos = shopPanel.Position
local inventoryPos = inventory.Position

-- Calculate hidden position by offsetting to the left
local function getHiddenPos(panel)
	return UDim2.new(-1, 0, panel.Position.Y.Scale, panel.Position.Y.Offset)
end

-- Move panels off-screen initially
invitePanel.Position = getHiddenPos(invitePanel)
invitePanel.Visible = false

shopPanel.Position = getHiddenPos(shopPanel)
shopPanel.Visible = false

inventory.Position = getHiddenPos(inventory)
inventory.Visible = false

-- Tween helper
local function tweenPanel(panel, targetPos, easing, onComplete)
	local tween = TweenService:Create(panel, TweenInfo.new(slideTime, easingStyle, easing), { Position = targetPos })
	tween:Play()
	if onComplete then
		tween.Completed:Once(onComplete)
	end
end

local function open(panel, targetPos)
	panel.Visible = true
	tweenPanel(panel, targetPos, easingOut)
end

local function close(panel)
	tweenPanel(panel, getHiddenPos(panel), easingIn, function()
		panel.Visible = false
	end)
end

local function openInvitePanel()
	if invitePanel.Visible then
		close(invitePanel)
	else
		close(shopPanel)
		close(inventory)
		open(invitePanel, inviteVisiblePos)
	end
end

local function openShopPanel()
	if shopPanel.Visible then
		close(shopPanel)
	else
		close(invitePanel)
		close(inventory)
		open(shopPanel, shopVisiblePos)
	end
end

local function openInventory()
	if inventory.Visible then
		close(inventory)
	else
		close(invitePanel)
		close(shopPanel)
		open(inventory, inventoryPos)
	end
end

ui.Shop.Activated:Connect(openShopPanel)
ui.Invite.Activated:Connect(openInvitePanel)
ui.Inventory.Activated:Connect(openInventory)
