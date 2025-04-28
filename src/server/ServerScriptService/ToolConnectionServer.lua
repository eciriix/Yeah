local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Events
local WeldToolEvent = ReplicatedStorage.Events:WaitForChild("ToolConnection")

-- Functions
local function unequipClonedTool(player, clonedTool)
	
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid:UnequipTools(clonedTool)
end

local function equipClonedTool(player, clonedTool)

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid:EquipTool(clonedTool)
end

-- Connect the event
WeldToolEvent.OnServerEvent:Connect(function(player, toolName, shouldWeld)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local hand = character:FindFirstChild("Right Arm")
	if not hand then return end
	
	local toolModel = game.ReplicatedStorage.Weapons:FindFirstChild(toolName)
	if not toolModel then return end

	local toolClone 

	if shouldWeld then
		toolClone = toolModel:Clone()
		if not toolClone then return end
		toolClone.Parent = character
		toolClone.Name = "Temp" .. toolModel.Name 

		local toolGrip = Instance.new("Motor6D")
		toolGrip.Name = "ClonedToolGrip"
		toolGrip.Part0 = character["Right Arm"]
		toolGrip.Part1 = toolClone.BodyAttach
		toolGrip.Parent = character["Right Arm"]

	else
		local toolGrip = character["Right Arm"]:FindFirstChild("ClonedToolGrip")
		if toolGrip then
			toolGrip:Destroy()
		end

		local clonedTool = character:FindFirstChild("Temp" .. toolName)
		if clonedTool then
			clonedTool:Destroy()
		end

		local backpackClonedTool = player.Backpack:FindFirstChild("Temp" .. toolName)
		if backpackClonedTool then
			backpackClonedTool:Destroy()
		end
	end
end)

