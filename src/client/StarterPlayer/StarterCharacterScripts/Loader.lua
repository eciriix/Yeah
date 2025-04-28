-- Player
local Players = game:GetService("Players")
local hum = script.Parent:WaitForChild('Humanoid')

-- Services
local RS = game:GetService('ReplicatedStorage')
local CP = game:GetService('ContentProvider')

task.wait(3)

-- load mouse icon (POSSIBLE LAG)
--local mouse = Players.LocalPlayer:GetMouse()
--mouse.Icon = "rbxassetid://17538117074"


for _, v in ipairs(RS:WaitForChild('Animations'):GetDescendants()) do 
	
	if v:IsA('Animation') then
		hum.Animator:LoadAnimation(v)
	end

end

CP:PreloadAsync(game:GetDescendants())