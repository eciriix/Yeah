local Players = game:GetService("Players")
local SS = game:GetService("ServerStorage")
local maxLevel = 50

local module = {}

local SSS = game:GetService("ServerScriptService")
local DataStore2 = require(SSS.Data.Datastore.DataStore2)

module.ExperienceAdd = function(player, amount)
	
	if player.PlayerData.Level.Value >= maxLevel then return end
	
	local xpStore = DataStore2('XP', player)
	xpStore:Increment(amount)
	
end

module.LevelSet = function(player, amount)

	local levelStore = DataStore2('Level', player)
	levelStore:Set(amount)

end

return module
