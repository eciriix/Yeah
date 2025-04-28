-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RS = game:GetService('ReplicatedStorage')

-- Events
local runningEvent = RS:WaitForChild('Events').Running
local runningStopEvent = RS:WaitForChild('Events').RunningStop

-- Constants
local PLAYER = game:GetService('Players').LocalPlayer
local char = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local NORM_SPEED = 9
local RUN_SPEED = 20

-- Animations
local runNormalID = RS:WaitForChild('Animations'):WaitForChild('Movement'):WaitForChild('run')
local hum = char:WaitForChild('Humanoid')
local animator = hum:WaitForChild('Animator')
local runAnimation = animator:LoadAnimation(runNormalID)
local toolname 

-- Variables
local debounce = false
local running = true
local moving = false
local holdingS = false

-- Events and functions
function getCharacter()
	return PLAYER.Character or PLAYER.CharacterAdded:Wait()
end

function getMovement()
	if hum.MoveDirection.Magnitude > 0 then
		return true
	else
		return false
	end
end

local function stopAnims(hum)
	for i,v in pairs(hum.Animator:GetPlayingAnimationTracks()) do
		if v.Name ~= 'idle' and v.Name ~= 'WalkAnim' then
			v:Stop()
		end
	end
end

function changeSpeed(speed)
	local character = getCharacter()
	local humanoid = character:FindFirstChild("Humanoid")
	humanoid.WalkSpeed = speed
end

function activate()
	local stunned = char:GetAttribute('Stunned')
	local attacked = char:GetAttribute('Attacked')
	local attacking = char:GetAttribute('Attacking')
	local isRagdoll = char:GetAttribute('isRagdoll')
	local swing = char:GetAttribute('Swing')
	local blocking = char:GetAttribute('isBlocking')
	local parrying = char:GetAttribute('Parrying')
	local slowStunned = char:GetAttribute('SlowStunned')
	local usingMove = char:GetAttribute('UsingMove')
	
	if attacking or attacked or stunned or isRagdoll or swing or blocking or parrying or slowStunned or usingMove then return end
	
	if char:FindFirstChildWhichIsA('Tool') then
		toolname = char:FindFirstChildWhichIsA('Tool').Name
	else
		toolname = nil
	end
	
	if debounce == false then
		runAnim('Start', toolname)
		runningEvent:FireServer('Start', RUN_SPEED)
		debounce = true
		running = true
	end
end

function runAnim(state, toolname)
	if state == 'Start' then
		if not runAnimation.IsPlaying then
			runAnimation:Play()
		end	
	elseif state == 'Stop' then
		if runAnimation.IsPlaying then
			runAnimation:Stop()			
		end
	end
end

runningStopEvent.OnClientEvent:Connect(function()
	runAnim('Stop')
end)

UserInputService.InputBegan:Connect(function(input,gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.S then
		holdingS = true
	end
	if input.KeyCode == Enum.KeyCode.LeftShift and moving and not holdingS then
		activate()
	end
end)

UserInputService.InputEnded:Connect(function(input,gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.S then
		holdingS = false
	end
	
	if input.KeyCode == Enum.KeyCode.LeftShift then
		if running then
			runAnim('Stop')
			runningEvent:FireServer('Stop', NORM_SPEED)
			running = false
			wait(.0)
			debounce = false
		end
	end
end)


hum:GetPropertyChangedSignal("MoveDirection"):Connect(function()
	if (char:WaitForChild('HumanoidRootPart').CFrame.LookVector:Dot(hum.MoveDirection)) <= -0.7 then
	  runAnim('Stop')
		runningEvent:FireServer('Stop', NORM_SPEED)
	end
	if hum.MoveDirection.Magnitude > 0 then
		moving = true
	else
		moving = false
	end
end)

while script do
	task.wait(0.05)	
	if moving and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and not running and not holdingS then
		activate()
	end
	if not moving and running then
		runAnim('Stop')
		runningEvent:FireServer('Stop', NORM_SPEED)
	end
end


