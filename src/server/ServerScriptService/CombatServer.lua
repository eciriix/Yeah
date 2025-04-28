-- Services
local RS = game:GetService('ReplicatedStorage')
local SS = game:GetService('ServerStorage')
local SoundService = game:GetService('SoundService')
local Debris = game:GetService('Debris')
local PlayerService = game:GetService('Players')

-- Folders
local remotes = RS:WaitForChild('Events')
local animations = RS:WaitForChild('Animations').Tools
local attackingAnimations = animations:WaitForChild('MSword'):WaitForChild('Attacking')
local ServerModules = SS:WaitForChild('Modules')
local AnimationsFolder = RS:WaitForChild("Animations")
local SoundFolder = SoundService:WaitForChild('SFX')

-- Modules
local ServerCombatModules = require(ServerModules.CombatModule)
local HitboxModule = require(ServerModules.TomatoHitbox)
local HitServiceModule = require(ServerModules.HitService)
local WeaponInfoModule = require(SS.Info.WeaponInfo)

-- Events
local swingEvent = remotes:WaitForChild('Swing')
local runningStopEvent = remotes:WaitForChild('RunningStop')
local vfxEvent = remotes.VFX

-- Settings
local comboCooldown = 0.5
local walkspeedDefault = 9
local jumpheightDefault = 4
local walkspeedDuring = 9
local jumpheightDuring = 4

-- Heavy attack
local function Heavy_Attack(char,hum,toolName,action,trail,newHitbox,HeavyHitboxSize,HeavyHitboxOffset, swordSwingPause, HeavyForwardTime)
	if action == "Heavy" then 
		ServerCombatModules.StopAnims(hum) 
		char:SetAttribute('Running', false)
		local playerFromCharacter = PlayerService:GetPlayerFromCharacter(char)
		runningStopEvent:FireClient(playerFromCharacter)
		
		newHitbox.Size = HeavyHitboxSize 
		newHitbox.Offset = HeavyHitboxOffset
		hum.WalkSpeed = walkspeedDuring 
		hum.JumpHeight = 0

		local HeavyChargeSound = SoundFolder.Tools:WaitForChild(toolName):WaitForChild("criticalcharge"):Clone() 
		HeavyChargeSound.Parent = char.HumanoidRootPart
		HeavyChargeSound:Play()
		Debris:AddItem(HeavyChargeSound,2)

		local HeavyAnim = hum.Animator:LoadAnimation(AnimationsFolder.Tools[toolName].Attacking.critical) 
		HeavyAnim:Play() 
		task.wait(0.2)
		HeavyAnim:AdjustSpeed(0)
		vfxEvent:FireAllClients("Critical", char) 
		task.wait(swordSwingPause*1.5) 
		HeavyAnim:AdjustSpeed(1)
		
		local hrp = char.HumanoidRootPart
		local knockback = hrp.CFrame.LookVector * 50
		
		local bv = Instance.new('BodyVelocity')
		bv.MaxForce = Vector3.new(1, 0, 1) * 14000
		bv.P = 100000
		bv.Velocity = knockback
		bv.Parent = hrp
		Debris:AddItem(bv,HeavyForwardTime)
		
		local HeavySound = SoundFolder.Tools:WaitForChild(toolName):WaitForChild("critical"):Clone() 
		HeavySound.Parent = char.HumanoidRootPart
		HeavySound:Play()
		Debris:AddItem(HeavySound,1.5)

		HeavyAnim.KeyframeReached:Connect(function(kf)
			if kf == "Hit" then
				char:SetAttribute("Attacking", false)
				
				task.spawn(function()
					if not char:GetAttribute('Stunned') then
						newHitbox:Start()
						task.wait(.3)		
						
						newHitbox:Stop()
						newHitbox:Destroy()
					else
						newHitbox:Stop()
						newHitbox:Destroy()
					end
				end)
			end			
		end)

		HeavyAnim.Stopped:Connect(function()  

			if HeavySound then task.delay(.1,function() HeavySound:Destroy() end) end
			char:SetAttribute("Swing", false)
			if char:FindFirstChild(toolName) and trail then  trail.Enabled = false end
			if not char:GetAttribute("isBlocking") or not char:GetAttribute("Stunned") or not char:GetAttribute("Attacked") or char:GetAttribute("Attacking") then hum.WalkSpeed = walkspeedDefault hum.JumpHeight = jumpheightDefault end			
		end)		
	end
end

