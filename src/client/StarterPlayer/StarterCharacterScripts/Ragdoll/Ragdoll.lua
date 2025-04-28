task.wait(1)
local Character = script.Parent
repeat
	Character:FindFirstChild("Humanoid")
until Character:FindFirstChild("Humanoid")
local Torso = Character:WaitForChild("Torso")
local Humanoid = Character:FindFirstChildOfClass("Humanoid")

--> Necessary for Ragdolling to function properly
Character.Humanoid.BreakJointsOnDeath = false
Character.Humanoid.RequiresNeck = false

--> Specific CFrame's I made for the best looking Ragdoll
local attachmentCFrames = {
	["Neck"] = {CFrame.new(0, 1, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1), CFrame.new(0, -0.5, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1)},
	["Left Shoulder"] = {CFrame.new(-1.3, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1), CFrame.new(0.2, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1)},
	["Right Shoulder"] = {CFrame.new(1.3, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), CFrame.new(-0.2, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
	["Left Hip"] = {CFrame.new(-0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)},
	["Right Hip"] = {CFrame.new(0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)},
}

local ragdollInstanceNames = {
	["RagdollAttachment"] = true,
	["RagdollConstraint"] = true,
	["ColliderPart"] = true,
}

-------------------------------------------------------------------------------------------------

--> Allows for proper limb collisions
local function createColliderPart(part: BasePart)
	if not part then return end
	local rp = Instance.new("Part")
	rp.Name = "ColliderPart"
	rp.Size = part.Size/1.7
	rp.Massless = true			
	rp.CFrame = part.CFrame
	rp.Transparency = 1
	
	local wc = Instance.new("WeldConstraint")
	wc.Part0 = rp
	wc.Part1 = part
	
	wc.Parent = rp
	rp.Parent = part
end

--> Converts Motor6D's into BallSocketConstraints
function replaceJoints()
	Humanoid.AutoRotate = false 
	for _, motor in pairs(Character:GetDescendants()) do
		if motor:IsA("Motor6D") then
			if not attachmentCFrames[motor.Name] then return end
			motor.Enabled = false;
			local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
			a0.CFrame = attachmentCFrames[motor.Name][1]
			a1.CFrame = attachmentCFrames[motor.Name][2]

			a0.Name = "RagdollAttachment"
			a1.Name = "RagdollAttachment"

			createColliderPart(motor.Part1)
			
			local impactH = script.ImpactSound:Clone()
			impactH.Parent = Character:WaitForChild("Head")
			impactH.Disabled = false
			local impactLA = script.ImpactSound:Clone()
			impactLA.Parent = Character:WaitForChild("Left Arm")
			impactLA.Disabled = false
			local impactRA = script.ImpactSound:Clone()
			impactRA.Parent = Character:WaitForChild("Right Arm")
			impactRA.Disabled = false

			local b = Instance.new("BallSocketConstraint")
			b.Attachment0 = a0
			b.Attachment1 = a1
			b.Name = "RagdollConstraint"

			b.Radius = 0.15
			b.LimitsEnabled = true
			b.TwistLimitsEnabled = false
			b.MaxFrictionTorque = 0
			b.Restitution = 0
			b.UpperAngle = 90
			b.TwistLowerAngle = -45
			b.TwistUpperAngle = 45

			if motor.Name == "Neck" then
				b.TwistLimitsEnabled = true
				b.UpperAngle = 45
				b.TwistLowerAngle = -70
				b.TwistUpperAngle = 70
			end
			
			a0.Parent = motor.Part0
			a1.Parent = motor.Part1
			b.Parent = motor.Parent
		end
	end
end

--> Destroys all Ragdoll made instances and re-enables the Motor6D's
function resetJoints()
	Character:SetAttribute("IsRagdoll", false)
	Humanoid.AutoRotate = true
	
	if Humanoid.Health < 1 then return end
	for _, instance in pairs(Character:GetDescendants()) do
		if ragdollInstanceNames[instance.Name] then
			instance:Destroy()
		end
		
		for i,v in pairs(Character:GetDescendants()) do
			if v:IsA("Script") and v.Name == "ImpactSound" and v.Enabled == true then
				v:Destroy()
			end
		end

		if instance:IsA("Motor6D") then
			instance.Enabled = true;
		end
	end
	
end

local function push(T)
	T:ApplyImpulse(T.CFrame.LookVector * 100)
end

function Ragdoll()
	local isRagdoll = not Character:GetAttribute("IsRagdoll")
	Character:SetAttribute("IsRagdoll", isRagdoll)
end

-- Connect the event
Character:GetAttributeChangedSignal("IsRagdoll"):Connect(function()
	local isRagdoll = Character:GetAttribute("IsRagdoll")
	if isRagdoll then
		replaceJoints()
	else
		resetJoints()
	end
end)

Humanoid.Died:Once(function() --> The only non perfect part about this is the oof sound plays twice for some reason
	Character:SetAttribute("IsRagdoll", true)
	local plr = game:GetService("Players"):GetPlayerFromCharacter(Character)
	plr.RageValues.Ultimate.Value = false
end)