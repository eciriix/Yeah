local RS = game:GetService('ReplicatedStorage')
local Debris = game:GetService('Debris')

local plr = game:GetService('Players').LocalPlayer

RS:WaitForChild('Events'):WaitForChild('VFX').OnClientEvent:Connect(function(action,...)
	
	if action == 'Fireball' then
		local part = ...

		local FireballEffect = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('FIREBALLPART').Attachment:Clone()
		FireballEffect.Parent = part
		FireballEffect.Name = 'Fire'
		
		Debris:AddItem(FireballEffect, 3)
		task.spawn(function()
			task.wait(1)
			for i, v in pairs(FireballEffect:GetDescendants()) do
				v.Enabled = false
			end
		end)

	end
	
	if action == 'FireballExplode' then
		local part = ...
		
		local fire = part:FindFirstChild('Fire')
		for i, v in pairs(fire:GetDescendants()) do
			v.Enabled = false
		end
		
		local FireballEffect = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('FIREBALLEXPLODEPART').Attachment:Clone()
		FireballEffect.Parent = part
		FireballEffect.Name = 'Explode'
		
		local SoundEffect = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('FIREBALLEXPLODEPART').Explode:Clone()
		SoundEffect.Parent = part
		SoundEffect:Play()
		
		Debris:AddItem(FireballEffect, 3)

		for i, v in pairs(FireballEffect:GetDescendants()) do
			v:Emit(v:GetAttribute('EmitCount'))
		end

	end
	
	
	if action == 'Blood' then
		local enemy, hit = ...
		
		if hit ~= 4 then enemy.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
		
		local BloodEffect = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('BLOODPART').Attachment:Clone()
		BloodEffect.Parent = enemy:WaitForChild('Torso')
		Debris:AddItem(BloodEffect, 5)
		
		for i, v in pairs(BloodEffect:GetDescendants()) do
			v:Emit(v:GetAttribute('EmitCount'))
		end
	end
	
	if action == 'HighlightGrey' then
		local character, highlightTime = ...
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.8
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.OutlineTransparency = 0.8
		highlight.DepthMode = 'Occluded' 
		highlight.Parent = character

		task.delay(highlightTime, function()
			highlight:Destroy()
		end)
	end

	if action == 'HighlightYellow' then
		local character = ...
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255, 255, 0) 
		highlight.FillTransparency = 0.8 
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.OutlineTransparency = 0.8
		highlight.DepthMode = 'Occluded' 
		highlight.Parent = character

		task.delay(1.9, function()
			highlight:Destroy()
		end)
	end
	
	if action == 'Climb' then
		local enemy= ...

		local ClimbEffect = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('CLIMBPART').Attachment:Clone()
		ClimbEffect.Parent = enemy:WaitForChild('Head')
		Debris:AddItem(ClimbEffect, 1)

		for i, v in pairs(ClimbEffect:GetDescendants()) do
			v:Emit(v:GetAttribute('EmitCount'))
		end
	end
	
	if action == 'Dashing' then
		local enemy, trailTime = ...
		
		local function createAttachmentIfNotExists(parent, name, position)
			local attachment = parent:FindFirstChild(name)
			if not attachment then
				attachment = Instance.new("Attachment")
				attachment.Name = name
				attachment.Position = position
				attachment.Parent = parent
			end
			return attachment
		end

		local function fadeOutAndDestroy(trail, duration)
			coroutine.wrap(function()
				local step = 0.1 
				local transparencyIncrement = step / duration
				local currentTime = 0

				while currentTime < duration do
					trail.Transparency = NumberSequence.new(currentTime / duration)
					currentTime = currentTime + step
					wait(step)
				end

				trail.Transparency = NumberSequence.new(1)
				trail:Destroy()
			end)()
		end

		local character = enemy
		local leftArm = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")
		local rightArm = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
		local leftLeg = character:FindFirstChild("LeftFoot") or character:FindFirstChild("Left Leg")
		local rightLeg = character:FindFirstChild("RightFoot") or character:FindFirstChild("Right Leg")

		if leftArm and rightArm and leftLeg and rightLeg then
			local TrailTemplate = RS:WaitForChild('Effects'):WaitForChild('RUNNINGTRAIL')

			-- Create the trail effect for left arm
			local leftArmTrail = TrailTemplate:Clone()
			local leftArmAttachment0 = createAttachmentIfNotExists(leftArm, "TrailAttachment0", Vector3.new(0, -leftArm.Size.Y / 2, 0))
			local leftArmAttachment1 = createAttachmentIfNotExists(leftArm, "TrailAttachment1", Vector3.new(0, -leftArm.Size.Y / 3, 0))

			leftArmTrail.Attachment0 = leftArmAttachment0
			leftArmTrail.Attachment1 = leftArmAttachment1
			leftArmTrail.Parent = leftArm

			-- Create the trail effect for right arm
			local rightArmTrail = TrailTemplate:Clone()
			local rightArmAttachment0 = createAttachmentIfNotExists(rightArm, "TrailAttachment0", Vector3.new(0, -rightArm.Size.Y / 2, 0))
			local rightArmAttachment1 = createAttachmentIfNotExists(rightArm, "TrailAttachment1", Vector3.new(0, -rightArm.Size.Y / 3, 0))

			rightArmTrail.Attachment0 = rightArmAttachment0
			rightArmTrail.Attachment1 = rightArmAttachment1
			rightArmTrail.Parent = rightArm

			-- Create the trail effect for left leg
			local leftLegTrail = TrailTemplate:Clone()
			local leftLegAttachment0 = createAttachmentIfNotExists(leftLeg, "TrailAttachment0", Vector3.new(0, -leftLeg.Size.Y / 2, 0))
			local leftLegAttachment1 = createAttachmentIfNotExists(leftLeg, "TrailAttachment1", Vector3.new(0, -leftLeg.Size.Y / 3, 0))

			leftLegTrail.Attachment0 = leftLegAttachment0
			leftLegTrail.Attachment1 = leftLegAttachment1
			leftLegTrail.Parent = leftLeg

			-- Create the trail effect for right leg
			local rightLegTrail = TrailTemplate:Clone()
			local rightLegAttachment0 = createAttachmentIfNotExists(rightLeg, "TrailAttachment0", Vector3.new(0, -rightLeg.Size.Y / 2, 0))
			local rightLegAttachment1 = createAttachmentIfNotExists(rightLeg, "TrailAttachment1", Vector3.new(0, -rightLeg.Size.Y / 3, 0))

			rightLegTrail.Attachment0 = rightLegAttachment0
			rightLegTrail.Attachment1 = rightLegAttachment1
			rightLegTrail.Parent = rightLeg

			-- Fade out and destroy the trails
			fadeOutAndDestroy(leftArmTrail, trailTime)
			fadeOutAndDestroy(rightArmTrail, trailTime)
			fadeOutAndDestroy(leftLegTrail, trailTime)
			fadeOutAndDestroy(rightLegTrail, trailTime)
		end
	end

	if action == 'FallSmoke' then
		local enemy= ...

		local SmokeEffect = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('FALLSMOKEPART').Attachment:Clone()
		SmokeEffect.Parent = enemy:WaitForChild('Left Leg')
		Debris:AddItem(SmokeEffect, 6)

		for i, v in pairs(SmokeEffect:GetDescendants()) do
			v:Emit(v:GetAttribute('EmitCount'))
		end
		
		local SmokeEffect2 = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('FALLSMOKEPART').Attachment:Clone()
		SmokeEffect2.Parent = enemy:WaitForChild('Right Leg')
		Debris:AddItem(SmokeEffect2, 6)

		for i, v in pairs(SmokeEffect2:GetDescendants()) do
			v:Emit(v:GetAttribute('EmitCount'))
		end
	end
	
	if action == 'WhirlwindSmoke' then
		local enemy= ...

		local SmokeEffect = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('WHIRLWINDSMOKEPART').Attachment:Clone()
		SmokeEffect.Parent = enemy:WaitForChild('Left Leg')
		Debris:AddItem(SmokeEffect, 6)

		for i, v in pairs(SmokeEffect:GetDescendants()) do
			v:Emit(v:GetAttribute('EmitCount'))
		end

		local SmokeEffect2 = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('WHIRLWINDSMOKEPART').Attachment:Clone()
		SmokeEffect2.Parent = enemy:WaitForChild('Right Leg')
		Debris:AddItem(SmokeEffect2, 6)

		for i, v in pairs(SmokeEffect2:GetDescendants()) do
			v:Emit(v:GetAttribute('EmitCount'))
		end
	end
	
	if action == 'SlowStunned' then
		local enemy = ...

		local SlowStunnedEffect = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('SLOWSTUNNEDPART').Attachment:Clone()
		SlowStunnedEffect.Parent = enemy:WaitForChild('Head')
		Debris:AddItem(SlowStunnedEffect, 3)

		for i, v in pairs(SlowStunnedEffect:GetDescendants()) do
			
			local emitCount = v:GetAttribute('EmitCount')
			local emitDelay = v:GetAttribute('EmitDelay')

			if emitCount and emitDelay then
				coroutine.wrap(function()
					wait(emitDelay)
					v:Emit(emitCount)
				end)()
			elseif emitCount then
				v:Emit(emitCount)
			end
		end
	end
	
	if action == 'RunningHit' then
		local enemy, hit = ...

		local RunningHitEffect = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('RUNNINGHITPART').Attachment:Clone()
		RunningHitEffect.Parent = enemy:WaitForChild('Right Arm')
		Debris:AddItem(RunningHitEffect, 0.1)

		for i, v in pairs(RunningHitEffect:GetDescendants()) do
			v:Emit(v:GetAttribute('EmitCount'))
		end
	end
	
	if action == 'Critical' then
		local enemy, hit = ...

		local CriticalEffect = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('CRITICALPART').Attachment:Clone()
		CriticalEffect.Parent = enemy:FindFirstChildOfClass("Tool").Sword
		Debris:AddItem(CriticalEffect, 2)

		for i, v in pairs(CriticalEffect:GetDescendants()) do
			v:Emit(v:GetAttribute('EmitCount'))
		end
	end
	
	if action == 'BlockingHit' then
		local enemy = ...

		local BlockEffect = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('BLOCKPART').Attachment:Clone()
		BlockEffect.Parent = enemy:FindFirstChildOfClass("Tool").Sword
		Debris:AddItem(BlockEffect, 4)

		for i, v in pairs(BlockEffect:GetDescendants()) do
			v:Emit(v:GetAttribute('EmitCount'))
		end
	end
	
	if action == 'ParryHit' then
		local enemy = ...

		local ParryEffect = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('PARRYPART').Attachment:Clone()
		ParryEffect.Parent = enemy:FindFirstChildOfClass("Tool").Sword 
		Debris:AddItem(ParryEffect, 4)

		for i, v in pairs(ParryEffect:GetDescendants()) do
			v:Emit(v:GetAttribute('EmitCount'))
		end
	end
	
	if action == 'Guardbreak' then
		local enemy = ...

		local GuardbreakEffect = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('GUARDBREAKPART').Attachment:Clone()
		GuardbreakEffect.Parent = enemy:WaitForChild('Torso')
		Debris:AddItem(GuardbreakEffect, 4)

		for i, v in pairs(GuardbreakEffect:GetDescendants()) do
			v:Emit(v:GetAttribute('EmitCount'))
		end
	end
	
	if action == 'Whirlwind' then
		local char = ...

		local WhirlwindEffect = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('WHIRLWINDPART').Attachment:Clone()
		WhirlwindEffect.Parent = char:WaitForChild('HumanoidRootPart')
		Debris:AddItem(WhirlwindEffect, 3)

		for i, v in pairs(WhirlwindEffect:GetDescendants()) do

			local emitCount = v:GetAttribute('EmitCount')
			local emitDelay = v:GetAttribute('EmitDelay')

			if emitCount and emitDelay then
				coroutine.wrap(function()
					wait(emitDelay)
					v:Emit(emitCount)
				end)()
			elseif emitCount then
				v:Emit(emitCount)
			end
		end
	end
	
	if action == 'Crack' then
		local person = ...

		local CrackEffect = game:GetService('ReplicatedStorage'):WaitForChild('Effects'):WaitForChild('CRACKPART').Attachment:Clone()
		CrackEffect.Parent = person:WaitForChild('HumanoidRootPart')
		Debris:AddItem(CrackEffect, 12)
		CrackEffect.Position = CrackEffect.Position + Vector3.new(0, -2.46, 0) -- Move 2 studs lower (adjust as needed)
		for i, v in pairs(CrackEffect:GetDescendants()) do
			v:Emit(v:GetAttribute('EmitCount'))
		end
	end
end)
