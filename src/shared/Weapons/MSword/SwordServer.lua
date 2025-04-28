-- Services
local RS = game:GetService('ReplicatedStorage')
local SoundService = game:GetService('SoundService')
local Debris = game:GetService('Debris')
local StarterGui = game:GetService('StarterGui')

-- Other
local tool = script.Parent

-- Modules
local AnimationModule = require(RS:WaitForChild('Modules'):WaitForChild('Animations'))

-- Folders
local SFXFolder = SoundService:WaitForChild("SFX")
local WeaponSFXFolder = SFXFolder:WaitForChild("Tools"):WaitForChild(tool.Name)

-- Values
local char = nil

-- Functions
tool.Equipped:Connect(function()
	char = tool.Parent
		
	local M6D = Instance.new("Motor6D")
	M6D.Name = "ToolGrip"
	M6D.Parent = char["Right Arm"]
	char["Right Arm"].ToolGrip.Part0 = char["Right Arm"]
	char["Right Arm"].ToolGrip.Part1 = char[tool.Name].BodyAttach
	
	if not char:GetAttribute('UsingMove') then
		
		AnimationModule.Equip(char)
		print('equipped played')

		local EquipSound = WeaponSFXFolder:WaitForChild('equip'):Clone()
		EquipSound.Parent = char:WaitForChild('HumanoidRootPart')
		task.wait(0.3)
		EquipSound:Play()
		Debris:AddItem(EquipSound, 1)
	else	
		AnimationModule.Idle(char, tool.Name)
	end
end)

tool.Unequipped:Connect(function()
		
	local rightArm = char:FindFirstChild("Right Arm")
	if rightArm then
		local toolGrips = {}

		for _, child in pairs(rightArm:GetChildren()) do
			if child.Name == "ToolGrip" and child:IsA("Motor6D") then
				table.insert(toolGrips, child)
			end
		end

		if #toolGrips > 1 then
			for i = 2, #toolGrips do
				toolGrips[i]:Destroy()
			end
		end
	end
	
	if not char:GetAttribute('UsingMove') then
		print('unequipped played')
		AnimationModule.Unequip(char)    
		local UnequipSound = WeaponSFXFolder:WaitForChild('unequip'):Clone()
		UnequipSound.Parent = char:WaitForChild('HumanoidRootPart')
		UnequipSound:Play()
		Debris:AddItem(UnequipSound, 1)
	end
end)
