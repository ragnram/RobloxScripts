local Module = {}
local ragdallEvent = game.ReplicatedStorage.Remotes.RemoteEvents.Ragdoll

local lastHit = {}

Module.Check = function(t)
	for _, v in pairs({ "LeftWrist", "RightWrist", "LeftAnkle", "RightAnkle", "Neck" }) do
		if v == t then
			return false
		end
	end
	return true
end

Module.Joints = function(c)
	c.Humanoid.BreakJointsOnDeath = false
	c.Humanoid.RequiresNeck = false
	for _, v in pairs(c:GetDescendants()) do
		if v:IsA("Motor6D") and Module.Check(v.Name) then
			local b = Instance.new("BallSocketConstraint")
			b.Parent = v.Parent
			local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
			a0.Parent, a1.Parent = v.Part0, v.Part1
			b.Attachment0, b.Attachment1 = a0, a1
			a0.CFrame, a1.CFrame = v.c0, v.c1
			b.LimitsEnabled = true
			b.TwistLimitsEnabled = true
			b.Enabled = false
		elseif v:IsA("BasePart") then
			v.CollisionGroup = "A"
			if v.Name == "HumanoidRootPart" then
				v.CollisionGroup = "B"
			elseif v.Name == "Head" then
				v.CanCollide = true
			end
		end
	end
end

Module.Ragdoll = function(char, bool)
	local plr = game.Players:GetPlayerFromCharacter(char)
	if
		char.Humanoid.Health ~= 0
		and ((char:FindFirstChild("LowerTorso") and not char.LowerTorso.Root.Enabled) or (char:FindFirstChild("Torso") and not char.Torso.Neck.Enabled))
		and not bool
	then
		ragdallEvent:FireClient(plr, false)
		for _, bodyPart in pairs(char:GetDescendants()) do
			if bodyPart:IsA("Motor6D") then
				bodyPart.Enabled = true
			elseif bodyPart:IsA("BallSocketConstraint") then
				bodyPart.Enabled = false
			end
		end
	else
		ragdallEvent:FireClient(plr, true)
		for _, bodyPart in pairs(char:GetDescendants()) do
			if bodyPart:IsA("Motor6D") and Module.Check(bodyPart.Name) then
				bodyPart.Enabled = false -- this moves all the parts that are connected to somewhere else
			elseif bodyPart:IsA("BallSocketConstraint") then
				bodyPart.Enabled = true
			elseif bodyPart.Name == "Head" then
				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.Parent = char.head
				BodyVelocity.Velocity = Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
				task.spawn(function()
					wait(0.1)
					BodyVelocity:Destroy()
				end)
			end
		end
	end
end

Module.Bot = function(bot)
	task.spawn(function()
		local StopOverLap = tick() + 3
		lastHit[bot] = StopOverLap

		local plr = game.Players:GetPlayerFromCharacter(bot)
		local H = bot.Humanoid

		if plr then
			ragdallEvent:FireClient(plr, true)
		end

		bot.HumanoidRootPart:SetNetworkOwner(nil)
		if
			bot:FindFirstChild("HumanoidRootPart")
			and H.Health ~= 0
			and bot:FindFirstChild("LowerTorso")
			and bot.LowerTorso.Root.Enabled == true
		then
			H:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
			H:ChangeState(Enum.HumanoidStateType.Ragdoll)
			for _, v in pairs(H:GetPlayingAnimationTracks()) do
				v:Stop(0)
			end
			bot.Animate.Disabled = true

			for _, v in pairs(bot:GetDescendants()) do
				if v:IsA("Motor6D") and Module.Check(v.Name) then
					v.Enabled = false
				elseif v:IsA("BallSocketConstraint") then
					v.Enabled = true
				end
			end

			repeat
				task.wait()
				if math.randomseed(StopOverLap) ~= math.randomseed(lastHit[bot]) then
					return
				end
			until lastHit[bot] < tick()

			if plr then
				ragdallEvent:FireClient(plr, false)
			end

			bot.Animate.Disabled = false
			H:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
			H:ChangeState(Enum.HumanoidStateType.GettingUp)

			for _, v in pairs(bot:GetDescendants()) do
				if v:IsA("Motor6D") then
					v.Enabled = true
				elseif v:IsA("BallSocketConstraint") then
					v.Enabled = false
				end
			end
		end
	end)
end

return Module
