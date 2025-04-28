-- Services and folders
local uis = game:GetService("UserInputService")
local rp = game:GetService("ReplicatedStorage")
local animations = rp:WaitForChild("Animations")

-- Player
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local TouchGui = player:WaitForChild("PlayerGui"):FindFirstChild("TouchGui")

-- Events
local climbEvent = rp.Events.Climbing

-- Climb variables
local latchDistance = 5 
local vaultDebounce = false
local climbDebounce = false
local climbing = false

-- Vault variables
local Root = char:WaitForChild("HumanoidRootPart")
local Head = char:WaitForChild("Head")
local studHeight = 1.5
local vaultPower = 35
local vaultForwardPower = 30
local vaultCooldown = 0.5
local ledgeavailable = true

-- Animation variables
local climbAnim = animations.Movement.Climbing.walljump
local vaultAnim1 = animations.Movement.Climbing.vault1
local vaultAnim2 = animations.Movement.Climbing.vault2

-- Functions
local function climbFunction(running)
	if climbDebounce then return end
	climbDebounce = true
	climbing = true

	local humanoidRootPart = char:WaitForChild("HumanoidRootPart")

	-- First jump
	if running then
		local firstJump = Instance.new("BodyVelocity")
		firstJump.MaxForce = Vector3.new(4000, 4000, 4000)  
		firstJump.P = 10000  -- Adjust as needed
		firstJump.Parent = humanoidRootPart
		firstJump.Velocity = humanoidRootPart.CFrame.LookVector * 20 + Vector3.new(0, 25, 0) 
		
		playClimb = hum:LoadAnimation(climbAnim)
		playClimb:Play()
		climbEvent:FireServer(1)
		task.wait(.3) 
		firstJump:Destroy()  
	else
		local firstJump = Instance.new("BodyVelocity")
		firstJump.MaxForce = Vector3.new(4000, 4000, 4000)
		firstJump.P = 10000  
		firstJump.Parent = humanoidRootPart
		firstJump.Velocity = humanoidRootPart.CFrame.LookVector * 20 + Vector3.new(0, 20, 0) 
		
		playClimb = hum:LoadAnimation(climbAnim)
		playClimb:Play()
		climbEvent:FireServer(1)
		task.wait(.2)  
		firstJump:Destroy()  
	end
	
	local secondJump = Instance.new("BodyVelocity")
	secondJump.MaxForce = Vector3.new(4000, 4000, 4000) 
	secondJump.P = 10000  -- Adjust as needed
	secondJump.Parent = humanoidRootPart
	secondJump.Velocity = humanoidRootPart.CFrame.LookVector * 20 + Vector3.new(0, 40, 0)  
	climbEvent:FireServer(2)
	task.wait(.2) 

	secondJump:Destroy()
	task.wait(1)
	climbing = false
	climbDebounce = false
end

uis.InputBegan:Connect(function(input, check)
	if check == false then

		if input.KeyCode == Enum.KeyCode.Space then
			local rayOrigin = char.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
			local rayDirection = char.HumanoidRootPart.CFrame.LookVector * latchDistance
			local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = {char}
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
			local rayResult = workspace:Raycast(rayOrigin, rayDirection, rayParams)

			if rayResult then
				if rayResult.Distance < latchDistance then
					if rayResult and hum.FloorMaterial == Enum.Material.Air and not climbDebounce then
						
						if char:GetAttribute('Stunned') or char:GetAttribute('SlowStunned') or char:GetAttribute('Dashing') or char:GetAttribute('isBlocking') or char:GetAttribute('UsingMove') or char:GetAttribute('Swing') or char:GetAttribute('Attacked') then return end
						
						if char:GetAttribute('Running') then
							climbFunction(true)
						else
							climbFunction(false)
						end
					end
				end
			end
		end
	end
end)


while game:GetService("RunService").Heartbeat:Wait() do

	local r = Ray.new(Head.CFrame.p, Head.CFrame.LookVector * 5)
	local part, position = workspace:FindPartOnRay(r, char)

	if part and ledgeavailable then
		if part.Size.Y >= 7 then
			if Head.Position.Y >= (part.Position.Y + (part.Size.Y / 2)) - studHeight and 
				Head.Position.Y <= part.Position.Y + (part.Size.Y / 2) and 
				hum.FloorMaterial == Enum.Material.Air and 
				Root.Velocity.Y >= 0 then

				vault()
			end
		end
	end

	function vault()
		
		playClimb:Stop()
		
		local playVaultAnimation = hum:LoadAnimation(rp.Animations.Movement.Climbing:WaitForChild(math.random(2) == 1 and 'vault1' or 'vault2'))
		playVaultAnimation:Play()
		playVaultAnimation:AdjustSpeed(1.2)

		local Vele = Instance.new("BodyVelocity", Root)

		Vele.MaxForce = Vector3.new(1, 1, 1) * math.huge 

		Vele.Velocity = Root.CFrame.LookVector * vaultForwardPower + Vector3.new(0, vaultPower, 0)

		game.Debris:AddItem(Vele, .15) 
		climbEvent:FireServer(3)

		wait(vaultCooldown)

		ledgeavailable = true
	end
end

