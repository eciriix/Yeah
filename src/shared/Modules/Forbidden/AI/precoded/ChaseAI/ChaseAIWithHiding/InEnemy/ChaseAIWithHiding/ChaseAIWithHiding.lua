-- Made by crit0271, Forbidden API <3

-- # Services
local players 			= game:GetService("Players")
local rs 				= game:GetService("ReplicatedStorage")
local run 				= game:GetService("RunService")
local debris			= game:GetService("Debris")

-- # Forbidden Modules
local forbidden_rs 		= rs.Modules:WaitForChild("Forbidden")
local std 				= require(forbidden_rs:WaitForChild("Standard"))
local ai 				= require(forbidden_rs:WaitForChild("AI"))

-- # Events
local remotes			= rs:WaitForChild("signals"):WaitForChild("remotes")

local RE_HideEvent		= remotes:WaitForChild("events"):WaitForChild("HideEvent")
local RF_RequestLocker	= remotes:WaitForChild("functions"):WaitForChild("RequestLocker")

-- # Settings
local config = require(script:WaitForChild("Settings"))


-- variables (DO NOT TOUCH)
local isWandering 		= false
local isChasing 		= false
local plrChasing 		= nil
local lastCallTime 		= 0 -- of plrChasing

local creditKill 		= false
local damaged_recently 	= false

