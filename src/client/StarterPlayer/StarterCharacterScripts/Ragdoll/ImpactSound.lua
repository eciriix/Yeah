local air = false 
local imp = false

local DripSettings = {
	500, -- Limit: The maximum number of blood drips that can be active at once
	true, -- RandomOffset: Whether to use random positions for the blood drips
	0.5, -- Speed: The speed or velocity at which the blood drips fall
	0.01, -- DripDelay: The delay between emitting blood drips,
	false, -- DripVisibile: Determines if the blood drip is visibile when emitted
	true -- Bouncing: Whether to make the drip bounce sometimes or never
}



script.Parent.Touched:connect(function(h)
	if not h:IsDescendantOf(script.Parent.Parent) and air == true and imp == false and h and h.Transparency<1 then		
		air = false		
		imp = true		
		
		local sou = math.random(1,20)
		
		local s = game.SoundService.SFX.Impact["Impact"..sou]:clone()		
		s.Parent = script.Parent		
		s.Name = "Impact"		
		game.Debris:AddItem(s, 3)	
		s:Play()		
			
	end				
end)

while true do	
	task.wait()	
	local ray = Ray.new(script.Parent.Position,Vector3.new(0,-3,0))
	local h,p = game.Workspace:FindPartOnRay(ray,script.Parent.Parent)
	
	if h then
			
	else
				
		air = true		
		imp = false		
	end
end