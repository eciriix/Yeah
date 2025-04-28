local RS = game:GetService('ReplicatedStorage')
local TS = game:GetService('TweenService')
local UIS = game:GetService('UserInputService')
local SoundService = game:GetService('SoundService')
local SoundFolder = SoundService:WaitForChild('SFX')

-- Events
local remotes = RS:WaitForChild('Events')
local swingEvent = remotes:WaitForChild('Swing')

-- Data
local camera = game.Workspace.CurrentCamera
local lastMouseButton1Pressed = 0
local TimeToFeint = .25
local FeintDebounce = false
local plr = game:GetService('Players').LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local HeavyDebounce = false
local HeavyCooldown = 2.5
local AerialDebounce = false
local AerialCooldown = 4

local function HeavyFunction()
	if char:FindFirstChildWhichIsA("Tool") and char:FindFirstChildWhichIsA("Tool"):GetAttribute("Type") == "Attack" and not HeavyDebounce and not char:GetAttribute("Swing") and not char:GetAttribute("Attacking") then
		swingEvent:FireServer("Heavy", char:FindFirstChildWhichIsA("Tool").Name)

		task.spawn(function()
			task.wait(0.5)
			if char:FindFirstChild('HumanoidRootPart') and char.HumanoidRootPart:FindFirstChild('critical') then
				HeavyDebounce = true
				task.wait(HeavyCooldown)
				HeavyDebounce = false
			end
		end)
	end
end

local function AerialFunction()
	if char:FindFirstChildWhichIsA("Tool") and char:FindFirstChildWhichIsA("Tool"):GetAttribute("Type") == "Attack" and not AerialDebounce and not char:GetAttribute("Swing") and not char:GetAttribute("Attacking") then
		swingEvent:FireServer("Air", char:FindFirstChildWhichIsA("Tool").Name, char.HumanoidRootPart.CFrame.LookVector)

		task.spawn(function()
			task.wait(0.5)
			if char:FindFirstChild('HumanoidRootPart') and char.HumanoidRootPart:FindFirstChild('aerial') then
				AerialDebounce = true
				task.wait(AerialCooldown)
				AerialDebounce = false
			end
		end)
	end
end

local function FeintFunction()
	local timeSinceMouseButton1 = tick() - lastMouseButton1Pressed
	if timeSinceMouseButton1 >= 0.05 and timeSinceMouseButton1 <= TimeToFeint and not FeintDebounce then
		FeintDebounce = true
		swingEvent:FireServer('Feint', char:FindFirstChildWhichIsA('Tool').Name)		

		task.spawn(function()
			task.wait(1)
			FeintDebounce = false
		end)
	end
end

UIS.InputBegan:Connect(function(key, isTyping)
	if isTyping or char:GetAttribute('Stunned') then return end

	local hum = char:FindFirstChild('Humanoid')

	local state = hum:GetState()

	if key.UserInputType == Enum.UserInputType.MouseButton1 and char:FindFirstChildWhichIsA("Tool") and char:FindFirstChildWhichIsA("Tool"):GetAttribute("Type") == "Attack" and hum:GetState() ~= Enum.HumanoidStateType.Dead and (state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping) then
		AerialFunction()
	end

	if key.UserInputType == Enum.UserInputType.MouseButton1 and char:FindFirstChildWhichIsA("Tool") and char:FindFirstChildWhichIsA("Tool"):GetAttribute("Type") == "Attack" and hum:GetState() ~= Enum.HumanoidStateType.Dead then
		lastMouseButton1Pressed = tick()
		swingEvent:FireServer('None', char:FindFirstChildWhichIsA('Tool').Name)
	end

	if key.KeyCode == Enum.KeyCode.R then
		HeavyFunction()
	end
	
	if key.UserInputType == Enum.UserInputType.MouseButton2 then
		FeintFunction()
	end
end)
