local DataStore2 = require(script.DataStore2)

DataStore2.Combine('DATA', 'Level', 'XP', 'Food', 'Water')

local defaultLevel = 1
local defaultXP = 0
local defaultFood = 100
local defaultWater = 100
local maxLevel = 60

local function xpNeeded(level)
	return 100 + level * 5
end

local Players = game:GetService('Players')

Players.PlayerAdded:Connect(function(player)
	local playerData = Instance.new('Folder', player)
	playerData.Name = 'PlayerData'
	
	print('Searching for PlayerData on:', player)
	repeat task.wait() until player:WaitForChild('PlayerData')
	print(player, ': PlayerData found.')
	
	local levelValue = Instance.new('IntValue', playerData)
	levelValue.Name = 'Level'
	local xpValue = Instance.new('IntValue', playerData)
	xpValue.Name = 'XP'
	
	local levelStore = DataStore2('Level', player)
	local xpStore = DataStore2('XP', player)
	
	
	
	local foodValue = Instance.new('NumberValue', playerData)
	foodValue.Name = 'Food'
	local waterValue = Instance.new('NumberValue', playerData)
	waterValue.Name = 'Water'
	
	local foodStore = DataStore2('Food', player)
	local waterStore = DataStore2('Water', player)

	

	local function updateLevel(level)
		player.PlayerData:WaitForChild('Level').Value = level
	end
	local function updateXP(xp)
		if xp >= xpNeeded(levelStore:Get(defaultLevel)) then -- if xp is greater than whats needed
			xpStore:Increment(xpNeeded(levelStore:Get(defaultLevel)) * -1) 
			levelStore:Increment(1)
			
		else
			player.PlayerData.XP.Value = xp
		end
	end
		
	local function updateFood(food)
		player.PlayerData:WaitForChild('Food').Value = food
	end
	local function updateWater(water)
		player.PlayerData:WaitForChild('Water').Value = water
	end

		
		
	updateLevel(levelStore:Get(defaultLevel))
	updateXP(xpStore:Get(defaultXP))
	updateFood(foodStore:Get(defaultFood))
	updateWater(waterStore:Get(defaultWater))

	levelStore:OnUpdate(updateLevel)
	xpStore:OnUpdate(updateXP)
	foodStore:OnUpdate(updateFood)
	waterStore:OnUpdate(updateWater)
end)

