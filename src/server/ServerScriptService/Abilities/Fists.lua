local Fists = {}

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
local walkspeedDuring = 4
local jumpheightDuring = 0
local walkspeedDefault = 9
local jumpheightDefault = 4

-- Whirlwind Data
local barrageCooldown = 5
local barrageDamage = 12

-- Functions
function Fists.Barrage(attacker)
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
		attacker.Backpack.Fists.Parent = char
		return
	end
	
	local CurrentCoolDowns = ActiveCDModule:GetCooldowns()

	if CurrentCoolDowns[attacker.Name] and CurrentCoolDowns[attacker.Name]["Barrage"] and (tick() - CurrentCoolDowns[attacker.Name]["Barrage"] >= barrageCooldown) then
	else
		if not CurrentCoolDowns[attacker.Name] or not CurrentCoolDowns[attacker.Name]["Barrage"] then
		else
			if (tick() - CurrentCoolDowns[attacker.Name]["Barrage"] < barrageCooldown) then 
				attacker.Backpack.Fists.Parent = char
				return
			end
		end
	end
	CooldownHandler:Fire(attacker, "Barrage")

	char:SetAttribute('Attacking', true)
	char:SetAttribute('Swing', true)
	char:SetAttribute('UsingMove', true)


	hum.WalkSpeed = walkspeedDuring
	hum.JumpHeight = jumpheightDuring

	local newHitbox = HitboxModule.new()
	newHitbox.Size = Vector3.new(8,6,6)
	newHitbox.CFrame = char:WaitForChild('HumanoidRootPart')
	newHitbox.Offset = CFrame.new(0,0,-2.5)

	local running = char:GetAttribute('Running')
	
	if running then
		char:SetAttribute('Running', false)
		runningStopEvent:FireClient(attacker)
	end

	char:SetAttribute("Combo",4)	
	
	local function createAndStartHitbox()
		local newHitbox = HitboxModule.new()
		newHitbox.Size = Vector3.new(8,6,6)
		newHitbox.CFrame = char:WaitForChild('HumanoidRootPart').CFrame * CFrame.new(0,0,-2.5)
		
		local soundName = math.random(2) == 1 and 'barrage3' or 'barrage4'
		local barrageSound = SoundFolder:WaitForChild('Abilities'):WaitForChild(soundName):Clone()
		barrageSound.Parent = char:WaitForChild('HumanoidRootPart')
		barrageSound:Play()
		Debris:AddItem(barrageSound, 3)

		newHitbox.onTouch = function(enemyHum)
			if enemyHum ~= hum and enemyHum.Health > 0 then
				if enemyHum.Parent:GetAttribute('Parrying') then ServerCombatModules.Parrying(char, enemyHum.Parent) return end
				if enemyHum.Parent:GetAttribute('isBlocking') and ServerCombatModules.CheckInfront(char, enemyHum.Parent) then ServerCombatModules.Blocking(enemyHum.Parent, barrageDamage) return end
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
				
				local soundName = math.random(2) == 1 and 'barrage1' or 'barrage2'
				local barrageSound = SoundFolder:WaitForChild('Abilities'):WaitForChild(soundName):Clone()
				barrageSound.Parent = char:WaitForChild('HumanoidRootPart')
				barrageSound:Play()
				Debris:AddItem(barrageSound, 3)

				HitServiceModule.Hit(enemyHum, barrageDamage, .5, false, false, 0)
			end
		end

		newHitbox:Start()
		task.wait(.05)
		newHitbox:Stop()
		newHitbox:Destroy()
	end

	local barrageAnimation = AnimationsFolder:WaitForChild("Abilities").barrage	
	local barrageAnim = hum.Animator:LoadAnimation(barrageAnimation)
	barrageAnim:Play()
	barrageAnim:AdjustSpeed(1)

	char:FindFirstChildOfClass('Humanoid'):UnequipTools('Barrage')
	attacker.Backpack.Fists.Parent = char

	barrageAnim.KeyframeReached:Connect(function(kf)
		if kf:find("Hit") then
			char:SetAttribute('Running', false)
			runningStopEvent:FireClient(attacker)
			print('hitbox')
			task.spawn(function()
				if not char:GetAttribute('Stunned') then
					createAndStartHitbox()
				end
			end)
		end
		if kf == 'HitFinal' then
			char:SetAttribute('Running', false)
			runningStopEvent:FireClient(attacker)
			char:SetAttribute('Attacking', false)
		end
	end)

	barrageAnim.Stopped:Connect(function()
		char:SetAttribute('Running', false)
		char:SetAttribute('Attacking', false)
		runningStopEvent:FireClient(attacker)
		hum.WalkSpeed = walkspeedDefault
		hum.JumpHeight = jumpheightDefault
		char:SetAttribute('Swing', false)

		char:SetAttribute('UsingMove', false)	
	end)
end

return Fists
