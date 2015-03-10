-- cl_scoreboard.lua
-- the scoreboard
COLOR_BLACK = COLOR_BLACK or Color(0,0,0);
COLOR_WHITE = COLOR_WHITE or Color(255,255,255);

vgui.Register("bhopSBoard",{
	Init = function(self) self.TimeCreate = SysTime() end,
	Paint = function(self,w,h)

		//draw.RoundedBox(0,0,0,w,h,Color(0,0,0,20));
		Derma_DrawBackgroundBlur(self,self.TimeCreate);
		local c = ES.GetColorScheme();
		surface.SetDrawColor(c);
		surface.DrawRect(0,0,w,4);

		draw.SimpleText("BUNNY HOP","exclMapTimeleft",20,h*0.1,COLOR_WHITE,0,0);
	end
},"Panel");

surface.CreateFont("BHSBFont",{
	font = "Roboto",
	size = 18,
	weight = 500,
})
local sb;
local function addPerformanceRow(parent,name,value)
	parent.performanceRows = (parent.performanceRows or -1)+1;

	local pnl = vgui.Create("Panel",parent);
	pnl:SetSize(300,40);
	pnl:SetPos(-300,ScrH()*0.1+70+20+parent.performanceRows*50);
	pnl.text = string.upper(name);
	pnl.value = value;
	pnl.Paint = function(self,w,h)


		draw.RoundedBox(2,0,0,w,h,Color(50,50,50));
		draw.RoundedBox(2,1,1,w-2,h-2,Color(255,255,255,10));

		draw.SimpleText(self.text,"ESDefault.Shadow",6,2,COLOR_BLACK)
		draw.SimpleText(self.text,"ESDefault",6,2,Color(220,220,220));
			draw.SimpleText(self.value,"bhopInfo",5,13,COLOR_WHITE)
	end
	pnl.Think = function(self)
		self.x = Lerp(0.3,self.x,20);
	end

end
local function addPlayerRow(parent,ply)
	parent.playerRows = (parent.playerRows or -1)+1;

	if !parent.switchleft and (parent.playerRows+1)*42 > parent:GetTall() then
		parent.switchleft = true;
		parent.playerRows = 0;
	end

	local pnl = vgui.Create("Panel",parent);
	pnl:SetSize(300,40);
	pnl:SetPos(parent.switchleft and 0 or 320,parent.playerRows*42);
	pnl.text = ply:Nick();
	pnl.Paint = function(self,w,h)
		if not IsValid(ply) then if IsValid(self) then self:Remove() end return end


		draw.RoundedBox(2,0,0,w,h,Color(50,50,50));
		local c = ply:GetDifficulty().color;
		local d = table.Copy(c);
		d.a = 50;

		draw.RoundedBox(2,1,1,w-2,h-2,d);

			draw.SimpleText(self.text,"bhopInfo",43,1,COLOR_WHITE)
			draw.SimpleText(ply:Deaths().." fails in "..ply:GetTimeString(),"ESDefault.Shadow",43,24,COLOR_BLACK)
		draw.SimpleText(ply:Deaths().." fails in "..ply:GetTimeString(),"ESDefault",43,24,Color(250,250,250));
	end

	local av = vgui.Create("AvatarImage",pnl);
	av:SetSize(32,32);
	av:SetPos((40-32)/2,(40-32)/2)
	av:SetPlayer(ply)
