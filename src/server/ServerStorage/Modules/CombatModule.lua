local module = {}

-- Services
local RS = game:GetService('ReplicatedStorage')
local SS = game:GetService('ServerStorage')
local SoundService = game:GetService('SoundService')
local Debris = game:GetService('Debris')

-- Modules
local ServerModules = SS:WaitForChild('Modules')
local HitServiceModule = require(ServerModules.HitService)
local AnimationModule = require(RS:WaitForChild('Modules'):WaitForChild('Animations'))
local WeaponInfoModule = require(SS.Info.WeaponInfo)

-- Animations
local animations = RS:WaitForChild('Animations')
local WeaponAnimationsFolder = animations:WaitForChild('Tools')

-- Settings
local lastSwing = {}
--local Max_Combo = 4

local function stopAnims(hum)
	for i,v in pairs(hum.Animator:GetPlayingAnimationTracks()) do
		if v.Name ~= 'idle' and v.Name ~= 'WalkAnim' then
			v:Stop()
		end
	end
end

local function GuardBreak(enemyChar, toolName, forced, parriedResult, char)
	
	if parriedResult and enemyChar:GetAttribute('Posture') > 100 then
		RS.Events.VFX:FireAllClients('ParryHit', char)

		local ParriedSound = SoundService:WaitForChild('SFX'):WaitForChild('Tools'):WaitForChild(toolName):WaitForChild(math.random(2) == 1 and 'parried1' or 'parried2'):Clone()
		ParriedSound.Parent = enemyChar:WaitForChild('HumanoidRootPart')
		ParriedSound:Play()
		Debris:AddItem(ParriedSound, 1)	

		stopAnims(char.Humanoid)

		char:WaitForChild('Humanoid').Animator:LoadAnimation(WeaponAnimationsFolder[toolName].Blocking:WaitForChild(math.random(2) == 1 and 'trueparry1' or 'trueparry2')):Play()

		HitServiceModule.Hit(char.Humanoid, 0, 0.3,Vector3.new(0,0,0), false, 0)		
	end
	
	if enemyChar:GetAttribute('Posture') > 100 or forced then
				
		stopAnims(enemyChar.Humanoid)
		enemyChar:SetAttribute('Posture', 0)
		local GuardbreakSound = SoundService:WaitForChild('SFX'):WaitForChild('Tools'):WaitForChild(toolName):WaitForChild('guardbreak'):Clone()
		GuardbreakSound.Parent = enemyChar:WaitForChild('HumanoidRootPart')
		GuardbreakSound:Play()
		Debris:AddItem(GuardbreakSound, 3)

		enemyChar:WaitForChild('Humanoid').Animator:LoadAnimation(WeaponAnimationsFolder[toolName].Blocking.guardbreak):Play()

		HitServiceModule.Hit(enemyChar.Humanoid, 0, 2,Vector3.new(0,0,0), false, 0)
		enemyChar:SetAttribute('SlowStunned', true)
		RS.Events.VFX:FireAllClients('SlowStunned', enemyChar)
		RS.Events.VFX:FireAllClients('HighlightYellow', enemyChar)
		return true
	end
end

module.ChangeCombo = function(char, toolname)
	local combo = char:GetAttribute('Combo')
	local WeaponStats = WeaponInfoModule:getWeapon(toolname)
	
	if lastSwing[char] then
		local passedTime = os.clock() - lastSwing[char]
		
		if passedTime <= 2 then
			if combo >= WeaponStats.MaxCombo then
				char:SetAttribute('Combo', 1)
			else
				char:SetAttribute('Combo', combo+1)
			end
		else
			char:SetAttribute('Combo', 1)
		end
	end
	
	lastSwing[char] = os.clock()
end

module.GetSwingAnimation = function(char, toolName)
	local combo = char:GetAttribute('Combo')
	local WeaponStats = WeaponInfoModule:getWeapon(toolName)
	local currAnim
	
	if combo == WeaponStats.MaxCombo then
		currAnim = WeaponAnimationsFolder:FindFirstChild(toolName):WaitForChild("Attacking")["swing"..combo]
	else
		currAnim = WeaponAnimationsFolder:FindFirstChild(toolName):WaitForChild("Attacking")["swing"..combo]
	end
	
	return currAnim
