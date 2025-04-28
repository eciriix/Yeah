local API = {}

local rs = game:GetService("ReplicatedStorage")
local pfservice = game:GetService("PathfindingService")
local debris = game:GetService("Debris")

local processes = {}
local Forbidden = rs.Modules:WaitForChild("Forbidden")
local signals = script:WaitForChild("signals")
local stopAI = signals:WaitForChild("StopAI")
local std = require(Forbidden:WaitForChild("Standard"))

local climbDebounce

type SmartPathfindSettings = {StandardPathfindSettings: {}, Visualize: boolean, Tracking: boolean, SwapMovementMethodDistance: boolean, RetrackTimer: number, SkipToWaypoint: number}

API.Stuck = function(humanoid: Humanoid)
	humanoid:Move(Vector3.new(math.random(-1,1),0,math.random(-1,1)))
	humanoid.Jump = true
end

local function reset(NPC)
	local currentWaypoint = NPC:FindFirstChild("CurrentWaypoint")
	if currentWaypoint == nil then return end
	if currentWaypoint.Value == nil then return end


	if currentWaypoint then
		local waypointPosition = currentWaypoint.Value
		--NPC.Humanoid:MoveTo(waypointPosition)
	else
		warn("Unable to reset AI's position. Current waypoint not found.")
	end
end

