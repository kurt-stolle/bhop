didJump=true
function BHOP:OnContextMenuOpen()
	if LocalPlayer():GetDifficulty().name ~= "Easy" then hook.Remove("Think","BHDoAutoBhop"); chat.AddText("Autohop can only be used in Easy mode.") return end

	hook.Add("Think","BHDoAutoBhop",function()
		if LocalPlayer():GetDifficulty().name ~= "Easy" then
			hook.Remove("Think","BHDoAutoBhop");
			if didJump then
				RunConsoleCommand("-jump")
				didJump=false
			end
		elseif LocalPlayer():IsOnGround() and not didJump then
			RunConsoleCommand("+jump")
			didJump=true
		elseif didJump then
			RunConsoleCommand("-jump")
			didJump=false
		end
	end)
end
function BHOP:OnContextMenuClose()
	hook.Remove("Think","BHDoAutoBhop");
	if didJump then
		RunConsoleCommand("-jump")
		didJump=false
	end
end
