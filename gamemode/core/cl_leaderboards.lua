-- cl_leaderboards.lua
-- the leaderboard menu

local lb;
local mapsPanel;
local lblMap;
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
	return str == 1 and "Practise" or str == 2 and "Autohop" or str == 3 and "Classic" or str == 4 and "Insanity" or "Error";
end


local function createMenu()
	if lb and IsValid(lb) then lb:Remove() end

	mapSelected = game.GetMap();

	lb = vgui.Create("esFrame");
	lb:SetSize(900,410);
	lb:Center();
	lb:SetTitle("Stats");

	local right=lb:Add("Panel")
	right:Dock(FILL)
	right:DockMargin(0,0,0,0)

	local lbl=right:Add("esLabel")
	lbl:SetFont("ESDefault++")
	lbl:SetText(string.upper(mapSelected))
	lbl:Dock(TOP)
	lbl:DockMargin(5,5,5,0)
	lbl:SizeToContents()

	lblMap=lbl;

	local stats = right:Add("esPanel")
		stats:Dock(RIGHT)
		stats:DockMargin(5,5,5,5)
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

	local board = right:Add("esPanel")
	board:Dock(FILL)
	board:DockMargin(0,5,0,5)
		local autohop = vgui.Create("esPanel",board);
		autohop:SetColor(ES.GetColorScheme(3))
		autohop.PaintOver = function(self,w,h)
			draw.RoundedBox(2,2,2,w-4,20,Color(0,0,0,200));
			draw.SimpleText("Autohop","ESDefaultBold",w/2,12,Color(255,255,255),1,1);

			local x,y
			for i=1,10 do
				x,y = 5,26 + (i-1)*30;
				draw.RoundedBox(2,x,y,w-10,28,Color(0,0,0,200));
				draw.RoundedBox(2,x,y,28,28,Color(0,0,0,150));
				draw.SimpleText(i,"ESDefault+",x+14,y+14,COLOR_WHITE,1,1)

				if not boards[mapSelected] or not boards[mapSelected][2] or not boards[mapSelected][2][i] then continue end
				draw.SimpleText(boards[mapSelected][2][i].name ,"ESDefault-",x+35,y+1,COLOR_WHITE,0,0)
				draw.SimpleText(fixTime(boards[mapSelected][2][i].time) ,"ESDefault-",x+35,y+15,COLOR_WHITE,0,0)
			end
		end

		local classic = vgui.Create("esPanel",board);
		classic:SetColor(ES.GetColorScheme(3))
		classic.PaintOver = function(self,w,h)
			draw.RoundedBox(2,2,2,w-4,20,Color(0,0,0,200));
			draw.SimpleText("Classic","ESDefaultBold",w/2,12,Color(255,255,255),1,1);

			local x,y
			for i=1,10 do
				x,y = 5,26 + (i-1)*30;
				draw.RoundedBox(2,x,y,w-10,28,Color(0,0,0,200));
				draw.RoundedBox(2,x,y,28,28,Color(0,0,0,150));
				draw.SimpleText(i,"ESDefault+",x+14,y+14,COLOR_WHITE,1,1)

				if not boards[mapSelected] or not boards[mapSelected][3] or not boards[mapSelected][3][i] then continue end
				draw.SimpleText(boards[mapSelected][3][i].name ,"ESDefault-",x+35,y+1,COLOR_WHITE,0,0)
				draw.SimpleText(fixTime(boards[mapSelected][3][i].time) ,"ESDefault-",x+35,y+15,COLOR_WHITE,0,0)
			end
		end

		local insanity = vgui.Create("esPanel",board)
		insanity:SetColor(ES.GetColorScheme(3))
		insanity.PaintOver = function(self,w,h)
			draw.RoundedBox(2,2,2,w-4,20,Color(0,0,0,200));
			draw.SimpleText("Insanity","ESDefaultBold",w/2,12,Color(255,255,255),1,1);

			local x,y
			for i=1,10 do
				x,y = 5,26 + (i-1)*30;
				draw.RoundedBox(2,x,y,w-10,28,Color(0,0,0,200));
				draw.RoundedBox(2,x,y,28,28,Color(0,0,0,150));
				draw.SimpleText(i,"ESDefault+",x+14,y+14,COLOR_WHITE,1,1)

				if  not boards[mapSelected] or not boards[mapSelected][4] or not boards[mapSelected][4][i]  then continue end
				draw.SimpleText(boards[mapSelected][4][i].name ,"ESDefault-",x+35,y+1,COLOR_WHITE,0,0)
				draw.SimpleText(fixTime(boards[mapSelected][4][i].time) ,"ESDefault-",x+35,y+15,COLOR_WHITE,0,0)
			end
		end

	board.PerformLayout=function(self)
		local colWide=(self:GetWide()-(5*4))/3
		local colTall=self:GetTall()-(5*2)

		autohop:SetPos(5,5)
		classic:SetPos(5+colWide+5,5)
		insanity:SetPos(5+colWide+5+colWide+5,5)

		insanity:SetSize(colWide,colTall)
		autohop:SetSize(colWide,colTall)
		classic:SetSize(colWide,colTall)
	end
-- todo

	local mapselection = vgui.Create("Panel",lb);
	mapselection:SetWide(160)
	mapselection:Dock(LEFT)
	mapselection:DockMargin(5,35,5,5)

	mapsPanel = mapselection;

	lb:MakePopup();

	RunConsoleCommand("bhop_requestmaps");
	RunConsoleCommand("bhop_requeststats",mapSelected)
	if !boards[mapSelected] then
		RunConsoleCommand("bhop_requestboards",mapSelected);
	end
end
net.Receive("bhopSendMaps",function()
	local maps = net.ReadTable();

	if not IsValid(mapsPanel) then return end

	local btns = {}
	for k,v in pairs(maps)do
		local b = mapsPanel:Add("esButton");
		b:SetText(string.gsub(v,"bhop_",""));
		b.DoClick = function()
			mapSelected = v;
			lblMap:SetText(string.upper(v))
			lblMap:SizeToContents()
			RunConsoleCommand("bhop_requeststats",mapSelected);

			if not boards[mapSelected] then
				RunConsoleCommand("bhop_requestboards",mapSelected);
			end
		end
		b:SetTall(30)
		b:Dock(TOP)

		btns[#btns+1] = b;
	end

	local scr = mapsPanel:Add("esScrollbar");
	scr:Setup()
end)
net.Receive("bhopSendStats",function()
	statsDisplay = net.ReadTable();
	BHOP.DebugPrint("received stats");
end)

net.Receive("bhopSendBoards",function()
	if !boards then boards = {} end
	boards[net.ReadString()] = net.ReadTable();
	BHOP.DebugPrint("received boards");
end)

concommand.Add("bhop_open_leaderboards",createMenu)
