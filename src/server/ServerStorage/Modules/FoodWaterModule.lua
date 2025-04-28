local Players = game:GetService("Players")
local SS = game:GetService("ServerStorage")

local maxFood = 100
local maxWater = 100
local foodDamage = 15
local waterDamage = 15

local module = {}

local SSS = game:GetService("ServerScriptService")
local DataStore2 = require(SSS.Data.Datastore.DataStore2)

module.FoodAdd = function(player, amount)
	local foodStore = DataStore2('Food', player)
	local currentFood = foodStore:Get(0)  

	local newFood = math.clamp(currentFood + amount, 0, maxFood)
	foodStore:Set(newFood)
	
	if newFood == 0 then
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local damage = humanoid.MaxHealth * (foodDamage / 100)
			humanoid:TakeDamage(damage)
		end
	end
end

module.WaterAdd = function(player, amount)
	local waterStore = DataStore2('Water', player)
	local currentWater = waterStore:Get(0)  
	local newWater = math.clamp(currentWater + amount, 0, maxWater)

	waterStore:Set(newWater)
	
	if newWater == 0 then
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local damage = humanoid.MaxHealth * (waterDamage / 100)
			humanoid:TakeDamage(damage)
		end
	end
end

return module
