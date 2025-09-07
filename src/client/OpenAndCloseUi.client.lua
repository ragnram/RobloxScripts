--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local screenGUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")
local invitePanel = screenGUI:WaitForChild("Invite")
local shopPanel = screenGUI:WaitForChild("Shop")
local inventory = screenGUI:WaitForChild("Inventory")
local setting = screenGUI:WaitForChild("Settings")
local ui = screenGUI:WaitForChild("Sidebar")
local wheel = screenGUI:WaitForChild("EmoteWheel")

-- Tween settings
local slideTime = 0.3
local easingStyle = Enum.EasingStyle.Quad
local easingOut = Enum.EasingDirection.Out
local easingIn = Enum.EasingDirection.In

-- Store original positions
local inviteVisiblePos = invitePanel.Position
local shopVisiblePos = shopPanel.Position
local inventoryPos = inventory.Position
local SettingsPos = setting.Position
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
		wheel.Visible = false
		close(shopPanel)
		close(inventory)
		close(setting)
		open(invitePanel, inviteVisiblePos)
	end
end

local function openShopPanel()
	if shopPanel.Visible then
		close(shopPanel)
	else
		wheel.Visible = false
		close(invitePanel)
		close(inventory)
		close(setting)
		open(shopPanel, shopVisiblePos)
	end
end

local function openInventory()
	if inventory.Visible then
		close(inventory)
	else
		wheel.Visible = false
		close(invitePanel)
		close(shopPanel)
		close(setting)
		open(inventory, inventoryPos)
	end
end
local function openSettingsPanel()
	if setting.Visible then
		close(setting)
	else
		wheel.Visible = false
		close(invitePanel)
		close(inventory)
		close(shopPanel)
		open(setting, SettingsPos)
	end
end

--// Events
ui.Shop.Activated:Connect(openShopPanel)
ui.Invite.Activated:Connect(openInvitePanel)
ui.Inventory.Activated:Connect(openInventory)
ui.Settings.Activated:Connect(openSettingsPanel)
invitePanel.Exit.Activated:Connect(openInvitePanel)
shopPanel.Exit.Activated:Connect(openShopPanel)
setting.Exit.Activated:Connect(openSettingsPanel)
inventory.Exit.Activated:Connect(openInventory)
