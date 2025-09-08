--// Services \\--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
--// Varubles \\--
local getEmotes = ReplicatedStorage.Remotes.RemoteFunction.GiveEquippedEmotes
local player = Players.LocalPlayer
local playerGui = player.PlayerGui
local emotePannel = playerGui:WaitForChild("Main").EmoteWheel
local emotes = {}
local character = player.Character or player.CharacterAdded:Wait()
local humanoid: Humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")
local loadedAnimtions = {}
local animtionInstances = {}
--// Local Functions \\--

local function OpenEmotePannel()
	emotePannel.Visible = true
	emotes = getEmotes:InvokeServer()
	table.clear(animtionInstances)
	for _, emote in ReplicatedStorage.ShopAssests.Emotes:GetChildren() do
		for index in emotes do
			if emotes[index] == emote.Name then
				-- Set Icon
				local icon: ImageButton = emotePannel.EmoteWheel_Image[index]
				local imageid = "rbxassetid://" .. emote:GetAttribute("Image")

				icon.Image = imageid
				-- Load Animation
				local animationController = animator :: Animator
				-- Create and load an animation
				local animation = Instance.new("Animation")
				animation.AnimationId = "rbxassetid://" .. emote:GetAttribute("Animation") -- Roblox dance emote
				local animationTrack = animationController:LoadAnimation(animation)
				table.insert(animtionInstances, animation)
				loadedAnimtions[index] = animationTrack
				break
			end
		end
	end
end

local function PlayerEmote(index)
	emotePannel.Visible = false
	if emotes[index] then
		loadedAnimtions[index]:Play()
	end
end

--// Events \\--
for index in emotePannel.EmoteWheel_Image:GetChildren() do
	(emotePannel.EmoteWheel_Image[index] :: GuiButton).Activated:Connect(function()
		PlayerEmote(index)
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.B then
		if emotePannel.Visible then
			emotePannel.Visible = false
		else
			OpenEmotePannel()
		end
	end
end)
