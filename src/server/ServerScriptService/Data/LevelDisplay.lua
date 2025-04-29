local Players = game:GetService("Players")
local SS = game:GetService("ServerStorage")

local function updatePlayerStats(player, levelValue, expValue)
	local playerGui = player:FindFirstChild('PlayerGui')
	if playerGui then
		local statsGui = playerGui:FindFirstChild('StatsGui')
		if statsGui then
			local playerStats = statsGui:FindFirstChild('PlayerStats')
			if playerStats then
				if levelValue then
					local levelLabel = playerStats:FindFirstChild('Level'):FindFirstChild('LevelValue')
					if levelLabel then
						levelLabel.Text = 'Level: ' .. levelValue.Value
					end
				end
				if expValue then
					local expLabel = playerStats:FindFirstChild('Level'):FindFirstChild('EXPValue')
					if expLabel then
						expLabel.Text = 'XP: ' .. expValue.Value
					end
				end
			end
		end
	end
end

local function onCharacterAdded(player, character)
	local playerFolder = player:FindFirstChild('PlayerData')

	if playerFolder then
		local levelValue = playerFolder:FindFirstChild("Level")
		local expValue = playerFolder:FindFirstChild("XP")

		if levelValue then
			updatePlayerStats(player, levelValue, expValue)
			levelValue.Changed:Connect(function()
				updatePlayerStats(player, levelValue, expValue)
			end)
		end

		if expValue then
			updatePlayerStats(player, levelValue, expValue)
			expValue.Changed:Connect(function()
				updatePlayerStats(player, levelValue, expValue)
			end)
		end
	end
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
