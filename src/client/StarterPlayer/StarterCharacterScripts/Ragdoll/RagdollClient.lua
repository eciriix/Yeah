local Character: Model = script.Parent.Parent
local Torso = Character:WaitForChild("Torso")
local Humanoid = Character:WaitForChild("Humanoid")

Character:GetAttributeChangedSignal("IsRagdoll"):Connect(function()
	local isRagdoll = Character:GetAttribute("IsRagdoll")
	if isRagdoll then
		Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		-- Apply any desired impulse when the character ragdolls
		Torso:ApplyImpulse(Torso.CFrame.LookVector * 75)
	else
		-- Change character state to GettingUp when unragdolled
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)

Humanoid.Died:Connect(function()
	Torso:ApplyImpulse(Torso.CFrame.LookVector * 100)
end)