API.SmartPathfind = function(NPC: any, Target: any, Yields: boolean, Settings: SmartPathfindSettings): Enum.PathStatus?
	
	if not NPC:FindFirstChild("antilag") then 
		local anti = script.antilag:Clone()
		anti.Parent = NPC
		anti.Enabled = true
	end

	if NPC == nil or Target == nil then return false end

	-- Update settings, with provided settings while keeping non-conflicting defaults.
	local pfSettings = {
		StandardPathfindSettings = { -- these defaults were messed up, smh
			AgentRadius = 2, -- was 3: default 2
			AgentHeight = 5, -- was 6: default 5
			AgentCanJump = true,
			AgentCanClimb = false,
			Cost = {},
		},
		Visualize = false,
		Tracking = false, -- continues till AI:Stop(NPC) or different pathfind is started.
		SwapMovementMethodDistance = 25,
		RetrackTimer = 2/60,
		SkipToWaypoint = 1 -- how many waypoints should it skip (-1)? For tracking this fixes the stutter bugs. Alternatively, you can alter waypoint spacing in StandardPathfindSettings. 
	}

	if Settings then
		for setting, v in pairs(Settings) do
			pfSettings[setting] = v
		end
		
		-- If the AI is tracking, and it the SkipToWaypoint setting was not explicity set, this is a better default
		if not Settings["SkipToWaypoint"] and pfSettings["Tracking"] then
			pfSettings["SkipToWaypoint"] = 3
		end
	end
	

	local i = 0

	local enemyRoot = nil
	local enemyHuman = nil
	local targetRoot = nil

	local function updateBasedOnType(obj,type) -- if you're trying to understand this script collapse this function and IGNORE it.

		i+=1

		local function updateVars(char)

			if i == 1 then -- for tracker


				enemyRoot = char:FindFirstChild("HumanoidRootPart")
				if enemyRoot == nil then error("Could not find HRT. change to waitforchild to bypass") return end
				enemyHuman = char:FindFirstChild("Humanoid")
				if enemyHuman == nil then error("Could not find Humanoid. change to waitforchild to bypass") return end

			end

			if i == 2 then -- for target

				targetRoot = char:FindFirstChild("HumanoidRootPart")
				if targetRoot == nil then error("Could not find HRT. change to waitforchild to bypass") return end
			end
		end

		if (typeof(obj)) == "userdata" then -- checks for Humanoid

			if obj:IsA("Humanoid") then

				updateVars(obj.Parent)
			end
		end

		if type == "Model" then -- checks to see if it is a char

			if i == 1 then

				if obj:FindFirstChild("Humanoid") then

					updateVars(obj)
				end
			end

			if i == 2 then

				targetRoot = obj:GetChildren()[1]
			end
		end

		if type == "Player" then -- checks to see if it is a player

			if obj.Character ~= nil then updateVars(obj.Character) end
			if obj.Character == nil then return "char not found" end -- protects against Players:GetChildren() loop errors
		end

		if type == "Part" then -- finds humanoid from part, if humanoid then send.

			if obj.Parent:FindFirstChild("Humanoid") then

				updateVars(obj.Parent)
			end

			if obj.Parent.Parent:FindFirstChild("Humanoid") then

				updateVars(obj.Parent.Parent)
			end

			if i == 1 then error("Are you sure you passed in the right part for the character, could not find a Humanoid") return end

			if i == 2 then -- for normality

				targetRoot = obj
			end
		end
	end

	if NPC ~= nil then updateBasedOnType(NPC,std.basic.GetType(NPC)) else error("Enemy/Tracker does not exist.") end
	if Target ~= nil then updateBasedOnType(Target,std.basic.GetType(Target)) else return "target not found" end


	local path = pfservice:CreatePath(pfSettings.StandardPathfindSettings)

	--print(waypoints)
	local function losCheck()

		local result = std.math.LineOfSight(NPC, Target, {Range = pfSettings.SwapMovementMethodDistance, SeeThroughTransparentParts = false})
		if result then
			return true
		end

		return false
	end

	-- Destroy any and all waypoint folders inside of the NPC, these should be previous ones so beware of the call.
	local function destroyWP()
		for i, v in pairs(NPC:GetChildren()) do
			if v.Name == "Waypoints" then
				debris:AddItem(v, 0)
			end
		end
	end

	-- Move to the enemy's HRT, should be called whenever the Line of Sight check returns true and the 
	local function moveToHRT()
		enemyHuman:MoveTo(targetRoot.Position)

		if not pfSettings.Tracking then

			enemyHuman.MoveToFinished:Wait()
		end
	end
	
	local function setProcess()

		local thisTime = os.clock()
		processes[NPC] = thisTime -- KEEP THIS IN MIND WHEN TRYING TO PAUSE, you have to pass the char in when pausing
		
		return thisTime
	end
	
	local function pathfind(timeStarted: number)
		
		-- Initial test, is the target in line of sight ?
		if losCheck() and (enemyRoot.Position - targetRoot.Position).Magnitude < pfSettings.SwapMovementMethodDistance then 
			moveToHRT() 
			return 
		end
		
		-- Compute the pathfind and get the waypoints.
		path:ComputeAsync(enemyRoot.Position,targetRoot.Position)
		local waypoints = path:GetWaypoints()
		
		-- Supporting features.
		local VECTOR3VAL_currentWaypoint = NPC:FindFirstChild("CurrentWaypoint")
		
		-- Was path generation a failure ?
		if path.Status == Enum.PathStatus.NoPath then 
			
			local function climbFunction()
				if climbDebounce then return end

				local humanoidRootPart = enemyRoot

				-- First jump
				if not climbDebounce then
					climbDebounce = true
					local firstJump = Instance.new("BodyVelocity")
					firstJump.MaxForce = Vector3.new(4000, 4000, 4000)  
					firstJump.P = 10000  -- Adjust as needed
					firstJump.Parent = humanoidRootPart
					firstJump.Velocity = humanoidRootPart.CFrame.LookVector * 20 + Vector3.new(0, 25, 0) 

					--playClimb = hum:LoadAnimation(climbAnim)
					--playClimb:Play()
					--climbEvent:FireServer(1)
					task.wait(.3) 
					firstJump:Destroy()  
				else
					local firstJump = Instance.new("BodyVelocity")
					firstJump.MaxForce = Vector3.new(4000, 4000, 4000)
					firstJump.P = 10000  
					firstJump.Parent = humanoidRootPart
					firstJump.Velocity = humanoidRootPart.CFrame.LookVector * 20 + Vector3.new(0, 20, 0) 

					--playClimb = hum:LoadAnimation(climbAnim)
					--playClimb:Play()
					--climbEvent:FireServer(1)
					task.wait(.2)  
					firstJump:Destroy()  
				end
			end
			
			enemyHuman.MoveToFinished:Wait()  

			climbFunction()
			
			warn("No path could be found. This is an issue with Roblox, not Forbidden. The NPC might also not be able to fit where the waypoint is, please see 'AgentRadius' ") 
			return Enum.PathStatus.NoPath 
		end -- if no possible path.


		local thisFolder = nil
		if path.Status == Enum.PathStatus.Success then
	
			if VECTOR3VAL_currentWaypoint == nil then VECTOR3VAL_currentWaypoint = Instance.new("Vector3Value", NPC) VECTOR3VAL_currentWaypoint.Name = "CurrentWaypoint" end
	
			-- Concurrent execution for the script to run better.
			local folder = Instance.new("Folder")
			folder.Name = "Waypoints"
			
			spawn(function()

				for i, waypoint in ipairs(waypoints) do

					local part = Instance.new("Part")
					part.Shape = Enum.PartType.Ball
					part.Color = Color3.new(0.384314, 0.341176, 1)
					part.Material = Enum.Material.Neon
					part.CFrame = CFrame.new(waypoint.Position)
					part.Parent = folder
					part.Name = i
					part.Anchored = true
					part.Size = Vector3.new(1,1,1)
					part.CanCollide = false

					if not pfSettings.Visualize then
						part.Transparency = 1
					end
				end
				
				thisFolder = folder

			end)
		else
			API.Stuck(enemyHuman) -- possibility?
		end
		
		spawn(function()
			destroyWP()
			thisFolder.Parent = NPC
		end)
		
		
		-- To stop jitter, and stop the ai from going backwards. TODO:// fix, though this may mess with maps with thin walls...
		--local function determineFirstWaypointInFront()
			
		--	local lastDist = (waypoints[1].Position - enemyRoot.Position).Magnitude
		--	for i=1, 5, 1 do
				
		--		if i == 1 then continue end
				
		--		local dist = (waypoints[i].Position - enemyRoot.Position).Magnitude
		--		if dist > lastDist then return i end
				
		--		lastDist = dist
		--	end
			
		--	print("Woah, how did this print!")
		--	return 1
		--end
		
		-- Iterate through and travel to waypoints.
		--local firstWP = determineFirstWaypointInFront()
		local firstWP = pfSettings.SkipToWaypoint
		local wasPathing = false
		for i, wp in ipairs(waypoints) do
			
			-- Ensure the waypoint still needs to be followed.
			if processes[NPC] > timeStarted then break end -- return to not destroy the other new path.
			
			-- Make sure the AI does not go backwards
			if i < firstWP then continue end
			
			-- Is the AI alive ?
			if enemyHuman.Health <= 0 then break end
			
			-- Jump
			if wp.Action == Enum.PathWaypointAction.Jump then enemyHuman.Jump = true end

			-- Move to position and update value, so cancelling later can be done smoothly
			enemyHuman:MoveTo(wp.Position)
			VECTOR3VAL_currentWaypoint.Value = wp.Position
			
			-- Try to track the now visible player.
			if losCheck() and (enemyRoot.Position - targetRoot.Position).Magnitude < pfSettings.SwapMovementMethodDistance then 
				-- Ensure the waypoint still needs to be followed.
				if processes[NPC] > timeStarted then break end -- return to not destroy the other new path.
				moveToHRT() 
				break 
			end 
			
			-- Handle movement successes
			local moveSuccess = enemyHuman.MoveToFinished:Wait()
			if not moveSuccess and processes[NPC] == timeStarted then -- if not successful in movement and was a result of this thread.
				-- stuck.
				warn("[Forbidden.AI] The AI was not successful in a movement: (" .. NPC.Name .. ")")
				API.Stuck(enemyHuman)
				break
			end
		
		end
	end
	
	-- Track a target.
	local function track()
		
		-- Initial Setup
		local lastTime = setProcess()
		local lastPositionOfTarget = Vector3.new(math.huge, math.huge, math.huge)
		
		-- While the process remains active, chase the targeted object.
		while processes[NPC] == lastTime do
			if Target == nil then processes[NPC] = math.huge break end
			
			-- Has the target moved, if so, recall the pathfind to update the target.
			local targetPositionNow = std.math.Round(targetRoot.Position)
			
			if targetPositionNow ~= lastPositionOfTarget then
				spawn(function() if processes[NPC] > lastTime then processes[NPC] = math.huge return end lastTime = setProcess() pathfind(lastTime) end)
				lastPositionOfTarget = targetPositionNow
			end
			
			task.wait(pfSettings.RetrackTimer)
		end
	end
	
	-- Pathfind to a target, normally.
	local function normalPf()
		pathfind(setProcess())
	end
	
	-- Determines the type of pathfind and handles cleanup.
	local function determiner()
		
		-- Do the pathfind
		destroyWP()
		
		if pfSettings.Tracking then track() return end
		if not pfSettings.Tracking then normalPf() return end
		
	end
	
	
	-- Yield / No yield handler.
	if Yields or Yields == nil then determiner() return end
	if not Yields then spawn(determiner) return end
	
end

local function onStoppage(AI)
	
	-- Destroy any and all waypoint folders inside of the NPC, these should be previous ones so beware of the call.
	local function destroyWP()
		for i, v in pairs(AI:GetChildren()) do
			if v.Name == "Waypoints" then
				debris:AddItem(v, 0)
			end
		end
	end
	
	
	if AI == nil then error("AI passed to AI:Stop() is nil.") return end

	--if processes[AI] ~= math.huge then reset(AI) end
	processes[AI] = math.huge

	destroyWP()
end

API.Stop = function(AI: Model)
	onStoppage(AI)
end

stopAI.Event:Connect(onStoppage)

return API