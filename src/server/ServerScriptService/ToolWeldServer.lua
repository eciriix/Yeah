-- Services
local PS = game:GetService('Players')
local SS = game:GetService('ServerStorage')


local referenceDummies = {
	MSword = SS.ReferenceWelds:WaitForChild('MSwordReferenceDummy'),
	HSword = SS.ReferenceWelds:WaitForChild('HSwordReferenceDummy')
}

local function weld(partA : BasePart, partB : BasePart, offsetCFrame : CFrame)

	partA.CFrame = partB.CFrame * offsetCFrame

	local weldConstraint = Instance.new('WeldConstraint')

	weldConstraint.Part0 = partA

	weldConstraint.Part1 = partB

	weldConstraint.Parent = partA

end

local function getReferenceDummy(toolName: string): Model
	return referenceDummies[toolName]
end

local function invis(newWeld)
	print()
end

local function onCharacterAdded(character : Model)
	local player = PS:GetPlayerFromCharacter(character)
	if not player then return end

	local tool = player.Backpack:FindFirstChildOfClass('Tool') or player.Character:FindFirstChildOfClass('Tool')

	if tool then
		local referenceDummy = getReferenceDummy(tool.Name)
		if referenceDummy then
			for _, part in ipairs(referenceDummy:GetDescendants()) do
				if part:IsA("BasePart") and part:FindFirstChild("WeldPart") then
					local newPart = part:Clone()
					local weldPartName = part.WeldPart.Value.Name
					local weldPart = character:WaitForChild(weldPartName)
					weld(newPart, weldPart, part.WeldPart.Value.CFrame:Inverse() * part.CFrame)
					newPart.Parent = character
					
					tool.AncestryChanged:Connect(function()
						if tool:IsDescendantOf(player.Character) then
							newPart.Transparency = 1
						else
							newPart.Transparency = 0
						end
					end)
				end
			end
		end
	end
end

PS.PlayerAdded:Connect(function(player : Player)

	player.CharacterAdded:Connect(onCharacterAdded)

end)

for i, player in pairs (PS:GetPlayers()) do

	player.CharacterAdded:Connect(onCharacterAdded)

	if (player.Character) then

		onCharacterAdded(player.Character)

	end
end