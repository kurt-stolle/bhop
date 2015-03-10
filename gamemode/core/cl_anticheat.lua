local CheatBinds = {
		"+bhop",
		"+bunnyhop",
		"+hop",
		"+bunny",
		"+script",
}

hook.Add("PlayerBindPress", "BHOP.ACDetectBinds", function( ply, bind, press )
  if string.match(string.lower(bind), "jump [%d]") then
    net.Start("BHOP.ACDetect")
    net.SendToServer()
		return true
	elseif table.HasValue(CheatBinds, string.lower(bind)) then
    net.Start("BHOP.ACDetect")
    net.SendToServer()
		return true
	end
end)

local count = 0
hook.Add("Think", "BHOP.ACNoBindCheats", function()
	if input.IsKeyDown(KEY_SPACE) then
		count = count + 1
	else
		count = 0
	end
	if count >= 100 and LocalPlayer():GetVelocity():Length2D() > 300 and ply:Alive() then
		net.Start("BHOP.ACDetect")
    net.SendToServer()
	end
end)
