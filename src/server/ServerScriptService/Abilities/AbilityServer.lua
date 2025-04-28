-- Directories
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Medium = require(game.ServerScriptService.Abilities.Medium)
local Fire = require(game.ServerScriptService.Abilities.Fire)
local Fists = require(game.ServerScriptService.Abilities.Fists)

-- Events and Modules
local AbilityEvent = ReplicatedStorage.Events.AbilityHandler
local CooldownHandler = ReplicatedStorage.Events.CooldownHandler
local ActiveCDModule = require(game.ServerScriptService.ActiveCDModule)
local CooldownRetriever = ReplicatedStorage.Events.CooldownRetriever

AbilityEvent.OnServerEvent:Connect(function(player, abilityType, toolName, abilityName)

	if not toolName then return end

	if abilityType == "Medium" then
		if player.Character:GetAttribute('UsingMove') then return end
		Medium[abilityName](player)
	elseif abilityType == 'Fire' then
		if player.Character:GetAttribute('UsingMove') then return end
		Fire[abilityName](player)
	elseif abilityType == "Fists" then
		if player.Character:GetAttribute('UsingMove') then return end
		Fists[abilityName](player)
	end
end)

CooldownHandler.Event:Connect(function(plr, AbilityName)

	local CurrentCoolDowns = ActiveCDModule:GetCooldowns()
	
	if not CurrentCoolDowns[plr.Name] then
		CurrentCoolDowns[plr.Name] = {}
		print('Cooldowns created, none was established.')
	end

	CurrentCoolDowns[plr.Name][AbilityName] = os.time()
	
end)

CooldownRetriever.OnServerInvoke = function(plr)
	
	local CurrentCoolDowns = ActiveCDModule:GetCooldowns()

	return CurrentCoolDowns
	
end