end

module.StopAnims = function(hum)
	stopAnims(hum)
end

module.Blocking = function(enemyChar, damage)
	if enemyChar:GetAttribute('Posture') <= 100 then
		
		local toolName
		if not enemyChar:FindFirstChildWhichIsA("Tool") then toolName = enemyChar:GetAttribute("Weapon") else toolName = enemyChar:FindFirstChildWhichIsA("Tool").Name end

		RS.Events.VFX:FireAllClients('BlockingHit', enemyChar)

		local postureValue =  enemyChar:GetAttribute('Posture')
		enemyChar:SetAttribute('Posture', postureValue + damage * 4)
		
		local BlockedSound = SoundService:WaitForChild('SFX'):WaitForChild('Tools'):WaitForChild(toolName):WaitForChild(math.random(2) == 1 and 'blocked1' or 'blocked2'):Clone()
		BlockedSound.Parent = enemyChar:WaitForChild('HumanoidRootPart')
		BlockedSound:Play()
		Debris:AddItem(BlockedSound, 1)
		
		GuardBreak(enemyChar, toolName, false, false)
		
	end
end

module.Parrying = function(enemyChar, char)
	
	local toolNameEnemy
	local toolname
	if not enemyChar:FindFirstChildWhichIsA("Tool") then toolNameEnemy = enemyChar:GetAttribute("Weapon") else toolNameEnemy = enemyChar:FindFirstChildWhichIsA("Tool").Name end
	if not char:FindFirstChildWhichIsA("Tool") then toolname = enemyChar:GetAttribute("Weapon") else toolname = char:FindFirstChildWhichIsA("Tool").Name end
	char:SetAttribute('ParryTrue', true)

	if (char:GetAttribute("Posture") - 5) >= 0 then
		char:SetAttribute("Posture",  char:GetAttribute("Posture") - 5)
	end
	
	char:SetAttribute('Parrying', false)

	enemyChar:SetAttribute('Posture', enemyChar:GetAttribute('Posture') + 10)
	
	char:SetAttribute('Combo', 4)
	enemyChar:SetAttribute('Combo', 4)
	
	stopAnims(enemyChar.Humanoid)
	
	if not GuardBreak(enemyChar, toolname, false, true, char) then
		
		RS.Events.VFX:FireAllClients('ParryHit', char)
		
		local ParriedSound = SoundService:WaitForChild('SFX'):WaitForChild('Tools'):WaitForChild(toolname):WaitForChild(math.random(2) == 1 and 'parried1' or 'parried2'):Clone()
		ParriedSound.Parent = enemyChar:WaitForChild('HumanoidRootPart')
		ParriedSound:Play()
		Debris:AddItem(ParriedSound, 1)	

		stopAnims(char.Humanoid)

		enemyChar:WaitForChild('Humanoid').Animator:LoadAnimation(WeaponAnimationsFolder[toolNameEnemy].Blocking:WaitForChild(math.random(2) == 1 and 'trueparry1' or 'trueparry2')):Play()
		char:WaitForChild('Humanoid').Animator:LoadAnimation(WeaponAnimationsFolder[toolname].Blocking:WaitForChild(math.random(2) == 1 and 'trueparry1' or 'trueparry2')):Play()

		HitServiceModule.Hit(enemyChar.Humanoid, 0, 0.5,Vector3.new(0,0,0), false, 0)	
		HitServiceModule.Hit(char.Humanoid, 0, 0.3,Vector3.new(0,0,0), false, 0)	
	end
	
end

module.CheckInfront = function(char, enemyChar)
	
	local rootPart = enemyChar.HumanoidRootPart
	local attackDirection = (char.HumanoidRootPart.Position - rootPart.Position).Unit
	local frontDirection = rootPart.CFrame.LookVector
	local direction = math.acos(attackDirection:Dot(frontDirection)) < math.rad(90)
	
	if not direction then
		return false
	else
		return true
	end
end

return module
