local function fixvalue(v)
	if string.len(tostring(v)) < 2 then
		return "0"..v;
	end
	return v;
end

net.Receive("bhopSendBest",function()
	local str = net.ReadString();

	local build = "";
	if string.find(str,"%.") then
		local parts = string.Explode(".",str);
		build = fixvalue(math.floor(tonumber(parts[1])/60))..":"..fixvalue(tonumber(parts[1]) - math.floor(tonumber(parts[1])/60)*60)
		build = build..":"..fixvalue(string.Left(parts[2],2));
	else
		build = fixvalue(math.floor(tonumber(str)/60))..":".. fixvalue(tonumber(str) - math.floor(tonumber(str)/60)*60)..":00"
	end
	LocalPlayer().BestTime = build;
	print("received best: "..build)
end)

hook.Add("PlayerBindPress", "BHKeyBinds", function(pl, bind, pressed)
	if bind == "+menu" and pressed then
		RunConsoleCommand("bhop_dropweapon")
		return true
	elseif bind == "gm_showhelp" and pressed then
		RunConsoleCommand("bhop_open_difficulty")
		return true
	elseif bind == "gm_showspare2" and presseds then
		RunConsoleCommand("bhop_requestspawn",LocalPlayer():GetDifficulty().key)
		return true
	end
end)

concommand.Add("bhop_reset",function()
	RunConsoleCommand("bhop_requestspawn",LocalPlayer():GetDifficulty().key)
end)

net.Receive("BHOP.SendNotification",function()
	chat.AddText(ES.Color.White,"Started <hl>"..net.ReadString().."</hl> mode. Press F1 to change mode or F4 to reset.")
end)