end
function BHOP:ScoreboardShow()
  	if sb and IsValid(sb) then sb:Remove() return end

  	sb = vgui.Create("bhopSBoard");
  	sb:SetSize(ScrW(),ScrH());
  	sb:SetPos(0,0);

  	local txt = Label("VERSION 5.0 CREATED BY EXCL",sb);
  	txt:SetFont("BHSBFont");
  	txt:SetPos(24,ScrH()*0.1+55);
  	txt:SizeToContents();
  	txt:SetColor(COLOR_WHITE);

	addPerformanceRow(sb,"Time left before mapvote",BHOP:GetTimeLeft())
	local d = LocalPlayer():GetDifficulty();
  	addPerformanceRow(sb,"Difficulty",d == 1 and "Easy" or d == 2 and "Normal" or d == 3 and "Hard" or d == 4 and "Nightmare" or d == 5 and "Spectator");
  	addPerformanceRow(sb,"Rank",LocalPlayer():GetRank())
  	addPerformanceRow(sb,"Total points",LocalPlayer():GetPoints());
  	addPerformanceRow(sb,"Fails in current session",LocalPlayer():Deaths());
  	addPerformanceRow(sb,"Personal record in this map",(LocalPlayer().BestTime or "00:00:00"))
	addPerformanceRow(sb,"Current time in this session",LocalPlayer():GetTimeString())

	local panel = sb:Add("Panel");
	panel:SetSize(620,ScrH()*.8);
	panel:SetPos(ScrW()-620-20,ScrH()*.1);

	for k,v in pairs(player.GetAll())do
		if not IsValid(v) then continue end
		addPlayerRow(panel,v)
	end
end

function BHOP:ScoreboardHide()
  	if sb and IsValid(sb) then sb:Remove() return end
end

