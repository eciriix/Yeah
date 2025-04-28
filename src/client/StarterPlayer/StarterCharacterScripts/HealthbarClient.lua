-- Remove ROBLOX health bar
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

local plr = game:GetService('Players').LocalPlayer
local char = plr.Character
local statsUI = plr.PlayerGui:WaitForChild('StatsGui')

repeat wait() until game.Players.LocalPlayer.Character 
repeat wait() until game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")

while wait(0.1) do -- loop
	statsUI.CombatStats.Health.Slider:TweenSize(UDim2.new((char.Humanoid.Health / char.Humanoid.MaxHealth)*0.944,0.03,0.902,0), Enum.EasingDirection.InOut,Enum.EasingStyle.Sine, .05)
end