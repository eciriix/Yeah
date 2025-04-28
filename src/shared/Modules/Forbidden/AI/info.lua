--[[

OVERVIEW:

	Simple pathfinding module, not the best code I've ever made but it works for its purpose.
		
		The module can track, yield the thread, and you can stop it very easily.


Troubleshooting:

	Most of the time any issues that arise will be with Forbidden. But there are cases where common issues and misunderstandings 
	arise
	
		1. Make sure the target doesn't disappear (this actually happens alot, bc unanchored or other reasons)
		2. Make sure the terrain is actually passable.
		3. Terrain is a big issue with Roblox's pathfinding system so keep that in mind.
		4. Any lag that appears when the NPC goes close to a player is caused by the parts not doing "part:SetNetworkOwner(nil)" 
		The antilag included is not the best fix to this issue, just my attempt to mitigate this issue as much as possible for
		new developers.
		
		5. Forbidden DOES NOT support trusses.
		
		
		Any questions or issues please DM crit#0271 on discord.
	
Functions:

	1. API.SmartPathfind(NPC: Model, Target: Part or Model, Yields: Boolean, Settings: Table)
	
		NPC - The NPC you want to move. Can be R6, R15. Newer models untested but should work.
		
		Target - A part or model that you want it to pathfind to. Will support positional data in the future.
		
		Yields - Whether the script the function was called from will yield until the AI reaches its destination
		
		Settings -
			{
				StandardPathfindSettings = { -- The normal pfsettings included at 'https://create.roblox.com/docs/mechanics/pathfinding'
					AgentRadius = 3,
					AgentHeight = 6,
					AgentCanJump = true,
					AgentCanClimb = true,
					Cost = {
					
						-- ex. Water = math.huge -- the higher the value the more it will avoid it.
					}
				}, 				
				Visualize = false, 		-- Visualize the pathfind
				Tracking = false, 		-- continues till AI:Stop(NPC) or different pathfind is started.
				SwapMovementMethodDistance = 10, -- in studs, swaps the movement method to direct tracking if the player is in LineOfSight at x distance.
			}

	2. API.Stop(NPC: Model)
	
		Halts the specified model if it is pathfinding. could take a bit to stop depending on pf state.
		
	3. API.Stuck(NPC: Model)
	
		Unbugs the NPC

]]--