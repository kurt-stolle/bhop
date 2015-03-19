net.Receive("bhPlayerStarted",function()
	local p = net.ReadEntity();
	local diff = net.ReadUInt(4);
	if not p or not IsValid(p) then return end

	p.Difficulty = diff;
	p.StartTime = CurTime();
end)
net.Receive("bhPlayerSynchActive",function()
	local t = net.ReadTable();
	if not t then return end

	for k,v in pairs(t)do
		if IsValid(v.ply) then
			v.ply.Difficulty = v.Difficulty;
			v.ply.StartTime = v.StartTime;
		end
	end
end)

BHOP.blockGroups = {};
BHOP.blocks = {};

net.Receive("bhopSynchBlocks",function()
	BHOP.blockGroups = net.ReadTable();

	BHOP.blocks = net.ReadTable();

	ES.DebugPrint("Block groups updated");
end);

local showBlocks = false;
local req = false;
concommand.Add("bhop_showconfig",function()
	showBlocks = true;
	if not req then
		RunConsoleCommand("bhop_requestsynch")
		req = true;
	end
end)
concommand.Add("bhop_noshowconfig",function()
	showBlocks = false;
end)

hook.Add("HUDPaint","bhopDrawMapConfig",function()
	if showBlocks then
		for k,v in pairs(BHOP.blockGroups)do
			surface.SetDrawColor(COLOR_BLACK);
			local pos = v:ToScreen();
			surface.DrawRect(pos.x-10,pos.y-10,20,20);
			draw.SimpleText(k,"DermaDefaultBold",pos.x,pos.y,COLOR_WHITE,1,1)
		end
		for k,v in pairs(BHOP.blocks)do
			if k and Entity(k) and IsValid(Entity(k)) and Entity(k):GetClass() == "func_door" then
				surface.SetDrawColor(COLOR_BLACK);
				local pos = Entity(k):LocalToWorld(Entity(k):OBBCenter()):ToScreen();
				draw.SimpleTextOutlined(tostring(v),"ESDefaultBold",pos.x,pos.y,COLOR_WHITE,1,1,1,COLOR_BLACK)
			end
		end
	end
end)

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
	if bind == "+menu" then
		RunConsoleCommand("bhop_dropweapon")
		return true
	elseif bind == "gm_showhelp" then
		RunConsoleCommand("bhop_open_difficulty")
		return true
	elseif bind == "gm_showspare2" then
		RunConsoleCommand("bhop_requestspawn",LocalPlayer():GetDifficulty())
		return true
	end
end)

concommand.Add("bhop_reset",function()
	RunConsoleCommand("bhop_requestspawn",LocalPlayer():GetDifficulty())
end)
