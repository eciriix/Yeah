local RS = game:GetService("RunService")

local player = game.Players.LocalPlayer

local camera = game.Workspace.CurrentCamera

local character = script.Parent

local breathHeight = .1
local breathSpeed = 2

local humanoid = character:WaitForChild("Humanoid")

-- Settings
game.Players.LocalPlayer.CameraMinZoomDistance = 2
game.Players.LocalPlayer.CameraMaxZoomDistance = 20


local function update()
	local now = tick()

	local orbit1 = Vector3.new(math.sin(now), 0, math.cos(now)) * 0.1
	local orbit2 = Vector3.new(math.sin(now * 1), 0, math.sin(now * 0)) * .1
	local height = math.sin(now * math.pi) * 0

	humanoid.CameraOffset = Vector3.new(0, height, 0) + orbit1 + orbit2
end

RS.RenderStepped:Connect(update)

--------------------------------------------

local function wobble()
	local CT = tick()
	if humanoid.MoveDirection.Magnitude > 0 then
		local BobbleX = math.cos(CT*10)*0.55
		local BobbleY = math.abs(math.sin(CT*10))*0.55
		local Bobble = Vector3.new(BobbleX,BobbleY,0)
		humanoid.CameraOffset = humanoid.CameraOffset:lerp(Bobble, 0.25)
	else
		humanoid.CameraOffset = humanoid.CameraOffset * 0.75
	end
end

RS.RenderStepped:Connect(wobble)

--bind camera to head
task.wait(1.5)
local plr = game.Players.LocalPlayer
local char = plr.Character
local hum = char:WaitForChild("Humanoid")
local rootpart,head = char:WaitForChild("HumanoidRootPart"),char:WaitForChild("Head")
game:GetService("RunService"):BindToRenderStep("CameraOffset",Enum.RenderPriority.Camera.Value-1,function()
	game:GetService("TweenService"):Create(hum,TweenInfo.new(0.3),{CameraOffset = (rootpart.CFrame+Vector3.new(0,1.5,0)):pointToObjectSpace(head.CFrame.p)}):Play()
end)
