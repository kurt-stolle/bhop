didJump=true
function BHOP:OnContextMenuOpen()
	if LocalPlayer():GetDifficulty().name ~= "Easy" and tostring(ply:ESGetRank()) ~= "owner" then hook.Remove("Think","BHDoAutoBhop"); chat.AddText("Autohop can only be used in Easy mode.") return end

	hook.Add("Think","BHDoAutoBhop",function()
		if LocalPlayer():GetDifficulty().name ~= "Easy" and tostring(ply:ESGetRank()) ~= "owner" then
			hook.Remove("Think","BHDoAutoBhop");
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
end
