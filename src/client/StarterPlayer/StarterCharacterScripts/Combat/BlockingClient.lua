-- Services
local RS           = game:GetService("ReplicatedStorage")
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Debris       = game:GetService("Debris")

-- Player & Character
local plr  = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum  = char:WaitForChild("Humanoid")
plr.CharacterAdded:Connect(function(c)
	char = c
	hum  = c:WaitForChild("Humanoid")
end)

-- Remotes
local eventsFolder     = RS:WaitForChild("Events")
local blockingObj      = eventsFolder:WaitForChild("Blocking")
local parryWindowEvent = eventsFolder:FindFirstChild("ParryWindow")
if not parryWindowEvent then
	warn("[Combat] Pas de RemoteEvent 'ParryWindow' trouvé — buffer désactivé.")
end

local function sendBlockingEvent(action)
	if blockingObj.FireServer then
		blockingObj:FireServer(action)
	elseif blockingObj.InvokeServer then
		blockingObj:InvokeServer(action)
	else
		warn("⚠️ Blocking n'est ni RemoteEvent ni RemoteFunction !")
	end
end

-- GUI
local statsUI = plr.PlayerGui:WaitForChild("StatsGui")

-- Modules
local AnimationModule = require(eventsFolder.Parent.Modules.Animations)

-- Sound setup
local function playBlockSound(toolName)
	local ok, sound = pcall(function()
		return SoundService.SFX.Tools[toolName].parryswing
	end)
	if ok and sound then
		local clone = sound:Clone()
		clone.Parent = char.HumanoidRootPart
		clone:Play()
		Debris:AddItem(clone, 1)
	end
end

-- Anti-spam & state
local debounce         = false
local blockCooldown    = 0.2
local inputHeld        = false
local blockBuffered    = false

-- Utility check: refuse block if attacking or using ability/move
local function canBlock()
	if char:GetAttribute("Attacking")
		or char:GetAttribute("UsingMove")
		or char:GetAttribute("UsingAbility") then
		return false
	end
	return true
end

-- START blocking/parry
local function startBlocking()
	if not canBlock() or debounce or char:GetAttribute("Stunned") then
		return
	end
	debounce = true
	sendBlockingEvent("Start")

	local ok, track = pcall(function() return AnimationModule.Blocking(char) end)
	if ok and typeof(track) == "Instance" and track:IsA("AnimationTrack") then
		track:Play()
		track:GetMarkerReachedSignal("Start"):Once(function()
			if not inputHeld then
				local tool = char:FindFirstChildWhichIsA("Tool")
				if tool then playBlockSound(tool.Name) end
			end
		end)
	else
		if not inputHeld then
			local tool = char:FindFirstChildWhichIsA("Tool")
			if tool then playBlockSound(tool.Name) end
		end
	end

	task.delay(blockCooldown, function()
		debounce = false
	end)
end

-- STOP blocking/parry
local function stopBlocking()
	sendBlockingEvent("Stop")
	pcall(AnimationModule.Unblocking, char)
end

-- Buffer: parry window (server-side trigger)
if parryWindowEvent then
	parryWindowEvent.OnClientEvent:Connect(function()
		if inputHeld and not char:GetAttribute("Stunned") and canBlock() then
			startBlocking()
		end
	end)
end

-- Polling: update inputHeld & handle buffered block
RunService.RenderStepped:Connect(function()
	if char.Parent and hum and hum.Health > 0 then
		inputHeld = UIS:IsKeyDown(Enum.KeyCode.F)
		-- si on a bufferisé et qu'on peut maintenant bloquer, on lance la parade
		if blockBuffered and canBlock() and not char:GetAttribute("Stunned") then
			blockBuffered = false
			startBlocking()
		end
	end
end)

-- Quick start if tap
UIS.InputBegan:Connect(function(input, gp)
	if gp or input.KeyCode ~= Enum.KeyCode.F then
		return
	end
	-- si bloc possible, on bloque ; sinon, on bufferise
	if canBlock() then
		startBlocking()
	else
		blockBuffered = true
	end
end)

-- Release
UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		stopBlocking()
	end
end)

-- If stun ends while holding F, trigger parry
char:GetAttributeChangedSignal("Stunned"):Connect(function(stunned)
	if not stunned and inputHeld and canBlock() then
		task.defer(startBlocking)
	end
end)

-- Auto-stop on tool drop or stun
char.ChildRemoved:Connect(function(child)
	if child:IsA("Tool") and char:GetAttribute("isBlocking") then
		stopBlocking()
	end
end)
RunService.Heartbeat:Connect(function()
	if char:GetAttribute("Stunned") and char:GetAttribute("isBlocking") then
		stopBlocking()
	end
end)

-- Posture UI update
char:GetAttributeChangedSignal("Posture"):Connect(function()
	local p = char:GetAttribute("Posture") or 0
	statsUI.CombatStats.Posture.Slider:TweenSize(
		UDim2.new(p/100*0.615, 0, 0.7, 0),
		Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.3
	)
end)
