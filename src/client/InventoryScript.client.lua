--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

--// Modules
local sortModule = require(ReplicatedStorage.SortModule)

--// Varubles
local name = 1
local price = 2
local itemtype = 3
local image = 4
local description = 5
local colour = 6
local rarity = 7
local limited = 8
local filter = "Filter By Name"
local player = Players.LocalPlayer
local inventoryGui = player.PlayerGui:WaitForChild("Main").Inventory
local innerFrame = inventoryGui.InnerFrame
local tabs = innerFrame.Tabs
local container = innerFrame.Container
local dropDownButton = container.DefaultScroller.DropDownButton
local dropDownMenu = dropDownButton.DropDownMenu
local content = {}
local getInventoryRemoteFunction = ReplicatedStorage.Remotes.RemoteFunction.GetInventory
local itemFrame = ReplicatedStorage.GUI.inventoryItem
local dot = innerFrame.Options.DisplayFrame.Dot
local defulatDotPosition = dot.Position
local mouse = player:GetMouse()
local selectedGui
local colorSetting = innerFrame.Options
local clickedOnItem
--// Local Functions

colorSetting.Visible = false
local function ResetColorWheel()
	colorSetting.Visible = false
	dot.Position = defulatDotPosition
end

local function OpenDropDown()
	if dropDownMenu.Visible == true then
		dropDownMenu.Visible = false
	else
		dropDownMenu.Visible = true
	end
end

local function ChangeType(self)
	ResetColorWheel()
	filter = self.Name
end

local function ChangeColour()
	colorSetting.Visible = true
	dot.Position = defulatDotPosition
end

local function OpenTab(itemType)
	ResetColorWheel()
	for _, button in container.DefaultScroller.ScrollingFrame:GetChildren() do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	content = getInventoryRemoteFunction:InvokeServer()

	sortModule.sort(filter, content)

	for object in content do
		if content[object][itemtype] == itemType then
			local frame = itemFrame:Clone()
			frame.Parent = container.DefaultScroller.ScrollingFrame
			frame.ItemRarity.ItemRarity.Text = content[object][rarity] or ""
			frame.DisplayImage.Image = content[object][image]
			frame.ItemName.Text = content[object][name]
			frame.Activated:Connect(function()
				clickedOnItem = frame
				ResetColorWheel()
			end)
			frame.DisplayImage.ChangeColor.Activated:Connect(ChangeColour)
		end
	end
end

local function EmotesTab()
	OpenTab("Emotes")
end

local function AurasTab()
	OpenTab("Auras")
end

local function MountsTab()
	OpenTab("Mounts")
end

local function TitlesTab()
	OpenTab("Titles")
end

local function StartDrag(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local gui = player.PlayerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
		if gui[1] == dot then
			selectedGui = dot
		end
	end
end

local function EndDrag(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local gui = player.PlayerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
		if gui[1] == selectedGui then
			selectedGui = nil
		end
	end
end

local function MoveGui()
	if selectedGui == dot then
		local mousePos = Vector2.new(mouse.X, mouse.Y)
		local guiInset = GuiService:GetGuiInset() -- Top bar offset

		-- Get parent's absolute screen position
		local parentAbs = dot.Parent.AbsolutePosition

		-- Adjust mouse to screen without topbar
		local adjustedMouse = mousePos - guiInset

		-- Convert to local space of parent
		local relativePos = adjustedMouse - parentAbs
		local centeredPos = relativePos - (dot.AbsoluteSize / 2)

		dot.Position = UDim2.new(0, centeredPos.X, 0, centeredPos.Y)
	end
end

--// Events
tabs.Emotes.Activated:Connect(EmotesTab)
tabs.Auras.Activated:Connect(AurasTab)
tabs.Mounts.Activated:Connect(MountsTab)
tabs.Titles.Activated:Connect(TitlesTab)
dropDownButton.Activated:Connect(OpenDropDown)
RunService.RenderStepped:Connect(MoveGui)
UserInputService.InputBegan:Connect(StartDrag)
UserInputService.InputEnded:Connect(EndDrag)

for _, filterType in dropDownMenu:GetChildren() do
	if filterType:IsA("GuiButton") then
		filterType.Activated:Connect(function()
			ChangeType(filterType)
		end)
	end
end
