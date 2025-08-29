--// Services \\--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--// Varubles \\--
local getEmotes = ReplicatedStorage.Remotes.RemoteFunction.GiveEquippedEmotes
local player = Players.LocalPlayer
local playerGui = player.PlayerGui
local emotePannel = playerGui:WaitForChild("Main").EmoteWheel
local emotes = {}
local character = player.Character or player.CharacterAdded:Wait()
local humanoid: Humanoid = character:WaitForChild("Humanoid")
local loadedAnimtions = {}
local animtionInstances = {}
--// Local Functions \\--

local function OpenEmotePannel()
	emotePannel.Visible = true
	emotes = getEmotes:InvokeServer()
	print(emotes)
	table.clear(animtionInstances)
	for _, emote in ReplicatedStorage.ShopAssests.Emotes:GetChildren() do
		for index in emotes do
			if emotes[index] == emote.Name then
				local image = emote:GetAttribute("Image")
				local icon: ImageButton = emotePannel.EmoteWheel_Image[index]
				icon.Image = image
				local animtionInstance = Instance.new("Animation")
				table.insert(animtionInstances, animtionInstance)
				animtionInstance.AnimationId = emote:GetAttribute("Animation")
				loadedAnimtions[index] = humanoid:LoadAnimation(animtionInstance)
				break
			end
		end
	end
end

local function PlayerEmote(index)
	if emotes[index] then
		loadedAnimtions[index]:Play()
	end
	emotePannel.Visible = false
end

--// Events \\--
for index in emotePannel.EmoteWheel_Image:GetChildren() do
	(emotePannel.EmoteWheel_Image[index] :: GuiButton).Activated:Connect(function()
		PlayerEmote(index)
	end)
end
OpenEmotePannel()
