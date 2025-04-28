local Fire = {}

-- Services
local RS = game:GetService('ReplicatedStorage')
local SS = game:GetService('ServerStorage')
local SoundService = game:GetService('SoundService')
local Debris = game:GetService('Debris')
local TweenService = game:GetService('TweenService')

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
local walkspeedDuring = 4
local jumpheightDuring = 4
local walkspeedDefault = 9
local jumpheightDefault = 4

-- Fireball Data
local fireballCooldown = 3
local fireballDamage = 12
local fireballHit

-- Functions
function Fire.Fireball(attacker)
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

	if attacking or attacked or stunned or isRagdoll or swing or blocking or parrying or iframes or Heavy then 
		return
	end
	
	local CurrentCoolDowns = ActiveCDModule:GetCooldowns()

	if CurrentCoolDowns[attacker.Name] and CurrentCoolDowns[attacker.Name]["Fireball"] and (os.time() - CurrentCoolDowns[attacker.Name]["Fireball"] >= fireballCooldown) then
	else
		if not CurrentCoolDowns[attacker.Name] or not CurrentCoolDowns[attacker.Name]["Fireball"] then
		else
			if (os.time() - CurrentCoolDowns[attacker.Name]["Fireball"] < fireballCooldown) then 

				return
			end
		end
	end
	CooldownHandler:Fire(attacker, "Fireball")
	
	char:FindFirstChildOfClass('Humanoid'):UnequipTools('Fireball')
	task.spawn(function()
		local EquippedWeapon = nil
		for _, tool in ipairs(attacker.Backpack:GetChildren()) do
			if tool:IsA("Tool") and tool:GetAttribute("Type") == "Attack" then
				EquippedWeapon = tool
				break
			end
		end
		EquippedWeapon.Parent = char

	end)




	char:SetAttribute('Attacking', true)
	char:SetAttribute('Swing', true)
	char:SetAttribute('UsingMove', true)

	hum.WalkSpeed = walkspeedDuring
	hum.JumpHeight = jumpheightDuring
	
	local ballPart = Instance.new('Part', workspace)
	ballPart.Name = 'FireballPart'
	ballPart.CFrame = char:WaitForChild('HumanoidRootPart').CFrame
	ballPart.CanCollide = false
	ballPart.Anchored = true
	ballPart.Size = Vector3.new(1,1,1)
	ballPart.Transparency = 1
	
	local newHitbox = HitboxModule.new()
	newHitbox.Size = Vector3.new(5,5,5)
	newHitbox.CFrame = ballPart
	newHitbox.Offset = CFrame.new(0,0,0)

	local running = char:GetAttribute('Running')
	
	if running then
		char:SetAttribute('Running', false)
		runningStopEvent:FireClient(attacker)
	end

	char:SetAttribute("Combo",4)	
	
	fireballHit = false
	
	newHitbox.onTouch = function(enemyHum)		
		if enemyHum ~= hum and enemyHum.Health > 0 then

			if enemyHum.Parent:GetAttribute('Parrying') then ServerCombatModules.Parrying(char, enemyHum.Parent) return end
			if enemyHum.Parent:GetAttribute('isBlocking') and ServerCombatModules.CheckInfront(char, enemyHum.Parent) then ServerCombatModules.Blocking(enemyHum.Parent, fireballDamage) return end
			if enemyHum.Parent:GetAttribute('isRagdoll') or enemyHum.Health <= 0 then return end
			if enemyHum.Parent:GetAttribute('iFrames') then RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('iFramesSuccess', enemyHum.Parent) return end			
						
			ServerCombatModules.StopAnims(enemyHum)
			
			enemyHum.Animator:LoadAnimation(AnimationsFolder.Tools.hit1):Play()			
			
			local enemyChar = enemyHum.Parent
			enemyChar:SetAttribute('Parrying', false)
			RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('Blood', enemyChar)

			local HitSound = SoundFolder:WaitForChild('Abilities'):WaitForChild('fireball3'):Clone()
			HitSound.Parent = char:WaitForChild('HumanoidRootPart')
			HitSound:Play()
			Debris:AddItem(HitSound, 2)
			
			local HitSound2 = SoundFolder:WaitForChild('Abilities'):WaitForChild('fireball4'):Clone()
			HitSound2.Parent = char:WaitForChild('HumanoidRootPart')
			HitSound2:Play()
			Debris:AddItem(HitSound2, 2)
			
			HitServiceModule.Hit(enemyHum, fireballDamage, .5, false, false, 0)
			
			RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('FireballExplode', ballPart)
			fireballHit = true
		end
	end
	
	local fireballAnimation = AnimationsFolder:WaitForChild("Abilities").fireball	
	local fireballAnim = hum.Animator:LoadAnimation(fireballAnimation)
	fireballAnim:Play()
	fireballAnim:AdjustSpeed(1)
		
	local fireballSound1 = SoundFolder:WaitForChild('Abilities'):WaitForChild('fireball1'):Clone()
	fireballSound1.Parent = char:WaitForChild('HumanoidRootPart')
	fireballSound1:Play()
	Debris:AddItem(fireballSound1, 3)

	fireballAnim.KeyframeReached:Connect(function(kf)		
		if kf == 'Hit' then			
			fireballAnim:AdjustSpeed(1)			
			char:SetAttribute('Running', false)
			runningStopEvent:FireClient(attacker)
			char:SetAttribute('Attacking', false)
			task.spawn(function()
				if not char:GetAttribute('Stunned') then
					newHitbox:Start()
					
					local fireballSound2 = SoundFolder:WaitForChild('Abilities'):WaitForChild('fireball2'):Clone()
					fireballSound2.Parent = char:WaitForChild('HumanoidRootPart')
					fireballSound2:Play()
					Debris:AddItem(fireballSound2, 3)
					
					local Tween = TweenService:Create(ballPart, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = ballPart.CFrame + char.HumanoidRootPart.CFrame.LookVector * 70})
					Tween:Play()
					
					RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('Fireball', ballPart)
					
					task.wait(1)		
					
					if fireballHit ~= true then
						RS:WaitForChild('Events'):WaitForChild('VFX'):FireAllClients('FireballExplode', ballPart)
					end
					
					newHitbox:Stop()
					newHitbox:Destroy()
				else
					ballPart:Destroy()
					
					newHitbox:Stop()
					newHitbox:Destroy()
				end
			end)
		end
	end)

	fireballAnim.Stopped:Connect(function()
		char:SetAttribute('Running', false)
		runningStopEvent:FireClient(attacker)
		hum.WalkSpeed = walkspeedDefault
		hum.JumpHeight = jumpheightDefault
		char:SetAttribute('Swing', false)
		char:SetAttribute('UsingMove', false)	
	end)
end

return Fire