if config.PreventAIFromSitting then
	config.enemy_char:WaitForChild("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, false) -- prevents NPC from sitting
end

local events 			= config.enemy_char:WaitForChild("Events")

local BE_StartAI 		= events:WaitForChild("StartAI")
local BE_StopAI 		= events:WaitForChild("StopAI")
local BE_TargetSeen 	= events:WaitForChild("TargetSeen")
local BE_TargetLost 	= events:WaitForChild("TargetLost")



-- User Defineable Functions

local function setNetworkOwner(player: Player)
	-- basically anti-lag, (so people dont get killed where they were 3 seconds ago, though I would delete this if you make TouchedOther kill other people.)
	if config.AntiLag then return end
	config.enemy_char:WaitForChild("HumanoidRootPart"):SetNetworkOwner(player)
end

local function isPlayerHiding(TargetedPlayer: Player)
	local tV = TargetedPlayer:FindFirstChild("TemporaryValues")
	if tV == nil then return false end

	local isHidingObj = tV:FindFirstChild("isHiding")
	if isHidingObj == nil then return false end

	return isHidingObj.Value
end

local function sawPlayerHide(TargetedPlayer: Player)

	plrChasing = TargetedPlayer
	isChasing = true

	RE_HideEvent:FireClient(TargetedPlayer, false)

	local lockerHidingIn = RF_RequestLocker:InvokeClient(TargetedPlayer)
	if lockerHidingIn == nil then warn("No locker found! Player: "  .. TargetedPlayer.Name) return end

	local partToGo = lockerHidingIn:WaitForChild("front")
	if partToGo == nil then warn("No spot for the AI to go in front of the locker to!") return end

	local done = false
	local failure = false

	spawn(function()
		local result = nil
		if #config.standardPathfindSettings > 0 then 
			result = ai.SmartPathfind(config.enemy_char, partToGo, true, config.standardPathfindSettings)
		else
			result = ai.SmartPathfind(config.enemy_char, partToGo, true)
		end

		if result == Enum.PathStatus.NoPath then failure = true done = true warn("No path found!") return end

		done = true
	end)

	-- Handoff to normalcy if failure.
	if failure then
		isChasing = false
		plrChasing = nil
		return 
	end

	while true do
		run.Heartbeat:Wait()
		if not isPlayerHiding(TargetedPlayer) then ai.Stop(config.enemy_char) isChasing = false plrChasing = nil return end -- Handoff to normalcy if the player stops hiding.
		if done then break end
	end

	RE_HideEvent:FireClient(TargetedPlayer, true)

	-- Drag Player Out!!!!!
	print("Reached locker where player is hiding!")

	-- for testing purposes
	local char = TargetedPlayer.Character
	local human = char:WaitForChild("Humanoid")
	human.Health -= 100 -- insta kill!

	-- Handoff to normalcy
	isChasing = false
	plrChasing = false 

	return 
end





-- disables AI for a while it is killing (if enabled)
local function damage_delay_handler()

	if config.disable_ai_while_damaging then
		spawn(function()
			creditKill = true -- if the player is lost and it doesnt think it killed it (based on this variable) then it will call LostPlayer
			config.isActive = false
			task.wait(config.damageDelay)
			config.isActive = true
		end)
	end

	if not(config.disable_ai_while_damaging) then
		spawn(function()
			creditKill = true
			damaged_recently = true
			task.wait(config.damageDelay)
			damaged_recently = false
		end)
	end
end

-- Called if a player that is not targeted is touched.
local function TouchedOther(other_plr_char)

end

-- Called when the targeted player is touched.
local function Damage(player: Player)


	if damaged_recently then return end
	if not config.isActive then return end


	local plr_char = player.Character
	if plr_char == nil then return end
	if plr_char.Name ~= plrChasing.Name then return end -- redundant


	local plr_human = plr_char.Humanoid
	if plr_human.Health <= 0 then return end

	damage_delay_handler() -- mandatory ...
	-- Damage player, SFX, animations, etc...
	local plr_human = plr_char.Humanoid
	plr_human.Health -= config.damageDone

	if plr_human.Health <= 0 then
		-- player is dead now.
		setNetworkOwner(nil)
	end
end

-- t3's purpose is for char.tool.Handle
local function partDescendantOfChar(part) -- HELPER FOR TOUCH HANDLER

	local t1 = part.Parent
	local t2 = nil
	local t3 = nil
	if t1 ~= nil then
		t2 = t1.Parent
		if t2 ~= nil then
			t3 = t2.Parent
		end
	end

	if t1 ~= nil then
		if t1:FindFirstChild("Humanoid") then return t1 end
	else
		return false
	end

	if t2 ~= nil then
		if t2:FindFirstChild("Humanoid") then return t2 end
	else
		return false
	end

	if t3 ~= nil then
		if t3:FindFirstChild("Humanoid") then return t3 end
	else
		return false
	end

	return false

end

-- Determines if a player was touched
local function touchHandler(hit) -- HELPER

	if not config.isActive then return end

	local char = partDescendantOfChar(hit)
	if not(char) then return end

	local player = players:FindFirstChild(char.Name)
	if player == nil then return end

	if player == plrChasing then
		Damage(plrChasing)
	else
		TouchedOther(char)
	end

end

-- During the continous loop to ensure the player should still be chased, your own input. If false, it stops.
local function ContinueChasing(TargetedPlayer: Player)
	if isPlayerHiding(TargetedPlayer) then return false end
	return true
end

-- In case you want to have a hiding feature, etc... (Once, see ContinueChasing for continous calls)
local function ConfirmPlayerChase(TargetedPlayer: Player)
	if isPlayerHiding(TargetedPlayer) then return false end
	return true -- for no effect
end

-- CALLED WHENEVER THE AI STARTS TO CHASE A PLAYER
local function PlayerChaseBegan(TargetedPlayer: Player)
	BE_TargetSeen:Fire(TargetedPlayer)
	setNetworkOwner(TargetedPlayer)
	return true -- for no effect
end

-- If you want ConfirmPlayerLost, you will need to go to Chase, due to a variety of reasons for the player to be lost.

-- CALLED WHENEVER THE AI LOSES THE TARGETED PLAYER!
local function LostPlayer(TargetedPlayer: Player, overrideNetworkReset: boolean)
	BE_TargetLost:Fire(TargetedPlayer)

	creditKill = false
	config.enemy_human.WalkSpeed = config.wanderSpeed

	if isPlayerHiding(TargetedPlayer) and config.LockerChase then 
		sawPlayerHide(TargetedPlayer)
	end

	if not overrideNetworkReset then
		setNetworkOwner(nil)
	end

end

-- Called when the AI starts to wander.
local function WanderStarted(location: Vector3) -- wander ends when a player is begun to be chased.
	setNetworkOwner(nil)
end











-- Suggested not to mess with the functions below, they are the core functions, but if you need
-- to change something, by all means do it!











-- If config.doRandomWander is TRUE
-- Uses the config.nodes_table and makes a node above those floors at a random point.
local prev_debug_nodes = {}
local function getRandomLocationInMap()

	local randomFloor = nil

	-- Honestly, I do not know why, I do not want to know why, nor do I care why. But this loop fixed a bug! I love this loop! It is pointless! But I love it! I am going insane!
	while randomFloor == nil do
		run.Heartbeat:Wait()

		local randInt = math.random(1, #config.nodes_table)
		local __randomFloor = config.nodes_table[randInt]
		if __randomFloor:IsA("BasePart") then
			randomFloor = __randomFloor
		end
	end


	-- Gets a random location above the floor given.
	local rf_pos = randomFloor.Position
	local sizeRand = Vector3.new(math.random(- randomFloor.Size.X / 2, randomFloor.Size.X / 2), 0, math.random(- randomFloor.Size.Z / 2, randomFloor.Size.Z / 2))
	local vec3 = Vector3.new(rf_pos.X + sizeRand.X, rf_pos.Y + randomFloor.Size.Y / 2 + 2, rf_pos.Z + sizeRand.Z)

	--print("Making node at ")
	--print(vec3)
	for i, v in prev_debug_nodes do
		v:Destroy()
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Color = Color3.fromRGB(255,255,0)
	part.Size = Vector3.new(2,2,2)
	part.Position = vec3
	part.Parent = workspace
	--print(part)
	table.insert(prev_debug_nodes, part)

	if config.debug_rand_pos then part.Transparency = 0.25 end

	return part
end

-- If config.doRandomWander is FALSE
-- Returns a random node from the config.nodes_table for the AI to wander to.
local function getRandomNode()
	if config.nodes_table == nil then error("config.nodes_table is nil.") end
	if #config.nodes_table <= 0 then error("No nodes!") end
	return config.nodes_table[math.random(1, #config.nodes_table)]
end

local function isInView(plr_char: Model) -- Determines if a model is in the view of the AI.

	-- idiot protection
	if config.detectionFOV < 0 then config.detectionFOV = 0 end
	if config.detectionFOV > 180 then config.detectionFOV = 180 end

	local plr_hrt = plr_char.HumanoidRootPart
	local result = std.math.LineOfSight(config.enemy_char, plr_char, {range = config.detectionRange, seeThroughTransparentParts = config.seeThroughTransparent})

	if result then
		local isInfront = false
		local isNextTo = false
		local angle = math.acos(config.enemy_hrt.CFrame.LookVector:Dot((plr_hrt.Position-config.enemy_hrt.Position).Unit))
		local isInFOVAngle = angle < config.detectionFOV * (math.pi / 180) -- works on 0: Ahead to PI: Behind (symmetrical on left and right sides of AI)
		if isInFOVAngle then
			return true
		end
	end

	return false
end

-- Track to the last known position
local chasePart = Instance.new("Part")
chasePart.Shape = Enum.PartType.Ball
chasePart.Color = Color3.new(0.384314, 0.341176, 1)
chasePart.Material = Enum.Material.Neon
chasePart.Anchored = true
chasePart.Size = Vector3.new(1,1,1)
chasePart.CanCollide = false
chasePart.Transparency = 0.5
chasePart.Name = "ChasePartForNPC-Forbidden"
chasePart.Parent = workspace

local canChaseToCorner = false
local function Chase(player: Player)
	if isChasing then return end
	isWandering = false

	local function stopChasing() -- if the AI stops chasing someone
		config.enemy_human.WalkSpeed = config.wanderSpeed
		plrChasing = nil
		isChasing = false
	end

	setNetworkOwner(player)

	local plr_char = player.Character
	if plr_char == nil then warn("Player is nil!") return end

	local function trackPlayer()
		if #config.standardPathfindSettings > 0 then 
			ai.SmartPathfind(config.enemy_char, player.Character, false, {Tracking = true, StandardPathfindingSettings = config.standardPathfindSettings, Visualize = true}) -- start player chase.
		else
			ai.SmartPathfind(config.enemy_char, player.Character, false, {Tracking = true, Visualize = true}) -- start player chase.
		end
		lastCallTime = os.clock()
	end

	-- Stop a previous pathfind.
	if lastCallTime > 0 then ai.Stop(config.enemy_char) lastCallTime = 0 end

	-- Start player tracking.
	trackPlayer()

	local plr_hrt = plr_char.HumanoidRootPart

	-- Chase
	isChasing = true
	config.enemy_human.WalkSpeed = config.chaseSpeed
	plrChasing = player

	local specRelease = false

	PlayerChaseBegan(player)
	while isChasing do
		run.Heartbeat:Wait()

		if plr_char == nil then stopChasing() break end
		local plr_human = plr_char:FindFirstChild("Humanoid")
		if plr_human and plr_human.Health <= 0 then stopChasing() break end

		-- If the NPC loses sight of the player, then chase to its last known location.
		if std.math.LineOfSight(config.enemy_char, plr_char, {range = config.detectionRange, seeThroughTransparentParts = config.seeThroughTransparent}) then
			chasePart.Position = plr_hrt.Position
			canChaseToCorner = true
		else
			-- Make sure the call is not redundant, if it is then just update position.
			if not canChaseToCorner then break end
			canChaseToCorner = false

			-- Stop the tracking
			isWandering = true -- makes the ai believe it is wandering.
			ai.Stop(config.enemy_char)
			task.wait(1/60) -- abritrary guess


			config.enemy_human.WalkSpeed = config.wanderSpeed

			specRelease = true

			spawn(function()
				local result = nil
				local timeNow = os.clock()
				lastCallTime = timeNow
				if #config.standardPathfindSettings > 0 then 
					result = ai.SmartPathfind(config.enemy_char, chasePart, true, {SkipToWaypoint = 2, StandardPathfindingSettings = config.standardPathfindSettings}) -- start player chase.
				else
					result = ai.SmartPathfind(config.enemy_char, chasePart, true, {SkipToWaypoint = 2}) -- start player chase.
				end
				if result == Enum.PathStatus.NoPath then print("No path.") end

				-- When the pathfind is done, either because it got cancelled, or etc...
				if lastCallTime ~= timeNow then return end
				isWandering = false
				lastCallTime = 0

				if config.NotInSightDoSprint then config.enemy_human.WalkSpeed = config.wanderSpeed end
			end)

			break
		end
	end

	-- Announce the player is lost, so that if along the way the NPC finds another player, it will chase them instead
	stopChasing()
	if not specRelease then lastCallTime = 0 end
	if config.NotInSightDoSprint and specRelease then config.enemy_human.WalkSpeed = config.chaseSpeed end
	LostPlayer(player, specRelease)
end



local function Wander()

	if isChasing then 
		--print("A") 
		return 
	end
	if isWandering then 
		--print("B") 
		return 
	end
	if lastCallTime > 0 then 
		--print("C") 
		return 
	end 

	isWandering = true

	config.enemy_human.WalkSpeed = config.wanderSpeed

	spawn(function()
		local function tryPathfind()

			local randomLocation = nil

			if config.doRandomWander then
				randomLocation = getRandomLocationInMap()
			end

			if not config.doRandomWander then
				randomLocation = getRandomNode()
			end

			if randomLocation == nil then warn("Random Location was nil, please make sure all the nodes are correct!") return Enum.PathStatus.NoPath end

			WanderStarted(randomLocation.Position)

			if #config.standardPathfindSettings > 0 then 
				return ai.SmartPathfind(config.enemy_char, randomLocation, true, {StandardPathfindingSettings = config.standardPathfindSettings}) -- start player chase.
			else
				return ai.SmartPathfind(config.enemy_char, randomLocation, true) -- start player chase.
			end
		end

		-- Repeat a pathfind until it likes its location, while ensuring nothing is going haywire in the background.
		lastCallTime = os.clock()
		while tryPathfind() == Enum.PathStatus.NoPath do

			if config.enemy_char == nil then return end
			run.Heartbeat:Wait()
			lastCallTime = os.clock()
			if isChasing then return end
			if not(isWandering) then return end

		end

		if isChasing then return end
		lastCallTime = 0
		isWandering = false

	end)

end

local function GetNearestVisiblePlayer()

	local playersInLOS = {}

	for i, player in players:GetChildren() do

		local plr_char = player.Character
		if plr_char == nil then continue end

		local plr_hrt = plr_char.HumanoidRootPart
		if plr_hrt == nil then continue end

		local dist = (config.enemy_hrt.Position - plr_hrt.Position).Magnitude

		if isInView(plr_char) then
			table.insert(playersInLOS, {dist, player})
			continue
		end

		if dist <= config.detectionBubble then --untested

			local plr_hrt = plr_char.HumanoidRootPart
			local result = std.math.LineOfSight(config.enemy_char, plr_char, {range = config.detectionRange, seeThroughTransparentParts = config.seeThroughTransparent})

			if result then
				table.insert(playersInLOS, {dist, player})
				continue
			end
		end

	end

	local nearestPlr = nil
	local nearestDist = math.huge
	for i, data in pairs(playersInLOS) do

		if nearestDist > data[1] then
			nearestDist = data[1]
			nearestPlr = data[2]
		end

	end

	return nearestPlr
end

local function cleanNodesTable() -- idiot protection

	local function removal(i)
		table.remove(config.nodes_table, i)
	end

	local function doRemove()

		for i, node in pairs(config.nodes_table) do

			if node == nil then
				removal(i)
				doRemove()
				break
			end

			if not node:IsA("BasePart") then
				if node:IsA("Model") then
					if node.PrimaryPart ~= nil then
						config.nodes_table[i] = node.PrimaryPart
					else
						removal(i)
						doRemove()
						break
					end
				end

				removal(i)
				doRemove()
				break
			end
		end
	end

	doRemove()

end

-- The core loop
local function Main()

	cleanNodesTable()

	while true do

		run.Heartbeat:Wait()

		if config.isActive then

			local nearestVisPlayer = GetNearestVisiblePlayer()
			if nearestVisPlayer ~= nil then
				if ConfirmPlayerChase(nearestVisPlayer) then
					Chase(nearestVisPlayer)
				end
			else
				if config.enemy_human.MoveDirection.Magnitude < 0.25 and config.doWander then -- if its not chasing then wander
					Wander()
				end
			end
		end

	end

end

local function stopAI()
	config.isActive = false
	plrChasing = nil
	isChasing = false
	config.enemy_human.WalkSpeed = config.wanderSpeed
end
BE_StopAI.Event:Connect(stopAI)

local function startAI()
	config.isActive = true
end
BE_StartAI.Event:Connect(startAI)

config.enemy_hrt.Touched:Connect(touchHandler)
for i, hitbox in pairs(config.hitboxes) do
	hitbox.Touched:Connect(touchHandler)
end

task.wait(config.AI_Init_Time) -- recommended
Main()