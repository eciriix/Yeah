local RS = game:GetService('ReplicatedStorage')

local runningEvent = RS:WaitForChild('Events').Running

local function handleRunning(plr, action, speed)
	
	local char = plr.character or plr.CharacterAdded:wait()

	-- Attributes
	local stunned = char:GetAttribute('Stunned')
	local attacked = char:GetAttribute('Attacked')
	local attacking = char:GetAttribute('Attacking')
	local isRagdoll = char:GetAttribute('isRagdoll')
	local swing = char:GetAttribute('Swing')
	local blocking = char:GetAttribute('isBlocking')
	local parrying = char:GetAttribute('Parrying')
	local usingMove = char:GetAttribute('UsingMove')

	if attacking or attacked or stunned or isRagdoll or swing or blocking or parrying or usingMove then return end
	
	local hum = char:WaitForChild('Humanoid')
	
	if action == 'Start' then
		hum.WalkSpeed = speed
		char:SetAttribute('Running', true)
		
	elseif action == 'Stop' then
		hum.WalkSpeed = speed
		char:SetAttribute('Running', false)
	end	
end

runningEvent.OnServerEvent:Connect(handleRunning)
