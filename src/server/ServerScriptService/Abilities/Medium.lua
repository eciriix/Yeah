local Medium = {}

-- Services
local RS = game:GetService('ReplicatedStorage')
local SS = game:GetService('ServerStorage')
local SoundService = game:GetService('SoundService')
local Debris = game:GetService('Debris')

-- Modules
local ServerModules = SS:WaitForChild('Modules')
local HitServiceModule = require(ServerModules.HitService)
local AnimationModule = require(RS:WaitForChild('Modules'):WaitForChild('Animations'))
local ServerCombatModules = require(ServerModules.CombatModule)
local HitboxModule = require(ServerModules.TomatoHitbox)
local CooldownHandler = RS.Events.CooldownHandler
local ActiveCDModule = require(game.ServerScriptService.ActiveCDModule)

-- Folders
local AnimationsFolder = RS:WaitForChild("Animations")
local SoundFolder = SoundService:WaitForChild('SFX')
local remotes = RS:WaitForChild('Events')
local vfxEvent = remotes.VFX
local runningStopEvent = remotes:WaitForChild('RunningStop')

-- Settings
local ShadowStrikeDistance = 14
local walkspeedDuring = 4
local jumpheightDuring = 0
local walkspeedDefault = 9
local jumpheightDefault = 4

-- Whirlwind Data
local whirlwindCooldown = 14
local whirlwindDamage = 12

-- Functions
local function findClosestPlayer(attacker)
	local closestPlayer = nil
	local closestDistance = ShadowStrikeDistance
	local attackerPosition = attacker.Character.PrimaryPart.Position

	for _, player in pairs(game.Players:GetPlayers()) do
		if player ~= attacker and player.Character and player.Character.PrimaryPart then
			local distance = (attackerPosition - player.Character.PrimaryPart.Position).Magnitude
			if distance < closestDistance then
				closestDistance = distance
				closestPlayer = player
			end
		end
	end

	return closestPlayer
end

