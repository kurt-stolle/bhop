-- cl_leaderboards.lua
-- the leaderboard menu

local lb;
local mapsPanel;
local mapSelected;
local statsDisplay;
local boards = {};


local function fixvalue(v)
	if string.len(tostring(v)) < 2 then
		return "0"..v;
	end
	return v;
end


local function drawtext(txt,x,y)
	draw.SimpleText(txt,"ESDefaultBold",x,y,COLOR_WHITE,0,1);
end


local function fixTime(str)
	local build = "";
	if string.find(str,"%.") then
		local parts = string.Explode(".",str);
		build = fixvalue(math.floor(tonumber(parts[1])/60))..":"..fixvalue(tonumber(parts[1]) - math.floor(tonumber(parts[1])/60)*60)
		build = build..":"..fixvalue(string.Left(parts[2],2));
	else
		build = fixvalue(math.floor(tonumber(str)/60))..":".. fixvalue(tonumber(str) - math.floor(tonumber(str)/60)*60)..":00"
	end
	return build
end


local function fixDiff(str)
	return str == 1 and "Easy" or str == 2 and "Normal" or str == 3 and "Hard" or str == 4 and "Nightmare" or "Error";
end


local function createMenu()
	if lb and IsValid(lb) then lb:Remove() end

	mapSelected = game.GetMap();

	lb = vgui.Create("esFrame");
	lb:SetSize(800,410);
	lb:Center();
	lb:SetTitle("Stats");

		local stats = lb:Add("esPanel")
		stats:Dock(RIGHT)
		stats:DockMargin(5,35,5,5)
		stats:SetWide(210)
		function stats:PaintOver(w,h)
			local x,y;
			local highlight = true;
			for i=1,13 do
				x,y = 2,2+(i-1)*28;
				draw.RoundedBox(0,x,y,w-4,28,Color(0,0,0,highlight and 80 or 50));
				draw.RoundedBox(0,x+36,y,80,28,ES.Color["#00000011"]);
				drawtext(i,x+8,y+14);

				drawtext(statsDisplay and statsDisplay[i] and fixTime(statsDisplay[i].time) or "",x+48,y+14);
				drawtext(statsDisplay and statsDisplay[i] and fixDiff(tonumber(statsDisplay[i].difficulty)) or "",x+36+80+12,y+14);
				highlight=not highlight;

				if not statsDisplay then continue end
			end
		end

	local board = lb:Add("esPanel")
	board:Dock(FILL)
	board:DockMargin(0,35,0,5)
		local colWide = (board:GetWide()-5-5-5-5)/3;

		local easy = vgui.Create("esPanel",board);
		easy:SetPos(5,5);
		easy:SetSize(colWide,board:GetTall()-10)
		easy.PaintHook = function(w,h)
			draw.RoundedBox(2,2,2,w-4,20,Color(0,0,0,200));
			draw.SimpleText("Normal","ESDefaultBold",w/2,12,Color(255,255,255),1,1);

			local x,y
			for i=1,10 do
				local x,y = 5,26 + (i-1)*30;
				draw.RoundedBox(2,x,y,w-10,28,Color(0,0,0,200));
				draw.RoundedBox(2,x,y,28,28,COLOR_BLACK);
				draw.SimpleText(i,"TargetID",x+14,y+14,COLOR_WHITE,1,1)

				if not boards[mapSelected] or not boards[mapSelected][2] or not boards[mapSelected][2][i] then continue end
				draw.SimpleText(boards[mapSelected][2][i].name ,"ESDefaultSmall",x+35,y+3,COLOR_WHITE,0,0)
				draw.SimpleText(fixTime(boards[mapSelected][2][i].time) ,"ESDefaultSmall",x+35,y+15,Color(255,152,0),0,0)
			end
		end

	local norm = vgui.Create("esPanel",board);
	norm:SetPos(5+colWide+5,5);
	norm:SetSize(colWide,board:GetTall()-10)
	norm.PaintHook = function(w,h)
		draw.RoundedBox(2,2,2,w-4,20,Color(0,0,0,200));
		draw.SimpleText("Hard","ESDefaultBold",w/2,12,Color(255,255,255),1,1);

		local x,y
		for i=1,10 do
			local x,y = 5,26 + (i-1)*30;
			draw.RoundedBox(2,x,y,w-10,28,Color(0,0,0,200));
			draw.RoundedBox(2,x,y,28,28,COLOR_BLACK);
			draw.SimpleText(i,"TargetID",x+14,y+14,COLOR_WHITE,1,1)

			if not boards[mapSelected] or not boards[mapSelected][3] or not boards[mapSelected][3][i] then continue end
			draw.SimpleText(boards[mapSelected][3][i].name ,"ESDefaultSmall",x+35,y+3,COLOR_WHITE,0,0)
			draw.SimpleText(fixTime(boards[mapSelected][3][i].time) ,"ESDefaultSmall",x+35,y+15,Color(255,152,0),0,0)
		end
	end

	local night = vgui.Create("esPanel",board);
	night:SetPos(5+colWide+5+colWide+5,5);
	night:SetSize(colWide,board:GetTall()-10)
	night.PaintHook = function(w,h)
		draw.RoundedBox(2,2,2,w-4,20,Color(0,0,0,200));
		draw.SimpleText("Nightmare","ESDefaultBold",w/2,12,Color(255,255,255),1,1);

		local x,y
		for i=1,10 do
			local x,y = 5,26 + (i-1)*30;
			draw.RoundedBox(2,x,y,w-10,28,Color(0,0,0,200));
			draw.RoundedBox(2,x,y,28,28,COLOR_BLACK);
			draw.SimpleText(i,"TargetID",x+14,y+14,COLOR_WHITE,1,1)

			if  not boards[mapSelected] or not boards[mapSelected][4] or not boards[mapSelected][4][i]  then continue end
			draw.SimpleText(boards[mapSelected][4][i].name ,"ESDefaultSmall",x+35,y+3,COLOR_WHITE,0,0)
			draw.SimpleText(fixTime(boards[mapSelected][4][i].time) ,"ESDefaultSmall",x+35,y+15,Color(255,152,0),0,0)
		end
	end
