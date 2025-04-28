local Players = game:GetService('Players')

-- Player attributes set
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		char:SetAttribute('Combo', 1)
		char:SetAttribute('Stunned', false)
		char:SetAttribute('Swing', false)
		char:SetAttribute('Attacked', false)
		char:SetAttribute('Attacking', false)
		char:SetAttribute('iFrames', false)
		char:SetAttribute('isBlocking', false)
		char:SetAttribute('Posture', 0)
		char:SetAttribute('Parrying', false)
		char:SetAttribute('Running', false)
		char:SetAttribute('ParryTrue', false)
		char:SetAttribute('SlowStunned', false)
		char:SetAttribute('UsingMove', false)

	end)
end)


-- Hide player name tag
game.Players.PlayerAdded:connect(function(player)
	player.CharacterAdded:connect(function(character)
		character:WaitForChild("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end)
end)