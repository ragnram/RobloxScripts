--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local TouchInputService = game:GetService("TouchInputService")
local TweenService = game:GetService("TweenService")
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
local defaulatDotPosition = dot.Position
local mouse = player:GetMouse()
local selectedGui
local colorSetting = innerFrame.Options
local clickedOnItem
local tabsPosition = innerFrame.Tabs.Position
local defauleDisplay = innerFrame.DefaultDisplay
local containerSize = container.Size
local equipEmotes = inventoryGui.EquipEmotes
local equipButton = defauleDisplay.Equip
local questButton = defauleDisplay.Quests
local lastTab
--// Local Functions

local function SetEquipButtonToEquip()
	equipButton.BackgroundColor3 = Color3.new(1, 1, 1)
	equipButton.UIGradient.Enabled = true
	equipButton.TextLabel.Text = "EQUIP"
end

local function SetEquipButtonToEquipped()
	equipButton.TextLabel.Text = "EQUIPPED"
	equipButton.BackgroundColor3 = Color3.new(0.564706, 0.564706, 0.564706)
	equipButton.UIGradient.Enabled = false
end

local function IsEmptySlote()
	for _, frame in equipEmotes.EmoteFrameContainer:GetChildren() do
		if frame:IsA("Frame") and frame.Visible == true and frame.Background.EmoteName.Text == selectedGui[name] then
			SetEquipButtonToEquipped()
			return nil
		end
	end

	for _, frame in equipEmotes.EmoteFrameContainer:GetChildren() do
		if frame:IsA("Frame") and frame.Visible == false then
			SetEquipButtonToEquip()
			return frame
		end
	end
	SetEquipButtonToEquipped()
	return nil
end

local function ResetColorWheel()
	colorSetting.Visible = false
	dot.Position = defaulatDotPosition
end

local function OpenDropDown()
	if dropDownMenu.Visible == true then
		dropDownMenu.Visible = false
	else
		dropDownMenu.Visible = true
	end
end

local function ChangeColour()
	colorSetting.Visible = true
	dot.Position = defaulatDotPosition
end

local function SetDeafultDisplay(frameObject)
	selectedGui = frameObject
	defauleDisplay.Visible = true
	defauleDisplay.ItemDescription.Text = frameObject[description]
	defauleDisplay.ItemName.Text = frameObject[name]

	SetEquipButtonToEquip()
	IsEmptySlote()
end

local function OpenTab(itemType)
	ResetColorWheel()
	lastTab = itemType
	equipEmotes.Visible = false
	defauleDisplay.Visible = false
	for _, button in container.DefaultScroller.ScrollingFrame:GetChildren() do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	content = getInventoryRemoteFunction:InvokeServer()

	sortModule.sort(filter, content)
	for index in content do
		local object = content[index]
		if object[itemtype] == itemType then
			local frame = itemFrame:Clone()
			frame.Parent = container.DefaultScroller.ScrollingFrame
			frame.ItemRarity.ItemRarity.Text = object[rarity] or ""
			frame.DisplayImage.Image = object[image]
			frame.ItemName.Text = object[name]
			frame.Activated:Connect(function()
				clickedOnItem = frame
				ResetColorWheel()
				SetDeafultDisplay(object)
			end)
			frame.DisplayImage.ChangeColor.Activated:Connect(ChangeColour)
			if defauleDisplay.Visible == false then
				SetDeafultDisplay(object)
				clickedOnItem = frame
			end
		end
	end
end

local function ChangeType(self)
	ResetColorWheel()
	filter = self.Name
	self.Parent.Visible = false
	OpenTab(lastTab)
end

local function GetEquippedEmotes()
	local equippedEmotes = ReplicatedStorage.Remotes.RemoteFunction.GiveEquippedEmotes:InvokeServer()
	for index in equippedEmotes do
		for _, frame in equipEmotes.EmoteFrameContainer:GetChildren() do
			if frame:IsA("Frame") and frame.Visible == false then
				frame.Visible = true
				frame.Background.EmoteName.Text = equippedEmotes[index]
				break
			end
		end
	end
