--!strict
local StarterGui = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")

local attributes = {
	Resolution = {
		is = "Vector2",
		default = Vector2.new(1280, 720),
	},
	ScaleRange = {
		is = "NumberRange",
		default = NumberRange.new(0, math.huge),
	},
}

type scaleInfo = {
	listener: listener,

	signals: { RBXScriptConnection }?,
	text_constraints: { UITextSizeConstraint },
}

type listener = {
	source: Instance,

	signal: RBXScriptConnection,
	scales: {
		[UIScale]: scaleInfo,
	},
}

local absoluteSizeListeners = {} :: { [Instance]: listener }
local scaleToInfoMap = {} :: { [UIScale]: scaleInfo }

local function removeFromList(list: { any }, value: any)
	local index = table.find(list, value)

	if index then
		table.remove(list, index)
	end
end

local function update(scale: UIScale)
	if not scale:IsA("UIScale") or scale:IsDescendantOf(StarterGui) then
		return
	end

	local params = {} :: {
		Resolution: Vector2,
		ScaleRange: NumberRange,
	}

	for key, data in pairs(attributes) do
		local value = scale:GetAttribute(key)

		if typeof(value) ~= data.is then
			value = data.default
			warn(`no '{key}' attribute found for {scale:GetFullName()}, using '{data.default}' instead`)
		end

		params[key] = value
	end

	if not scale.Parent then
		return
	end

	local gui = scale.Parent:FindFirstAncestorWhichIsA("GuiBase2d")

	local size, monitorInstance

	if not gui or (gui:IsA("ScreenGui") and (gui.IgnoreGuiInset or gui.ScreenInsets == Enum.ScreenInsets.None)) then
		size = workspace.CurrentCamera.ViewportSize
		monitorInstance = workspace.CurrentCamera
	else
		size = gui.AbsoluteSize
		monitorInstance = gui
	end

	local listener = absoluteSizeListeners[monitorInstance]

	if not listener then
		local newListener
		newListener = {
			source = monitorInstance,
			scales = {},

			signal = monitorInstance
				:GetPropertyChangedSignal(monitorInstance:IsA("Camera") and "ViewportSize" or "AbsoluteSize")
				:Connect(function()
					for scale in newListener.scales do
					update(scale)
				end
				end),
		}

		listener = newListener
		absoluteSizeListeners[monitorInstance] = listener
	end

	local scaleInfo = listener.scales[scale]

	if not scaleInfo then
		local newScaleInfo = {
			listener = listener,

			signals = {},
			text_constraints = {},
		}

		listener.scales[scale] = newScaleInfo
		scaleToInfoMap[scale] = newScaleInfo

		if gui then
			local function setupCleanup(obj: UITextSizeConstraint)
				local conn
				conn = obj.AncestryChanged:Connect(function()
					if obj:IsDescendantOf(gui) then
						return
					end

					removeFromList(newScaleInfo.signals, conn)
					removeFromList(newScaleInfo.text_constraints, obj)

					print(newScaleInfo)
				end)

				table.insert(newScaleInfo.signals, conn)
			end

			for _, desc in gui:GetDescendants() do
				if not desc:IsA("UITextSizeConstraint") then
					continue
				end

				table.insert(newScaleInfo.text_constraints, desc)

				desc:SetAttribute("__uitools_reference_range", NumberRange.new(desc.MinTextSize, desc.MaxTextSize))

				setupCleanup(desc)
			end

			table.insert(
				newScaleInfo.signals,
				gui.DescendantAdded:Connect(function(desc)
					if not desc:IsA("UITextSizeConstraint") then
						return
					end

					table.insert(newScaleInfo.text_constraints, desc)

					local ref = desc:GetAttribute("__uitools_reference_range")

					if typeof(ref) == "NumberRange" then
						desc.MinTextSize = ref.Min * scale.Scale
						desc.MaxTextSize = ref.Max * scale.Scale
					end

					setupCleanup(desc)
				end)
			)
		end

		scaleInfo = newScaleInfo
	end

	local axis = size.Y < size.X and size.Y or size.X

	local reference = 1
		/ params.Resolution.Y
		* math.clamp(1 / params.Resolution.X * size.X / (1 / params.Resolution.Y * axis), 0, 1)

	scale.Scale = math.clamp(reference * axis, params.ScaleRange.Min, params.ScaleRange.Max)

	if not plugin then
		for _, obj in scaleInfo.text_constraints do
			local ref = obj:GetAttribute("__uitools_reference_range")

			if typeof(ref) ~= "NumberRange" then
				continue
			end

			obj.MinTextSize = ref.Min * scale.Scale
			obj.MaxTextSize = ref.Max * scale.Scale
		end
	end
end

local function updateAll()
	for _, obj in CollectionService:GetTagged("UIScaleRuntimeObject") do
		if not obj:IsA("UIScale") then
			continue
		end

		update(obj)
	end
end

updateAll()

local function cleanupScale(scale: UIScale)
	if not scale:IsA("UIScale") then
		return
	end

	local scaleInfo = scaleToInfoMap[scale]

	if not scaleInfo then
		return
	end

	scale.Scale = 1

	scaleToInfoMap[scale] = nil

	if scaleInfo.signals then
		for _, conn in scaleInfo.signals do
			conn:Disconnect()
		end
	end

	scaleInfo.listener.scales[scale] = nil

	if next(scaleInfo.listener.scales) == nil then
		scaleInfo.listener.signal:Disconnect()
		absoluteSizeListeners[scaleInfo.listener.source] = nil
	end
end

CollectionService:GetInstanceAddedSignal("UIScaleRuntimeObject"):Connect(update)
CollectionService:GetInstanceRemovedSignal("UIScaleRuntimeObject"):Connect(cleanupScale)
