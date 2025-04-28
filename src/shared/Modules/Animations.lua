local anim = {}

-- Services
local RS = game:GetService('ReplicatedStorage')

-- Animation folder
local AnimationFolder = RS:WaitForChild('Animations')
local WeaponAnimationFolder = AnimationFolder:WaitForChild("Tools")
local ToolAnimations = nil

-- Animations
local EquipAnimation = nil
local IdleAnimation = nil
local UnequipAnimation = nil
local BlockingAnimation = nil

-- Animation values
local EquipAnim = {}
local UnequipAnim = {}
local IdleAnim = {}
local BlockingAnim = {}

-- Functions
local function StopAllAnimations(char)
	if EquipAnim[char] then EquipAnim[char]:Stop() end
	if UnequipAnim[char] then UnequipAnim[char]:Stop() end
	if IdleAnim[char] then IdleAnim[char]:Stop() end
	if BlockingAnim[char] then BlockingAnim[char]:Stop() end

	if char:FindFirstChildWhichIsA("Tool") then ToolAnimations = WeaponAnimationFolder:FindFirstChild(char:FindFirstChildWhichIsA("Tool").Name) end --getting the right animation folder for our weapon
end

anim.Equip = function(char)
	StopAllAnimations(char)

	local hum = char:WaitForChild('Humanoid')
	local animator = hum:WaitForChild('Animator')
	
	EquipAnimation = ToolAnimations:WaitForChild('equip')
	IdleAnimation = ToolAnimations:WaitForChild('idle')
	
	IdleAnim[char] = animator:LoadAnimation(IdleAnimation)
	EquipAnim[char] = animator:LoadAnimation(EquipAnimation)
	EquipAnim[char]:Play()
	
	--char:SetAttribute("Swing",true)

	EquipAnim[char].KeyframeReached:Connect(function(kf)
		if kf == 'Equipped' then
			--char:SetAttribute("Swing",false)
			IdleAnim[char]:Play()
		end
	end)
	
	EquipAnim[char].Ended:Connect(function(kf) -- we are actually still keeping the ended in case the player gets hit while equipping
		if char:FindFirstChildWhichIsA("Tool") and char:GetAttribute("Stunned") then --actually checking if we didnt just unequip the weapon while we still equipped it
			IdleAnim[char]:Play()
		end
	end)
end

anim.Unequip = function(char)
	StopAllAnimations(char)

	local hum = char:WaitForChild('Humanoid')
	local animator = hum:WaitForChild('Animator')

	if not ToolAnimations then return end

	UnequipAnimation = ToolAnimations:WaitForChild("unequip")

	UnequipAnim[char] = animator:LoadAnimation(UnequipAnimation)
	UnequipAnim[char]:Play()
end

anim.Blocking = function(char)
	StopAllAnimations(char)

	local hum = char:WaitForChild('Humanoid')
	local animator = hum:WaitForChild('Animator')
	
	BlockingAnimation = ToolAnimations:WaitForChild("Blocking"):WaitForChild("blocking")

	BlockingAnim[char] = animator:LoadAnimation(BlockingAnimation)
	BlockingAnim[char]:Play()
end

anim.Unblocking = function(char)
	StopAllAnimations(char) 
	char:SetAttribute("Stunned", true)
	delay(0.2, function()
		char:SetAttribute("Stunned", false)
	end)
end

-- Used for abilities
anim.Idle = function(char, toolName)
	StopAllAnimations(char)

	local hum = char:WaitForChild('Humanoid')
	local animator = hum:WaitForChild('Animator')
	
	print(toolName)
	
	if toolName then
		ToolAnimations = WeaponAnimationFolder:FindFirstChild(toolName)
	end
	
	IdleAnimation = ToolAnimations:WaitForChild('idle')

	IdleAnim[char] = animator:LoadAnimation(IdleAnimation)
	IdleAnim[char]:Play()
end


return anim
