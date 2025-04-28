-- Services
local RS = game:GetService('ReplicatedStorage')
local SS = game:GetService("ServerStorage")

-- Events
local blockingEvent = RS:WaitForChild('Events').Blocking
local runningStopEvent = RS:WaitForChild('Events'):WaitForChild('RunningStop')

-- Modules
local ServerModuleInfo = SS:WaitForChild("Info")
local WeaponInfoModule = require(ServerModuleInfo.WeaponInfo)
local BlockingStats = WeaponInfoModule:getWeapon("Blocking")

-- Settings
local parryFrame = BlockingStats.ParryFrame
local walkspeedDefault = 9
local jumpheightDefault = 4
local walkspeedDuring = 6
local jumpheightDuring = 3


local function handleBlocking(plr, action)
	local character = plr.Character
	
	local isBlocking = character:GetAttribute('isBlocking')
	local running = character:GetAttribute('Running')
	local lastStopTime = character:GetAttribute('LastStopTime') or 0
	local currentTime = tick()
	
	if running then 
		character:SetAttribute('Running', false)
		character.Humanoid.WalkSpeed = walkspeedDefault
		character.Humanoid.JumpHeight = jumpheightDefault
		runningStopEvent:FireClient(plr)
	end
	
	if action == 'Start' then
		
		character:SetAttribute('ParryTrue', false)

		
		task.spawn(function()
			character:SetAttribute('Parrying', true)
			task.wait(parryFrame)
			character:SetAttribute('Parrying', false)
		end)
		
		character:SetAttribute('isBlocking', true)
		character:SetAttribute('LastStopTime', 0)
		
		local hum = plr.Character:FindFirstChild('Humanoid')		
		hum.WalkSpeed = walkspeedDuring
		hum.JumpHeight = jumpheightDuring 
		
	elseif action == 'Stop' then
		if isBlocking then
			character:SetAttribute('isBlocking', false)
			character:SetAttribute('LastStopTime', currentTime)
			
			local hum = plr.Character:FindFirstChild('Humanoid')		
			
			hum.WalkSpeed = walkspeedDefault
			hum.JumpHeight = jumpheightDefault
			
			task.delay(parryFrame, function()
				character:SetAttribute('Parrying', false)
			end)
		end
	end
end
 
blockingEvent.OnServerEvent:Connect(handleBlocking)

-- Check and decrease posture attribute each second
while true do
	task.wait(1)
	for _, player in pairs(game.Players:GetPlayers()) do
		local character = player.Character
		if character then
			
			local isBlocking = character:GetAttribute('isBlocking')
			local lastStopTime = character:GetAttribute('LastStopTime') or 0
			local currentTime = tick()
			
			if not isBlocking and currentTime - lastStopTime >= 3 then
				--print(character:GetAttribute('Posture'))
				character:SetAttribute('Posture', math.max(0, character:GetAttribute('Posture') - (math.random(0, 3))))
			end
		end
	end
end