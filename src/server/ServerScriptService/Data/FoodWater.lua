local SS = game:GetService('ServerStorage')
local modules = SS:WaitForChild('Modules')
local module = require(modules.FoodWaterModule)

local foodInterval = 16
local waterInterval = 12

local function playerAdded(player)

	local character = player.Character or player.CharacterAdded:Wait()
	
	repeat task.wait() until player:WaitForChild('PlayerData')

	task.spawn(function()
		while true do
			task.wait(foodInterval)
			if character.Humanoid.Health >= 0 then
				module.FoodAdd(player, -0.5)
			end
		end
	end)
	task.spawn(function()
		while true do
			task.wait(waterInterval)
			if character.Humanoid.Health >= 0 then
				module.WaterAdd(player, -0.5)
			end
		end
	end)
end

game.Players.PlayerAdded:Connect(playerAdded)
