-- Player
local player = game:GetService("Players").LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local humRp = char:WaitForChild("HumanoidRootPart")

-- Folders
local rp = game:GetService("ReplicatedStorage")
local animations = rp:WaitForChild("Animations")
local dashAnimations = animations:WaitForChild("Movement").Dash
local CombatStats = 		player.PlayerGui.StatsGui.CombatStats

-- Other
local dashEvent = rp:WaitForChild('Events').Dash
local camera = workspace.CurrentCamera
local gameSettings = UserSettings().GameSettings
local UIS = game:GetService("UserInputService")

-- Variables
local dashing = false
local db = false
local cd = 1.4


local allDashAnim = 
	{
		["Left"] = dashAnimations.ldash, 
		["Right"] = dashAnimations.rdash, 
		["Front"] = dashAnimations.fdash, 
		["Back"] = dashAnimations.bdash 
	}

local function blinkUI()
	for count = 0, 3, 1.5 do
		CombatStats.Indicators.Roll.BorderSizePixel += 1
		task.wait(0.05)
	end
	for count = 0, 3, 1.5 do
		CombatStats.Indicators.Roll.BorderSizePixel -= 1
		task.wait(0.05)
	end
end

local function slowDash(direction,dashAnim)
	if dashAnim == nil then 
		db = false
		dashEvent:FireServer(false)
		dashing = false
		print('buged')
	end
	
	if dashAnim == nil then return end
	
	local bodyV = Instance.new("BodyVelocity",humRp)
	bodyV.MaxForce = Vector3.new(1, 0, 1) * 25000

	local playDash = hum:LoadAnimation(dashAnim)
	playDash:Play()

	if direction == 'forward' then
		for i=50,0,-1 do
			bodyV.Velocity = camera.CFrame.LookVector * i
			task.wait(0.01)
		end
		dashEvent:FireServer(false)
		task.delay(cd,function()
			db = false
			blinkUI()
		end)
		
	elseif direction == 'backward' then
		local relativeVector
		relativeVector = camera.CFrame.LookVector * -1
		for i=50,0,-1 do
			bodyV.Velocity = relativeVector * i
			task.wait(0.01)
		end
		dashEvent:FireServer(false)
		task.delay(cd,function()
			db = false
			blinkUI()
		end)
		
	else
		gameSettings.RotationType = Enum.RotationType.CameraRelative
		local relativeVector
		if direction == "left" then
			relativeVector = camera.CFrame.RightVector * -1  
		elseif direction == "right" then
			relativeVector = camera.CFrame.RightVector
		end

		for i = 45, 0, -1 do
			bodyV.Velocity = relativeVector * i
			task.wait(0.01)
		end
		dashEvent:FireServer(false)
		task.delay(cd,function()
			db = false
			blinkUI()
		end)
	end
	
	playDash:Stop()
	gameSettings.RotationType = Enum.RotationType.MovementRelative
	bodyV:Destroy()
	dashing = false
end

UIS.InputBegan:Connect(function(input,isTyping)
	if isTyping then return end

	if input.KeyCode == Enum.KeyCode.Q then

		local md = hum.MoveDirection.Magnitude
		local blocking = char:GetAttribute('isBlocking')
		local attacking = char:GetAttribute('Attacking')
		local swing = char:GetAttribute('Swing')
		local stunned = char:GetAttribute('Stunned')
		local slowStunned = char:GetAttribute('SlowStunned')
		local usingMove = char:GetAttribute('UsingMove')

		if dashing or md <= 0 or blocking or attacking or swing or stunned or slowStunned or usingMove then return end

		local MoveDirection = camera.CFrame:VectorToObjectSpace(hum.MoveDirection)

		local left = math.round(MoveDirection.X) == -1
		local right = math.round(MoveDirection.X) == 1
		local front = math.round(MoveDirection.Z) == -1
		local back = math.round(MoveDirection.Z) == 1

		local direct = nil
		local dashAnim

		if left then

			if db then return end

			direct = 'left'
			db = true
			dashAnim = allDashAnim.Left

		elseif right then

			if db then return end

			direct = 'right'
			db = true
			dashAnim = allDashAnim.Right

		elseif front then

			if db then return end

			direct = 'forward'
			db = true
			dashAnim = allDashAnim.Front

		elseif back then

			if db then return end

			direct = 'backward'
			db = true
			dashAnim = allDashAnim.Back

		end
		if dashAnim == nil then return end
		dashing = true
		dashEvent:FireServer(true)
		slowDash(direct,dashAnim)
	end
end)



local function updateUI()
	if db then
		CombatStats.Indicators.Roll.Overlay.Visible = true
	else
		CombatStats.Indicators.Roll.Overlay.Visible = false
	end
end

while task.wait() do
	updateUI()
end