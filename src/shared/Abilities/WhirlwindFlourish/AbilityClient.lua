-- Player/Tool
local plr = game.Players.LocalPlayer
local Tool = script.Parent

-- Events
local AbilityHandler = game.ReplicatedStorage.Events.AbilityHandler
local ConnectionEvent = game.ReplicatedStorage.Events.ToolConnection

-- Data
local Equip = false
local CD = false


Tool.Equipped:Connect(function()
	wait()

	Equip = true
	ConnectionEvent:FireServer('MSword', true)
	
	if plr.Character:GetAttribute('Stunned') then return end
	if plr.Character:GetAttribute('isBlocking') then return end
	if plr.Character:GetAttribute('Attacking') then return end
	if plr.Character:GetAttribute('Attacked') then return end
	if plr.Character:GetAttribute('Swing') then return end
	if plr.Character:GetAttribute('UsingMove') then return end
	if plr.Character:FindFirstChild("Humanoid").Health <= 0 then return end

	if CD == false then		
		CD = true
		AbilityHandler:FireServer("Medium", Tool, "WhirlwindFlourish")

		spawn(function()
			wait(0.5)
			CD = false
		end)
	end
end)

Tool.Unequipped:Connect(function()
	wait()

	Equip = false
	ConnectionEvent:FireServer("MSword", false)
end)
