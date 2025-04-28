-- Services
local RS = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")
local debris = game:GetService('Debris')
local SoundService = game:GetService('SoundService')
local SoundFolder = SoundService:WaitForChild('SFX')
local Debris = game:GetService('Debris')

-- Folders
local climbEvent = RS:WaitForChild('Events').Climbing
local remotes = RS:WaitForChild('Events')
local vfxEvent = remotes.VFX

climbEvent.OnServerEvent:Connect(function(plr, climb)
	local char = plr.Character
	local hum = char:WaitForChild('Humanoid')
	
	if climb == 1 then
		local climbSound = SoundFolder.Movement:WaitForChild("climb1"):Clone()
		climbSound.Parent = char.HumanoidRootPart
		climbSound:Play()
		Debris:AddItem(climbSound,2)
	elseif climb == 2 then
		local climbSound2 = SoundFolder.Movement:WaitForChild("climb2"):Clone()
		climbSound2.Parent = char.HumanoidRootPart
		climbSound2:Play()
		Debris:AddItem(climbSound2,2)
	elseif climb == 3 then
		local vaultSound = SoundFolder.Movement:WaitForChild("vault"):Clone()
		vaultSound.Parent = char.HumanoidRootPart
		vaultSound:Play()
		Debris:AddItem(vaultSound,2)
		
		
		vfxEvent:FireAllClients("Dashing", char, 0.4)
	end

end)