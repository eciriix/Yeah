-- Services
local TweenService = game:GetService('TweenService')
local SoundService = game:GetService('SoundService')
local SoundFolder = SoundService:WaitForChild('SFX')
local Debris = game:GetService('Debris')

-- Player
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Modules
local InnerDialogueModule = require(game.ReplicatedStorage.Modules.InnerDialogue)
local BindableEvent = game.ReplicatedStorage:WaitForChild('Events').FallDialogue

-- Settings
local lowBloodTrue = false
local dialogueQueue = {}
local isDialoguePlaying = false

local function playSound()
	local dialogueSound = SoundFolder.GUI.Dialogue:WaitForChild(math.random(2) == 1 and 'popup1' or 'popup2'):Clone()
	dialogueSound.Parent = character.HumanoidRootPart
	dialogueSound:Play()
	Debris:AddItem(dialogueSound,2)
end

local function playDialogue(label)
	isDialoguePlaying = true

	player.PlayerGui.InnerDialogue.Enabled = true
	player.PlayerGui.InnerDialogue.Image.Label.Text = label
	player.PlayerGui.InnerDialogue.Image.Label.TextTransparency = 1
	player.PlayerGui.InnerDialogue.Image.Header.TextTransparency = 1
	player.PlayerGui.InnerDialogue.Image.ImageTransparency = 1
	playSound()

	-- Fade-in animation
	for count = 0, 10, 1 do
		player.PlayerGui.InnerDialogue.Image.Label.TextTransparency -= 0.1
		player.PlayerGui.InnerDialogue.Image.Header.TextTransparency -= 0.1
		player.PlayerGui.InnerDialogue.Image.ImageTransparency -= 0.1
		wait(0.1)
	end

	task.wait(5)

	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local fadeLabelTween = TweenService:Create(player.PlayerGui.InnerDialogue.Image.Label, tweenInfo, {TextTransparency = 1})
	local fadeHeaderTween = TweenService:Create(player.PlayerGui.InnerDialogue.Image.Header, tweenInfo, {TextTransparency = 1})
	local fadeImageTween = TweenService:Create(player.PlayerGui.InnerDialogue.Image, tweenInfo, {ImageTransparency = 1})

	fadeLabelTween:Play()
	fadeHeaderTween:Play()
	fadeImageTween:Play()

	fadeImageTween.Completed:Connect(function()
		isDialoguePlaying = false
		if #dialogueQueue > 0 then
			playDialogue(table.remove(dialogueQueue, 1))
		end
	end)
end

local function queueDialogue(dialogueName)
	local InnerDialogueInfo = InnerDialogueModule:getDialogue(dialogueName)
	local label = InnerDialogueInfo[math.random(1, #InnerDialogueInfo)]

	if isDialoguePlaying then
		table.insert(dialogueQueue, label)
	else
		playDialogue(label)
		isDialoguePlaying = true
	end
end

BindableEvent.Event:Connect(function()
	queueDialogue('Fell')
end)

humanoid.HealthChanged:Connect(function(health)
	
	local healthPercent = humanoid.Health/humanoid.MaxHealth * 100
	
	if healthPercent <= 30 and not lowBloodTrue then
		lowBloodTrue = true
		queueDialogue('LowBlood')
	elseif lowBloodTrue and healthPercent > 30 then
		lowBloodTrue = false
		queueDialogue('LowBloodRecovered')
	end
end)