--[[
local sbEnable = false;

local colorMainTheme = Color(255,152,0);

local width = 1050;
local height = 1660;
local cornerdepth = 64;

local x = 0;
local y = -(height/2);

local poly = {
	{x = x, y = y + cornerdepth},{x = x + cornerdepth,y=y},{x= x + width,y=y},
	{x=x + width,y=y+height-cornerdepth},{x = x + width - cornerdepth, y = y + height},{x = x, y = y + height},
}
local margin = 10;
local polyHeader = {
	{x = x+margin, y = y+  cornerdepth},
	{x = x + margin/2 + cornerdepth,y=y+margin},
	{x= x + width - margin,y=y+margin},

	{x=x + width-margin,y=y+cornerdepth},
}
local polyFooter = {
	{x = x+margin, y = y+height-margin },
	{x = x+margin, y = y+height-cornerdepth},
	{x = x+width-margin,y=y+height-cornerdepth},
	{x = x+width-cornerdepth- margin/2 , y= y+height-margin},
}
surface.CreateFont("bhSbHeader",{
	font = "Arial",
	weight = 700,
	size = 50
})
surface.CreateFont("bhSbHeaderCredits",{
	font = "Arial Narrow",
	weight = 700,
	size = 30,
	italic = true
})
surface.CreateFont("bhSbPlRowMain",{
	font = "Arial",
	weight = 700,
	size = 50
})
surface.CreateFont("bhSbPlRowInfos",{
	font = "Arial Narrow",
	weight = 500,
	italic = true,
	size = 50
})
surface.CreateFont("bhSbPlRowCount",{
	font = "Arial",
	weight = 700,
	size = 35
})
surface.CreateFont("bhLeftMain",{
	font = "Arial",
	weight = 700,
	size = 108
})
surface.CreateFont("bhLeftTime",{
	font = "Arial Narrow",
	weight = 400,
	italic = true,
	size = 108
})

local setcolor,drawrect,drawpoly = surface.SetDrawColor,surface.DrawRect,surface.DrawPoly;
local roundedbox,simpletext = draw.RoundedBox,draw.SimpleText;


local curYPos = y + cornerdepth + margin;
local count = 0;
local drawn = 0;
local scroll = 0;
local colorPlayerRowTheme = Color(180,180,180);
local function drawPlayerRow(p)
	count = count+1;

	if scroll > count or drawn >= 20 then return end

	setcolor(colorPlayerRowTheme);
	drawrect(x+margin,curYPos, width-margin*2 , 66);

	setcolor(p:GetDifficulty().color);
	drawrect(x + margin + 4, curYPos + 4, 58,58);

	simpletext(p:Nick() or "undefined","bhSbPlRowMain",x + margin + 2 + 64 + 10, curYPos + 8,COLOR_BLACK)
	simpletext(p:Deaths().." fails in "..p:GetTimeString(),"bhSbPlRowInfos",x + width -margin - 32, curYPos + 5,COLOR_BLACK,2)
	simpletext(count,"bhSbPlRowCount",x+margin+4+(58/2),curYPos+4+(58/2),COLOR_WHITE,1,1);
	curYPos = curYPos + 66 + margin;

	drawn = drawn+1;
end
hook.Add("Think","bhopSBThinkScroll",function()
	if sbEnable and #player.GetAll() > 20 then
		if input.IsMouseDown(MOUSE_LEFT) then
			scroll = scroll + 1;
			if scroll > #player.GetAll() - 20 then
				scroll = #player.GetAll() - 20;
			end
		elseif input.IsMouseDown(MOUSE_RIGHT) then
			scroll = scroll - 1;
			if scroll < 0 then
				scroll = 0;
			end
		end

	else
		scroll = 0;
	end
end)
local model;

local rotRight = 355;
local moveRight = 20;

local rotLeftA = 0;
local rotLeftB = -50;
local moveLeft = -30;

local scaleMargin = 0.005;
local scaleSize = 0.005;

function BHOP:CalcView(p,pos,ang,fov)
	return self.BaseClass:CalcView(p,pos,ang,90);
end

hook.Add("PostDrawTranslucentRenderables", "bhopDrawScoreboard", function()
	if sbEnable then
		local p = LocalPlayer();
		if IsValid(p) then
			if ScrW() >= 1900 then
				scaleMargin = 0.02;
			elseif ScrW() > 1500 then
				scaleMargin = 0.04;
			elseif ScrW() > 1300 then
				scaleMargin = 0.009;
			end
			if ScrH() >= 1080 then
				scaleSize = 0.002;
			elseif ScrH() > 800 then
				scaleSize = 0.004;
			end


			local ang = p:EyeAngles();
			rotRight = Lerp(0.09,rotRight,255)
			moveRight = Lerp(0.09,moveRight,1) + ScreenScale(scaleMargin);
			ang:RotateAroundAxis(ang:Up(),rotRight)
			ang:RotateAroundAxis(ang:Forward(),90)
			cam.IgnoreZ(true);
			render.PushFilterMag(3)
			render.PushFilterMin(3)
			cam.Start3D2D( p:EyePos() + p:EyeAngles():Forward() * 15 + p:EyeAngles():Right() * moveRight + p:EyeAngles():Up() * .7, ang, ScreenScale(scaleSize) )
				roundedbox(0,x,y,width,height,Color(0,0,0,0))
				setcolor(COLOR_BLACK)
				drawpoly(poly);
				drawpoly(poly);
				-- SB header

				setcolor(colorMainTheme)
				drawpoly(polyHeader);
				simpletext("BUNNY HOP","bhSbHeader",x+cornerdepth+margin+5,y + margin/2 + cornerdepth/2,COLOR_BLACK,0,1);
				simpletext("CREATED BY EXCL","bhSbHeaderCredits",x+width-margin-margin,y+cornerdepth-35,COLOR_BLACK,2)
				-- PLAYER BARS

				drawPlayerRow(p)
				for k,v in pairs(player.GetAll())do
					if v ~= p then
						drawPlayerRow(v)
					end
				end
				curYPos = y + cornerdepth + margin;
				count = 0;
				drawn = 0;
				-- FOOTER

				setcolor(colorMainTheme)
				drawpoly(polyFooter);
				simpletext("USE LEFT AND RIGHT MOUSE TO SCROLL","bhSbHeaderCredits",x+margin+5,y + height - (margin/2 + cornerdepth/2),COLOR_BLACK,0,1);

			cam.End3D2D();
			render.PopFilterMag()
					render.PopFilterMin()

					rotLeftA = Lerp(0.1,rotLeftA,280);
			rotLeftB = Lerp(0.1,rotLeftB,90);
			moveLeft = Lerp(0.1,moveLeft,-9) - ScreenScale(scaleMargin);

			local ang = p:EyeAngles();
			ang:RotateAroundAxis(ang:Up(),rotLeftA)
			ang:RotateAroundAxis(ang:Forward(),rotLeftB)



			render.PushFilterMag(3)
					render.PushFilterMin(3)
			cam.Start3D2D( p:EyePos() + p:EyeAngles():Forward() * 15 + p:EyeAngles():Right() * moveLeft + p:EyeAngles():Up() * .7, ang, ScreenScale(scaleSize) )
				roundedbox(0,0,160 + 160 + -height/2,width,120,Color(0,0,0,240))
				roundedbox(4,8,160 + 160 + -height/2 + 8 ,8,104,colorMainTheme)

				simpletext("My Time","bhLeftMain",34,160 + 160 + -height/2+ 4,COLOR_WHITE)
				simpletext(p:GetTimeString(),"bhLeftTime",width-40,160 + 160 + -height/2 + 4,COLOR_WHITE,2)

				roundedbox(0,0,160+160 + 160+ -height/2,width,120,Color(0,0,0,240))
				roundedbox(4,8,160+160 + 160+ -height/2 + 8 ,8,104,colorMainTheme)

				simpletext("My Best","bhLeftMain",34,160+160 + 160 + -height/2+ 4,COLOR_WHITE)
				simpletext((p.BestTime or "00:00:00"),"bhLeftTime",width-40,160+160 + 160 + -height/2 + 4,COLOR_WHITE,2)

				roundedbox(0,0,160+160 +160 + 160+ -height/2,width,120,Color(0,0,0,240))
				roundedbox(4,8,160+160 +160 + 160+ -height/2 + 8 ,8,104,colorMainTheme)

				simpletext("Fails","bhLeftMain",34,160+160 +160 + 160 -height/2+ 4,COLOR_WHITE)
				simpletext(p:Deaths(),"bhLeftTime",width-40,160+160 +160 + 160+ -height/2 + 4,COLOR_WHITE,2)

				roundedbox(0,0,-height/2,width,120,Color(0,0,0,240))
				roundedbox(4,8, -height/2 + 8 ,8,104,colorMainTheme)

				simpletext("Difficulty","bhLeftMain",34, -height/2+ 4,COLOR_WHITE)

				local diff = p:GetDifficulty();
				for i=0,3 do
					setcolor(Color(120,120,120));
					drawrect(680 + 90*i,-height/2 + 20,80,80);
					if diff-1 >= i then
						setcolor(colorMainTheme)
						drawrect(690 + 90*i,-height/2 + 30,60,60);
					end
				end

				roundedbox(0,0,160 -height/2,width,120,Color(0,0,0,240))
				roundedbox(4,8,160 -height/2 + 8 ,8,104,colorMainTheme)

				simpletext("Time left","bhLeftMain",34,160 -height/2+ 4,COLOR_WHITE)
				simpletext(BHOP:GetTimeLeft(),"bhLeftTime",width-40,160 -height/2 + 4,COLOR_WHITE,2)

				roundedbox(0,0,160+160 +160 + 160+160+ -height/2,width,120,Color(0,0,0,240))
				roundedbox(4,8,160+160 +160 + 160+160+ -height/2 + 8 ,8,104,colorMainTheme)

				simpletext("Total Points","bhLeftMain",34,160+160 +160 + 160+160+ -height/2+ 4,COLOR_WHITE)
				simpletext(p:GetPoints(),"bhLeftTime",width-40,160+160 +160 + 160+160+ -height/2 + 4,COLOR_WHITE,2)


				local rank = LocalPlayer():GetRank();

				roundedbox(0,0,160+160+160+160+160+160+ -height/2,width,120,Color(0,0,0,240))
				roundedbox(4,8,160+160+160+160+160+160+ -height/2 + 8 ,8,104,colorMainTheme)
				simpletext("Rank","bhLeftMain",34,160+160+160+160+160+160+ -height/2+ 4,COLOR_WHITE)
				simpletext(rank,"bhLeftTime",width-40,160+160+160+160+160+160+ -height/2 + 4,COLOR_WHITE,2)

			cam.End3D2D();

				render.PopFilterMag()
					render.PopFilterMin()

			cam.IgnoreZ(false);
		end
	end
end  )

function BHOP:ScoreboardShow()
  	sbEnable = true;
  	--gui.EnableScreenClicker(true)
end

function BHOP:ScoreboardHide()
   sbEnable = false;
   rotRight = 355;
   moveRight = 20;

   rotLeftA = 0;
	rotLeftB = -50;
	moveLeft = -30;

	--gui.EnableScreenClicker(false)
end]]