-- Air attack
local function Air_Attack(char, hum, toolName, action, trail, newHitbox, lookVec)
	if action == "Air" then
		ServerCombatModules.StopAnims(hum)
		char:SetAttribute('Running', false)
		local playerFromCharacter = PlayerService:GetPlayerFromCharacter(char)
		runningStopEvent:FireClient(playerFromCharacter)

		newHitbox.Size = Vector3.new(6, 6, 5)
		newHitbox.Offset = CFrame.new(0, 0, -2.5)
		hum.WalkSpeed = walkspeedDuring
		hum.JumpHeight = jumpheightDefault

		local AirAnim = hum.Animator:LoadAnimation(AnimationsFolder.Tools[toolName].Attacking.aerial)
		AirAnim:Play()
		AirAnim:AdjustSpeed(1)
		vfxEvent:FireAllClients("Critical", char)

		local hrp = char.HumanoidRootPart
		local forwardDirection = lookVec * 55
		local downwardSpeed = -60

		local bv = Instance.new('BodyVelocity')
		bv.MaxForce = Vector3.new(1, 1, 1) * 100000
		bv.P = 100000
		bv.Velocity = Vector3.new(0, 0, 0)
		bv.Parent = hrp

		task.spawn(function()
			for i = 35, 0, -1 do
				bv.Velocity = hrp.CFrame.LookVector * i
				task.wait(0.01)
			end
			bv:Destroy()

			local finalBv = Instance.new('BodyVelocity')
			finalBv.MaxForce = Vector3.new(1, 1, 1) * 14000
			finalBv.P = 100000
			finalBv.Parent = hrp

			for i = 20, 0, -1 do
				finalBv.Velocity = hrp.CFrame.LookVector * (55 * (i / 10)) + Vector3.new(0, downwardSpeed, 0)
				task.wait(0.01)
			end
			finalBv:Destroy()
		end)

		local AerialSound = SoundFolder.Tools:WaitForChild(toolName):WaitForChild("aerial"):Clone()
		AerialSound.Parent = char.HumanoidRootPart
		AerialSound:Play()
		Debris:AddItem(AerialSound, 1.5)

		AirAnim.KeyframeReached:Connect(function(kf)
			if kf == "Hit" then
				char:SetAttribute("Attacking", false)

				task.spawn(function()
					if not char:GetAttribute('Stunned') then
						newHitbox:Start()
						task.wait(.4)
						newHitbox:Stop()
						newHitbox:Destroy()
					else
						newHitbox:Stop()
						newHitbox:Destroy()
					end
				end)
			end
		end)

		AirAnim.Stopped:Connect(function()
			if AerialSound then task.delay(.1, function() AerialSound:Destroy() end) end
			char:SetAttribute("Swing", false)
			if char:FindFirstChild(toolName) and trail then trail.Enabled = false end
			if not char:GetAttribute("isBlocking") or not char:GetAttribute("Stunned") or not char:GetAttribute("Attacked") or char:GetAttribute("Attacking") then
				hum.WalkSpeed = walkspeedDefault
				hum.JumpHeight = jumpheightDefault
			end
		end)
	end
end

-- Feint
local function Feint(char, hum, toolName, action)
	if action == "Feint" then		
		if char:GetAttribute('Combo') ~= 1 then return end

		char:SetAttribute('Attacking', true)
		char:SetAttribute('Swing', true)

		--ServerCombatModules.ChangeCombo(char, toolName)
		
		ServerCombatModules.StopAnims(hum)
		char:SetAttribute('Running', false)
		local playerFromCharacter = PlayerService:GetPlayerFromCharacter(char)
		runningStopEvent:FireClient(playerFromCharacter)

		task.spawn(function()
			task.wait(0.3)
			char:SetAttribute('Attacking', false)
			char:SetAttribute('Swing', false)
		end)

		local FeintSound = SoundFolder.Tools:WaitForChild(toolName):WaitForChild("feint"):Clone()
		FeintSound.Parent = char.HumanoidRootPart
		FeintSound:Play()
		Debris:AddItem(FeintSound, 1)
		return 
	end
end