function Medium.WhirlwindFlourish(attacker)
	local char = attacker.Character
	local hum = char:WaitForChild('Humanoid')
	if not char then return end

	local stunned = char:GetAttribute('Stunned')
	local attacked = char:GetAttribute('Attacked')
	local attacking = char:GetAttribute('Attacking')
	local isRagdoll = char:GetAttribute('isRagdoll')
	local swing = char:GetAttribute('Swing')
	local blocking = char:GetAttribute('isBlocking')
	local parrying = char:GetAttribute('Parrying')
	local running = char:GetAttribute('Running')
	local iframes = char:GetAttribute('iFrames')
	local Heavy = char.HumanoidRootPart:FindFirstChild("critical")

	---------------------------------------------------------------------------------------------------------------------------------------------------------

	if attacking or attacked or isRagdoll or swing or blocking or parrying or iframes or Heavy then 
		attacker.Backpack.MSword.Parent = char
		return
	end
	
	local CurrentCoolDowns = ActiveCDModule:GetCooldowns()

	if CurrentCoolDowns[attacker.Name] and CurrentCoolDowns[attacker.Name]["WhirlwindFlourish"] and (os.time() - CurrentCoolDowns[attacker.Name]["WhirlwindFlourish"] >= whirlwindCooldown) then
	else
		if not CurrentCoolDowns[attacker.Name] or not CurrentCoolDowns[attacker.Name]["WhirlwindFlourish"] then
		else
			if (os.time() - CurrentCoolDowns[attacker.Name]["WhirlwindFlourish"] < whirlwindCooldown) then 
				attacker.Backpack.MSword.Parent = char

				return
			end
		end
	end
	CooldownHandler:Fire(attacker, "WhirlwindFlourish")

	char:SetAttribute('Attacking', true)
	char:SetAttribute('Swing', true)
	char:SetAttribute('iFrames', true)
	char:SetAttribute('UsingMove', true)

	RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('HighlightGrey', char, 1.2)

	hum.WalkSpeed = walkspeedDuring
	hum.JumpHeight = jumpheightDuring

	local newHitbox = HitboxModule.new()
	newHitbox.Size = Vector3.new(12,8,12)
	newHitbox.CFrame = char:WaitForChild('HumanoidRootPart')
	newHitbox.Offset = CFrame.new(0,0,-3)

	local running = char:GetAttribute('Running')
	
	if running then
		char:SetAttribute('Running', false)
		runningStopEvent:FireClient(attacker)
	end

	char:SetAttribute("Combo",4)	

	newHitbox.onTouch = function(enemyHum)		
		if enemyHum ~= hum and enemyHum.Health > 0 then

			if enemyHum.Parent:GetAttribute('Parrying') then ServerCombatModules.Parrying(char, enemyHum.Parent) return end
			if enemyHum.Parent:GetAttribute('isBlocking') and ServerCombatModules.CheckInfront(char, enemyHum.Parent) then ServerCombatModules.Blocking(enemyHum.Parent, whirlwindDamage) return end
			if enemyHum.Parent:GetAttribute('isRagdoll') or enemyHum.Health <= 0 then return end
			if enemyHum.Parent:GetAttribute('iFrames') then RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('iFramesSuccess', enemyHum.Parent) return end			
						
			ServerCombatModules.StopAnims(enemyHum)
			
			enemyHum.Animator:LoadAnimation(AnimationsFolder.Tools.hit1):Play()			
			
			local enemyChar = enemyHum.Parent
			enemyChar:SetAttribute('Parrying', false)
			RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('Blood', enemyChar)

			local HitSound = SoundFolder:WaitForChild('Tools'):WaitForChild('MSword'):WaitForChild(math.random(2) == 1 and 'hit1' or 'hit2'):Clone()
			HitSound.Parent = char:WaitForChild('HumanoidRootPart')
			HitSound:Play()
			Debris:AddItem(HitSound, 2)
			
			HitServiceModule.Hit(enemyHum, whirlwindDamage, .5, false, false, 0)
		end
	end
	
	local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
	local bodyV = Instance.new("BodyVelocity")
	bodyV.MaxForce = Vector3.new(1, 0, 1) * 25000
	bodyV.Parent = humanoidRootPart

	local function updateVelocity()
		local lookVector = humanoidRootPart.CFrame.LookVector
		bodyV.Velocity = lookVector * 50 
	end

	local runService = game:GetService("RunService")
	local startTime = tick()
	local connection

	connection = runService.Stepped:Connect(function(_, dt)
		local currentTime = tick()
		local elapsedTime = currentTime - startTime

		if elapsedTime >= 0.4 and elapsedTime <= 1.1 then
			updateVelocity()
		elseif elapsedTime > 1.1 and elapsedTime <= 2 then
			local progress = (elapsedTime - 1.1) / (2 - 1.1)
			local lookVector = humanoidRootPart.CFrame.LookVector
			bodyV.Velocity = lookVector * (50 * (1 - progress))
		elseif elapsedTime > 2 then
			bodyV.Velocity = Vector3.new()
			connection:Disconnect()
		end
	end)
	RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('Whirlwind', char)

	game:GetService("Debris"):AddItem(bodyV, 2)
	RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('WhirlwindSmoke', char)

	task.spawn(function()
		task.wait(0.3)
		local flourishSound1 = SoundFolder:WaitForChild('Abilities'):WaitForChild('whirlwind1'):Clone()
		flourishSound1.Parent = char:WaitForChild('HumanoidRootPart')
		flourishSound1:Play()
		Debris:AddItem(flourishSound1, 3)
		task.wait(0.2)
		RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('Crack', char)
		RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('Dashing', char, 1)
		
		task.wait(.4)
		local flourishSound3 = SoundFolder:WaitForChild('Abilities'):WaitForChild('whirlwind3'):Clone()
		flourishSound3.Parent = char:WaitForChild('HumanoidRootPart')
		flourishSound3:Play()
		Debris:AddItem(flourishSound3, 3)
		task.wait(.2)

		local flourishSound2 = SoundFolder:WaitForChild('Abilities'):WaitForChild('whirlwind2'):Clone()
		flourishSound2.Parent = char:WaitForChild('HumanoidRootPart')
		flourishSound2:Play()
		Debris:AddItem(flourishSound2, 3)
		
		local flourishSound4 = SoundFolder:WaitForChild('Abilities'):WaitForChild('whirlwind4'):Clone()
		flourishSound4.Parent = char:WaitForChild('HumanoidRootPart')
		flourishSound4:Play()
		Debris:AddItem(flourishSound4, 3)

	end)

	local flourishAnimation = AnimationsFolder:WaitForChild("Abilities").whirlwind	
	local flourishAnim = hum.Animator:LoadAnimation(flourishAnimation)
	flourishAnim:Play()
	flourishAnim:AdjustSpeed(1)

	char:FindFirstChildOfClass('Humanoid'):UnequipTools('TempMSword')
	attacker.Backpack.MSword.Parent = char

	flourishAnim.KeyframeReached:Connect(function(kf)
		if kf == 'Air' then
			flourishAnim:AdjustSpeed(2)
		end
		
		if kf == 'Hit' then			
			flourishAnim:AdjustSpeed(1)			
			char:SetAttribute('Running', false)
			runningStopEvent:FireClient(attacker)
			char:SetAttribute('Attacking', false)
			char:SetAttribute('iFrames', false)
			task.spawn(function()
				if not char:GetAttribute('Stunned') then
					newHitbox:Start()
					task.wait(.5)		
					newHitbox:Stop()
					newHitbox:Destroy()
				else
					newHitbox:Stop()
					newHitbox:Destroy()
				end
			end)
		end
	end)

	flourishAnim.Stopped:Connect(function()
		char:SetAttribute('Running', false)
		runningStopEvent:FireClient(attacker)
		hum.WalkSpeed = walkspeedDefault
		hum.JumpHeight = jumpheightDefault
		char:SetAttribute('Swing', false)
	
		char:SetAttribute('UsingMove', false)	
	end)
end

return Medium