end
local function EmotesTab()
	OpenTab("Emotes")
	equipEmotes.Visible = true
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
		-- if gui[1] == selectedGui then
		-- 	selectedGui = nil
		-- end
	end
end

local function MoveGui()
	-- if selectedGui== dot then
	-- 	local mousePos = Vector2.new(mouse.X, mouse.Y)
	-- 	local guiInset = GuiService:GetGuiInset() -- Top bar offset

	-- 	local parentAbs = dot.Parent.AbsolutePosition

	-- 	local adjustedMouse = mousePos - guiInset

	-- 	local relativePos = adjustedMouse - parentAbs
	-- 	local centeredPos = relativePos - (dot.AbsoluteSize / 2)

	-- 	dot.Position = UDim2.new(0, centeredPos.X, 0, centeredPos.Y)
	-- end
end

local function ChangePannel()
	if colorSetting.Visible then
		defauleDisplay.Visible = false
	else
		defauleDisplay.Visible = true
	end
end

local function RotateIcon(x, y, z)
	for i = x, y, z do
		task.wait()
		innerFrame.ToggleSidebar.Rotation = i
	end
end

local function TweenTabs(offset)
	local NewUiPositin = { Position = tabsPosition - UDim2.new(0, offset, 0, 0) }
	local tweenTime = TweenInfo.new(0.5)
	local theTween = TweenService:Create(innerFrame.Tabs, tweenTime, NewUiPositin)
	theTween:Play()
end

local function ExpandContainer(offset)
	local NewUiPositin = {
		Size = containerSize + UDim2.new(0, offset, 0, 0),
	}
	local tweenTime = TweenInfo.new(0.5)
	local theTween = TweenService:Create(container, tweenTime, NewUiPositin)
	theTween:Play()
end

local function ToggleSidebarEvent()
	if innerFrame.ToggleSidebar.Rotation == 0 then
		task.spawn(function()
			RotateIcon(0, 180, 18)
		end)
		task.spawn(function()
			TweenTabs(500)
		end)
		ExpandContainer(130)
	elseif innerFrame.ToggleSidebar.Rotation == 180 then
		task.spawn(function()
			RotateIcon(180, 0, -18)
		end)
		task.spawn(function()
			TweenTabs(0)
		end)
		ExpandContainer(0)
	end
end

local function CloseEquipEmotes()
	equipEmotes.Visible = false
end

local function RemoveEquiptedEmote(frame)
	frame.Visible = false
	if selectedGui[name] == frame.Background.EmoteName.Text then
		SetEquipButtonToEquip()
	end
	ReplicatedStorage.Remotes.RemoteEvents.EquippedEmotes:FireServer(frame.Background.EmoteName.Text, false)
end

local function EquipEmote()
	equipEmotes.Visible = true
	local freeSpace = IsEmptySlote()
	if freeSpace then
		ReplicatedStorage.Remotes.RemoteEvents.EquippedEmotes:FireServer(selectedGui[name], true)
		freeSpace.Background.EmoteName.Text = selectedGui[name]
		freeSpace.Visible = true
		IsEmptySlote()
	else
		equipButton.TextLabel.Text = "FULL"
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
colorSetting.Changed:Connect(ChangePannel)
innerFrame.ToggleSidebar.Activated:Connect(ToggleSidebarEvent)
equipButton.Activated:Connect(EquipEmote)
equipEmotes.Header.Exit.Activated:Connect(CloseEquipEmotes)
for _, filterType in dropDownMenu:GetChildren() do
	if filterType:IsA("GuiButton") then
		filterType.Activated:Connect(function()
			ChangeType(filterType)
		end)
	end
end
for _, emoteFrame in equipEmotes.EmoteFrameContainer:GetChildren() do
	if emoteFrame:IsA("Frame") then
		emoteFrame.Background.Unequip.Activated:Connect(function()
			RemoveEquiptedEmote(emoteFrame)
		end)
	end
end

--// Calls
EmotesTab()
colorSetting.Visible = false

GetEquippedEmotes()
