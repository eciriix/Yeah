local RS = game:GetService('ReplicatedStorage')
local SS = game:GetService('ServerStorage')
local uis = game:GetService('UserInputService')
local SoundService = game:GetService('SoundService')
local Debris = game:GetService('Debris')

local plr = game:GetService('Players').LocalPlayer
local char = plr.Character

local blockingEvent = RS:WaitForChild('Events').Blocking
local statsUI = plr.PlayerGui:WaitForChild('StatsGui')

-- Modules
local AnimationModule = require(RS:WaitForChild('Modules'):WaitForChild('Animations'))

-- Settings
local debounce = false
local blockCooldown = 1

local function startBlocking(guardbroke)
	debounce = true
	blockingEvent:FireServer('Start')
	AnimationModule.Blocking(char)

	local BlockSound = SoundService:WaitForChild('SFX'):WaitForChild('Tools'):WaitForChild('MSword'):WaitForChild('parryswing'):Clone()
	BlockSound.Parent = char:WaitForChild('HumanoidRootPart')
	BlockSound:Play()
	Debris:AddItem(BlockSound, 1)
	task.wait(blockCooldown)
	debounce = false
end

local function stopBlocking()	
	blockingEvent:FireServer('Stop')
	AnimationModule.Unblocking(char)
end

uis.InputBegan:Connect(function(key, isTyping)
	
	if isTyping then return end
	
	local hum = char:FindFirstChild('Humanoid')
	
	if key.KeyCode == Enum.KeyCode.F then
		
		local attacking = char:GetAttribute('Attacking')
		local stunned = char:GetAttribute('Stunned')
		local isRagdoll = char:GetAttribute('isRagdoll')
		local isBlocking = char:GetAttribute('isBlocking')
		local posture = char:GetAttribute('Posture')
		local swing = char:GetAttribute('Swing')
		local running = char:GetAttribute('Running')
		local parryTrue = char:GetAttribute('ParryTrue')
		local dashing = char:GetAttribute('Dashing')
		local slowStunned = char:GetAttribute('SlowStunned')
		local usingMove = char:GetAttribute('UsingMove')

		if attacking or stunned or isRagdoll or isBlocking or dashing or slowStunned or usingMove then return end
		if debounce and parryTrue then
			debounce = false
		end
		if not debounce and char:FindFirstChildWhichIsA("Tool") and char:FindFirstChildWhichIsA("Tool"):GetAttribute("Type") == "Attack" and hum:GetState() ~= Enum.HumanoidStateType.Dead then
			startBlocking(false)
		end 
	end
end)

uis.InputEnded:Connect(function(key)
	
	local stunned = char:GetAttribute('Stunned')
	if key.KeyCode == Enum.KeyCode.F and not stunned then
		stopBlocking()
	end
end)

char.ChildRemoved:Connect(function()
	
	if not char:FindFirstChild('MSword') and char:GetAttribute('isBlocking') then
		stopBlocking()
	end
	
end)

char:GetAttributeChangedSignal('Posture'):Connect(function()

	statsUI.CombatStats.Posture.Slider:TweenSize(UDim2.new(char:GetAttribute('Posture') /100*0.615,0,0.7,0), Enum.EasingDirection.InOut,Enum.EasingStyle.Sine, .3)
	
end)

while script do
	task.wait(0.05)
	if char:GetAttribute('Stunned') then
		stopBlocking()
	end
end