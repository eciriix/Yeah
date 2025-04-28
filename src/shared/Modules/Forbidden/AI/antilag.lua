-- forces server to run the AI physics sim preventing rubberbanding when transferring from server->client rendering


for i, part in pairs(script.Parent:GetChildren()) do
	
	if part:IsA("BasePart") then
		
		local s, e = pcall(function() part:SetNetworkOwner(nil) end)
		
		if e then return end
	end
end


script:Destroy()