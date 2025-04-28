local module = {}

-- # Settings
module.enemy_char 		= script.Parent.Parent
module.enemy_hrt 		= module.enemy_char:WaitForChild("HumanoidRootPart")
module.enemy_human 		= module.enemy_char:WaitForChild("Humanoid")

module.AI_Init_Time 				= 3 		-- In order to prevent errors, this is recommended.
module.seeThroughTransparent 		= true		-- Whether or not the AI can see through transparent parts
module.isActive 					= true		-- Dictates whether the AI is activated.
module.AntiLag 						= true		-- Dictates whether the AI is activated.
module.PreventAIFromSitting			= true
module.hitboxes						= {}		-- As default, HumanoidRootPart is used (recommended to not do GetChildren() on AI).
module.damageDelay 					= 1			-- In seconds, how long until the AI can damage again (or move if setting below is enabled)
module.disable_ai_while_damaging 	= false
module.damageDone 					= 100
module.chaseSpeed					= 20
module.NotInSightDoSprint			= true		-- if the player is not in sight, yet the AI is pathing to a location where it last saw it, should it sprint?
module.detectionRange				= 1000
module.detectionFOV					= 70		-- In degrees, the detection FOV of the AI. LIMIT: 180 for full 360 degrees.
module.detectionBubble				= 5			-- In studs, if the AI should autodetect a player, regardless of angle, within a range. will be fixed asap
module.doWander 					= true		-- Whether or not the AI will use the wander function when not chasing.
	module.doRandomWander				= false		-- If true, calls "getRandomLocationInMap", otherwise, calls "getRandomNode" for a part to go to.
	module.nodes_table					= {}		-- If using random wander, give all valid floors. If not, give manually made nodes. (any models use primary part, if not, they are tossed)
	module.wanderSpeed					= 16
	module.debug_rand_pos 				= false 	-- If using the random wander function
module.ALLT							= 0.1		-- an offset for how long the AI must wait to wander, the wander does not retrigger faster than the chase check.

module.standardPathfindSettings 	= {}		-- should your AI get stuck on corners, tweak these as followed in https://create.roblox.com/docs/characters/pathfinding (Agent-Radius, etc..).

--[[ Example
module.standardPathfindSettings 	= {			-- optimized for default dummies.
	AgentRadius = 2.25, 	-- default 2
	AgentHeight = 5.5, 		-- default 5
	AgentCanJump = true,	-- default true
	AgentCanClimb = false,	-- default false
	Cost = {}				-- default {}
}		-- should your AI get stuck on corners, tweak these as followed in https://create.roblox.com/docs/characters/pathfinding (Agent-Radius, etc..).

]]

return module