-- todo

local mapselection = vgui.Create("esPanel",lb);
	mapselection:SetWide(200)
	mapselection:Dock(LEFT)
	mapselection:DockMargin(5,35,5,5)
	mapselection.PaintHook = function(w,h)
		draw.RoundedBox(2,2,2,w-4,20,Color(0,0,0,200));
		draw.SimpleText(string.gsub(mapSelected,"bhop_",""),"ESDefaultBold",w/2,12,Color(255,255,255),1,1);
	end

	mapsPanel = mapselection:Add("Panel");
	mapsPanel:SetPos(5,27);
	mapsPanel:SetSize(mapselection:GetWide()-10,mapselection:GetTall()-10-20-2)

	lb:MakePopup();

	RunConsoleCommand("bhop_requestmaps");
	RunConsoleCommand("bhop_requeststats",mapSelected)
	if !boards[mapSelected] then
		RunConsoleCommand("bhop_requestboards",mapSelected);
	end
end
net.Receive("bhopSendMaps",function()
	local maps = net.ReadTable();

	if !IsValid(mapsPanel) then return end
	local btns = {}
	for k,v in pairs(maps)do
		local b = mapsPanel:Add("esButton");
		b:SetText(string.gsub(v,"bhop_",""));
		b.DoClick = function()
			mapSelected = v;
			RunConsoleCommand("bhop_requeststats",mapSelected);

			if !boards[mapSelected] then
				RunConsoleCommand("bhop_requestboards",mapSelected);
			end
		end
		b:SetSize(mapsPanel:GetWide(),30);
		b:SetPos(0,(k-1)*34)

		btns[#btns+1] = b;
	end

	if btns[#btns] and btns[#btns].y + btns[#btns]:GetTall() > mapsPanel:GetTall() then
		local scr = mapsPanel:Add("esScrollbar");
		scr:SetPos(mapsPanel:GetWide()-15,0);
		scr:SetSize(15,mapsPanel:GetTall());
		scr:SetUp()

		for k,v in pairs(btns)do
			v:SetWide(v:GetWide()-17);
		end
	end
end)
net.Receive("bhopSendStats",function()
	statsDisplay = net.ReadTable();
	ES.DebugPrint("received stats");
end)

net.Receive("bhopSendBoards",function()
	if !boards then boards = {} end
	boards[net.ReadString()] = net.ReadTable();
	ES.DebugPrint("received boards");
end)

concommand.Add("bhop_open_leaderboards",createMenu)
