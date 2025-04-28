-- Services
local Players = game:GetService('Players')
local SoundService = game:GetService('SoundService')
local Debris = game:GetService('Debris')
local RS = game:GetService('ReplicatedStorage')

-- Folder
local SFXFolder = SoundService.SFX.Movement

-- Event
local fallEvent = RS.Events.Fall
local BindableEvent = game.ReplicatedStorage:WaitForChild('Events').FallDialogue


-- Player
local plr = Players.LocalPlayer
local Character = plr.Character or plr.CharacterAdded:Wait()
local hum = Character.Humanoid
local hrp = Character.HumanoidRootPart

hum.StateChanged:Connect(function(OldState, NewState)
	if NewState == Enum.HumanoidStateType.Landed then
		local height = -hrp.Velocity.Y
		if height >= 100 then
			local damage = (height / 80) ^ 5.5
			fallEvent:FireServer(damage)
			BindableEvent:Fire()
			local HeavyAnim = hum.Animator:LoadAnimation(RS.Animations.Movement.fallrecovery)
			HeavyAnim:Play()
			if damage <= 40 then
				local FallSound = SFXFolder.fall:Clone() 
				FallSound.Parent = Character.HumanoidRootPart
				FallSound:Play()
				Debris:AddItem(FallSound,2)
			else
				local FallSound = SFXFolder.fallheavy:Clone() 
				FallSound.Parent = Character.HumanoidRootPart
				FallSound:Play()
				Debris:AddItem(FallSound,2)
			end
		end
	end
end)