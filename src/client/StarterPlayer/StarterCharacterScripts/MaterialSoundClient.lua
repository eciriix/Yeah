local MaterialSounds = {
	[Enum.Material.Ground] = "rbxassetid://336575135",
	[Enum.Material.Brick] = "rbxassetid://4416041299",
	[Enum.Material.Plastic] = "rbxassetid://4416041299",
	--[Enum.Material.Grass] = "rbxassetid://507863105",
	--[Enum.Material.Grass] = "rbxassetid://344063420",
	[Enum.Material.Grass] = "rbxassetid://9064714296",
	[Enum.Material.Concrete] = "rbxassetid://0",
	[Enum.Material.Wood] = "rbxassetid://8454543187",
	[Enum.Material.Asphalt] = "rbxassetid://4416041299",
	[Enum.Material.Pavement] = "rbxassetid://6362185620",
}

local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local FootstepsSound = HumanoidRootPart:WaitForChild("Running")

function updateFootstepsSound()
	local FloorMaterial = Humanoid.FloorMaterial
	local Sound = MaterialSounds[FloorMaterial]
	if Sound then
		FootstepsSound.SoundId = Sound
		FootstepsSound.Volume = 3
		-- Adjust the pitch
		if FloorMaterial == Enum.Material.Grass then
			FootstepsSound.PlaybackSpeed = 0.8 
			FootstepsSound.Volume = 0.8
		elseif FloorMaterial == Enum.Material.Wood then
			FootstepsSound.PlaybackSpeed = 1.1 
		elseif FloorMaterial == Enum.Material.Pebble then
			FootstepsSound.PlaybackSpeed = 1.1 
		elseif FloorMaterial == Enum.Material.Ground then
			FootstepsSound.PlaybackSpeed = 1.3 
		elseif FloorMaterial == Enum.Material.Pavement then
			FootstepsSound.PlaybackSpeed = 1.1 
			FootstepsSound.Volume = 2
		else
			FootstepsSound.PlaybackSpeed = 1
		end
	else
		FootstepsSound.SoundId = "" -- No walk sound cus in air
	end
	if Humanoid.WalkSpeed > 9 then
		FootstepsSound.PlaybackSpeed = FootstepsSound.PlaybackSpeed * 2
	elseif Humanoid.WalkSpeed > 21 then
		FootstepsSound.PlaybackSpeed = FootstepsSound.PlaybackSpeed * 5
	else
		FootstepsSound.PlaybackSpeed = FootstepsSound.PlaybackSpeed
	end
end

Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(updateFootstepsSound)

while true do
	task.wait(0.05)
	updateFootstepsSound()
end
