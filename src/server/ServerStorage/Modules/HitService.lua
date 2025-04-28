local module = {}

-- Services
local debris = game:GetService("Debris")
local RS = game:GetService('ReplicatedStorage')
local ss = game:GetService("ServerStorage")

-- Modules
local modules = ss:WaitForChild("Modules")
local stunHandler = require(modules:WaitForChild("StunHandlerV2"))

-- Settings
local walkspeedDefault = 9
local jumpheightDefault = 4
local walkspeedDuring = 4
local jumpheightDuring = 2

function module.Hit(enemyHumanoid,damage,stunDuration,knockback,ragdoll,ragdollDuration)
	local enemyHumRp = enemyHumanoid.Parent.HumanoidRootPart
	enemyHumanoid.Parent:SetAttribute('isRagdoll', false)
	if damage then
		enemyHumanoid:TakeDamage(damage)
		enemyHumRp.Anchored = false
	end

	if ragdoll then
		task.spawn(function()
			enemyHumanoid.Parent:SetAttribute('isRagdoll', false)
			enemyHumanoid.Parent:SetAttribute('isRagdoll', true)

			task.wait(ragdollDuration)

			enemyHumanoid.Parent:SetAttribute('isRagdoll', false)
			enemyHumanoid.Parent:SetAttribute('iFrames', true)

			if enemyHumanoid.Health > 0 then
				--RS.Events.VFXHandler:FireAllClients(enemyHumRp, 'iFrames', enemyHumRp, .4)
				task.delay(.4, function() enemyHumanoid.Parent:SetAttribute('iFrames', false) end)
			end
		end)
	end


	if stunDuration then
		enemyHumanoid.WalkSpeed = walkspeedDefault
		enemyHumanoid.JumpPower = jumpheightDefault
		stunHandler.Stun(enemyHumanoid,stunDuration)
	end


	if knockback then
		task.spawn(function()
			local mover = Instance.new("BodyVelocity")
			mover.MaxForce = Vector3.new(1, 0, 1) * 14000 
			mover.Velocity = knockback 
			mover.Parent = enemyHumRp  

			debris:AddItem(mover, 0.2)  

			for i = 1, 8 do
				task.wait(0.25) 
				mover.Velocity *= 0.9  
			end
		end)
	end

	--[[
	
	if knockback then
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(math.huge,0,math.huge)
		bv.P = 50000
		bv.Velocity = knockback
		bv.Parent = enemyHumRp

		debris:AddItem(bv,0.2)
	end
	
	]]




	enemyHumanoid.Parent:SetAttribute('isBlocking', false)
	enemyHumanoid.Parent:SetAttribute('Attacking', false)
	enemyHumanoid.Parent:SetAttribute('Swing', false)
	enemyHumanoid.Parent:SetAttribute('Parrying', false)


end

return module