swingEvent.OnServerEvent:Connect(function(plr, action, toolName, lookVec)

	local char = plr.Character
	local hum = char:WaitForChild('Humanoid')
	local hrp = char:WaitForChild('HumanoidRootPart')
	
	local WeaponStats = WeaponInfoModule:getWeapon(toolName)
	local damage = WeaponStats.Damage	
	local waitBetweenHits = WeaponStats.WaitBetweenHits
	local HitboxSize = WeaponStats.HitboxSize
	local HitboxOffset = WeaponStats.HitboxOffset
	local HeavyDamage = WeaponStats.HeavyDamage
	local HeavyHitboxSize = WeaponStats.HeavyHitboxSize
	local HeavyHitboxOffset = WeaponStats.HeavyHitboxOffset
	local SwordSwingPause = WeaponStats.SwordSwingPause
	local SwingSpeed = WeaponStats.SwingSpeed
	local HeavyForwardTime = WeaponStats.HeavyForwardTime
	local MaxCombo = WeaponStats.MaxCombo
	
	local stunned = char:GetAttribute('Stunned')
	local attacked = char:GetAttribute('Attacked')
	local attacking = char:GetAttribute('Attacking')
	local isRagdoll = char:GetAttribute('isRagdoll')
	local swing = char:GetAttribute('Swing')
	local blocking = char:GetAttribute('isBlocking')
	local parrying = char:GetAttribute('Parrying')
	local running = char:GetAttribute('Running')
	local iframes = char:GetAttribute('iFrames')
	local Heavy = char.HumanoidRootPart:FindFirstChild(SoundFolder.Tools[toolName]:FindFirstChild("critical").Name) 
	local usingMove = char:GetAttribute('UsingMove')
	local wallRunning = char:GetAttribute('WallRunning')
	local Aerial = char.HumanoidRootPart:FindFirstChild(SoundFolder.Tools[toolName]:FindFirstChild("aerial").Name) 

	---------------------------------------------------------------------------------------------------------------------------------------------------------
	Feint(char, hum, toolName, action)

	if attacking or attacked or stunned or isRagdoll or swing or blocking or parrying or iframes or Heavy or Aerial or usingMove or wallRunning then return end

	char:SetAttribute('Attacking', true)
	char:SetAttribute('Swing', true)

	ServerCombatModules.ChangeCombo(char, toolName)
	ServerCombatModules.StopAnims(hum)

	hum.WalkSpeed = walkspeedDuring
	hum.JumpHeight = jumpheightDuring

	local trail = char:WaitForChild(toolName):WaitForChild("BodyAttach"):FindFirstChild("Trail")
	if trail then trail.Enabled = true end

	local ragdoll = false

	local newHitbox = HitboxModule.new()
	newHitbox.Size = HitboxSize
	newHitbox.CFrame = hrp
	newHitbox.Offset = HitboxOffset
	
	if running then
		char:SetAttribute('Running', false)
		runningStopEvent:FireClient(plr)
	end
	
	Heavy_Attack(char,hum,toolName,action,trail,newHitbox,HeavyHitboxSize, HeavyHitboxOffset, SwordSwingPause, HeavyForwardTime)
	Air_Attack(char,hum,toolName,action,trail,newHitbox, lookVec)

	newHitbox.onTouch = function(enemyHum)
		if enemyHum ~= hum then
			if enemyHum.Parent:GetAttribute("PlayerTag") then
				enemyHum.Parent:SetAttribute("PlayerTag", plr.Name)
			else
				enemyHum.Parent:SetAttribute("PlayerTag", plr.Name)
			end
			
			local isHeavyHit = char.HumanoidRootPart:FindFirstChild(SoundFolder.Tools[toolName]:FindFirstChild("critical").Name) 

			if enemyHum.Parent:GetAttribute('Parrying') then ServerCombatModules.Parrying(char, enemyHum.Parent) return end
			if enemyHum.Parent:GetAttribute('isBlocking') and not isHeavyHit and ServerCombatModules.CheckInfront(char, enemyHum.Parent) then ServerCombatModules.Blocking(enemyHum.Parent, damage) return end
			if enemyHum.Parent:GetAttribute('isRagdoll') or enemyHum.Health <= 0 then return end
			if enemyHum.Parent:GetAttribute('iFrames') then RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('iFramesSuccess', enemyHum.Parent) return end
			
			
			if enemyHum.Parent:GetAttribute('isBlocking') and isHeavyHit and ServerCombatModules.CheckInfront(char, enemyHum.Parent) then
				ServerCombatModules.Blocking(enemyHum.Parent, damage*2)
			end
								
			if char.HumanoidRootPart:FindFirstChild(SoundFolder.Tools[toolName]:FindFirstChild("critical").Name) then char:SetAttribute("Combo",4) end
			
			if char.HumanoidRootPart:FindFirstChild(SoundFolder.Tools[toolName]:FindFirstChild("running").Name) then char:SetAttribute("Combo",4) end


			local enemyChar = enemyHum.Parent
			local enemyHrp =  enemyChar:WaitForChild('HumanoidRootPart')
			
			local center = (enemyHrp.Position - hrp.Position).Unit
			local strength = 10

			ServerCombatModules.StopAnims(enemyHum)
			
			local currCombo = char:GetAttribute('Combo')
			if currCombo == 1 then
				enemyHum.Animator:LoadAnimation(AnimationsFolder.Tools.hit1):Play()
			elseif currCombo == 2 then
				enemyHum.Animator:LoadAnimation(AnimationsFolder.Tools.hit2):Play()
			elseif currCombo == 3 then
				enemyHum.Animator:LoadAnimation(AnimationsFolder.Tools.hit1):Play()
			else
				enemyHum.Animator:LoadAnimation(AnimationsFolder.Tools.hit2):Play()
			end
			
			if currCombo == MaxCombo and not isHeavyHit then
				strength = 60
			end
			
			local knockback = center * strength
			if currCombo < 4 then
				HitServiceModule.Hit(enemyHum, damage, .5, knockback, false, 0)
			elseif isHeavyHit then
				HitServiceModule.Hit(enemyHum, damage, .5, knockback, false, 0)
			else
				HitServiceModule.Hit(enemyHum, damage, 2, knockback, false, 0)
				RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('SlowStunned', enemyChar)
				RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('HighlightYellow', enemyChar)
				enemyChar:SetAttribute('SlowStunned', true)
			end
			enemyChar:SetAttribute('Parrying', false)
			RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('Blood', enemyChar, currCombo)
			
			local HitSound = SoundFolder:WaitForChild('Tools'):WaitForChild(toolName):WaitForChild(math.random(2) == 1 and 'hit1' or 'hit2'):Clone()
			HitSound.Parent = char:WaitForChild('HumanoidRootPart')
			HitSound:Play()
			Debris:AddItem(HitSound, 2)
		end
	end
	
	local swingAnim = ServerCombatModules.GetSwingAnimation(char, toolName)
	local playSwingAnimation = hum.Animator:LoadAnimation(swingAnim)
	
	playSwingAnimation.KeyframeReached:Connect(function(kf)
		if kf == 'Hit' then
			char:SetAttribute('Running', false)
			runningStopEvent:FireClient(plr)
			char:SetAttribute('Attacking', false)
			task.spawn(function()
				if not char:GetAttribute('Stunned') and char:FindFirstChild(toolName) then
					newHitbox:Start()
					task.wait(.1)		
					newHitbox:Stop()
					newHitbox:Destroy()

				else
					newHitbox:Stop()
					newHitbox:Destroy()
				end
			end)
			
			if char:GetAttribute('Combo') == MaxCombo then
				task.wait(comboCooldown)
			else
				task.wait(waitBetweenHits)
			end
		end
		
		if kf == 'Hold' then
			playSwingAnimation:AdjustSpeed(0)
			task.wait(SwordSwingPause)
			playSwingAnimation:AdjustSpeed(SwingSpeed)
			
			local SwordSwingSound = SoundService:WaitForChild('SFX'):WaitForChild('Tools'):WaitForChild(toolName):WaitForChild(math.random(2) == 1 and 'swing1' or 'swing2'):Clone()
			SwordSwingSound.Parent = char:WaitForChild('HumanoidRootPart')
			SwordSwingSound:Play()
			Debris:AddItem(SwordSwingSound, 1)
		end
	end)
		
	playSwingAnimation.Stopped:Connect(function()
		char:SetAttribute('Running', false)
		runningStopEvent:FireClient(plr)
		hum.WalkSpeed = walkspeedDefault
		hum.JumpHeight = jumpheightDefault
		char:SetAttribute('Swing', false)
		if char:FindFirstChild(toolName) and trail then  
			trail.Enabled = false 
		end
	end)
	
	if not char.HumanoidRootPart:FindFirstChild(SoundFolder.Tools[toolName]:FindFirstChild("critical").Name) and not char.HumanoidRootPart:FindFirstChild(SoundFolder.Tools[toolName]:FindFirstChild("aerial").Name) then
		if char:GetAttribute('Combo') ~= MaxCombo then
			playSwingAnimation:Play()
			playSwingAnimation:AdjustSpeed(SwingSpeed)
		else
			playSwingAnimation:Play()
			playSwingAnimation:AdjustSpeed(SwingSpeed)
		end
	end
end)