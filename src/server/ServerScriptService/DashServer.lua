local RS = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")
local dashEvent = RS:WaitForChild('Events').Dash
local remotes = RS:WaitForChild('Events')
local vfxEvent = remotes.VFX
local debris = game:GetService('Debris')
local SoundService = game:GetService('SoundService')
local SoundFolder = SoundService:WaitForChild('SFX')
local Debris = game:GetService('Debris')


dashEvent.OnServerEvent:Connect(function(plr, action)
	local char = plr.Character
	local hum = char:WaitForChild('Humanoid')

	if action then
		char:SetAttribute('Dashing', true)
		char:SetAttribute('iFrames', true)

		vfxEvent:FireAllClients("Dashing", char, 0.5)
		vfxEvent:FireAllClients('HighlightGrey', char, 0.4)
		char:SetAttribute('iFrames', true)
		
		local DashSound = SoundFolder.Movement:WaitForChild("dash"):Clone()
		DashSound.Parent = char.HumanoidRootPart
		DashSound:Play()
		Debris:AddItem(DashSound,2)
	else
		char:SetAttribute('Dashing', false)
		char:SetAttribute('iFrames', false)
	end
end)