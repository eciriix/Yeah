-- Services
local RS = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")
local debris = game:GetService('Debris')
local SoundService = game:GetService('SoundService')
local SoundFolder = SoundService:WaitForChild('SFX')
local Debris = game:GetService('Debris')
local SS = game:GetService('ServerStorage')

-- Modules
local ServerModules = SS:WaitForChild('Modules')
local HitServiceModule = require(ServerModules.HitService)

-- Folders
local fallEvent = RS:WaitForChild('Events').Fall
local remotes = RS:WaitForChild('Events')
local vfxEvent = remotes.VFX

fallEvent.OnServerEvent:Connect(function(plr, damage)
	local char = plr.Character
	local hum = char:WaitForChild('Humanoid')

	-- fall vfx
	vfxEvent:FireAllClients("Blood", char) 
	vfxEvent:FireAllClients("FallSmoke", char) 
	
	
	-- stun player
	HitServiceModule.Hit(hum, damage, 1.5, false, false, 0)
	char:SetAttribute('SlowStunned', true)
end)