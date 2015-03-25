-- cl_scoreboard.lua
-- the scoreboard
surface.CreateFont("BHOP.SB.Header",{
	font="Roboto",
	size=52,
	weight=400
})

local popModelMatrix = cam.PopModelMatrix
local pushModelMatrix = cam.PushModelMatrix
local pushFilterMag = render.PushFilterMag
local pushFilterMin = render.PushFilterMin
local popFilterMag = render.PopFilterMag
local popFilterMin = render.PopFilterMin

local matrixAngle = Angle(0, 0, 0)
local matrixScale = Vector(0, 0, 0)
local matrixTranslation = Vector(0, 0, 0)


local matrix,x,y,width,height,rad

vgui.Register("bhopSBoard",{
	Init = function(self) self.TimeCreate = SysTime() end,
	Paint = function(self,w,h)

		Derma_DrawBackgroundBlur(self,self.TimeCreate);
		draw.SimpleText("BUNNY HOP","BHOP.SB.Header",20,h*0.1,ES.Color.White,0,0);
	end
},"Panel");

vgui.Register("bhopSBoard.InfoRow",{
	Init=function(self)
		self.scale=0
		self.delay=0
	end,
	Think=function(self,w,h)
		if self.delay > CurTime() then return end

		self.scale=Lerp(FrameTime()*8,self.scale,1)
	end,
	Paint=function(self,w,h)
		pushFilterMag( TEXFILTER.ANISOTROPIC )
		pushFilterMin( TEXFILTER.ANISOTROPIC )

		x,y=self:LocalToScreen(w/2,h/2)
		x,y=(self.scale-1)*-x,(self.scale-1)*-y

		matrix=Matrix()
		matrix:SetAngles( matrixAngle )
		matrixTranslation.x = x
		matrixTranslation.y = y
		matrix:SetTranslation( matrixTranslation )
		matrixScale.x = self.scale
		matrixScale.y = self.scale
		matrix:Scale( matrixScale )

		-- push matrix
		pushModelMatrix( matrix )

		draw.RoundedBox(2,0,0,w,h,ES.Color["#1E1E1EFF"]);
		draw.RoundedBox(2,1,1,w-2,h-2,Color(255,255,255,10));

		draw.SimpleText(self.text,"ESDefault-",6,4,ES.Color.White);
		draw.SimpleText(self.value,"bhopInfo",5,15,ES.Color.White)
	end,
	PaintOver=function(self,w,h)
		popModelMatrix()
		popFilterMag( TEXFILTER.ANISOTROPIC )
		popFilterMin( TEXFILTER.ANISOTROPIC )
	end
},"Panel")

vgui.Register("bhopSBoard.PlayerRow",{
	Init=function(self)
		self.scale=0
		self.delay=0
		self.xSmooth=ScrW()
		self.xTarg=ScrW()
	end,
	Think=function(self,w,h)
		if self.delay > CurTime() then return end

		self.xSmooth=Lerp(FrameTime()*8,self.xSmooth,self.xTarg)
		self.x=self.xSmooth
	end
},"Panel")

surface.CreateFont("BHSBFont",{
	font = "Roboto",
	size = 16,
	weight = 400,
})
local sb;
local function addPerformanceRow(parent,name,value)
	parent.performanceRows = (parent.performanceRows or -1)+1;

	local pnl = vgui.Create("bhopSBoard.InfoRow",parent);
	pnl:SetSize(300,40);
	pnl:SetPos(20,ScrH()*0.1+70+20+parent.performanceRows*50);
	pnl.text = string.upper(name);
	pnl.value = value;
	pnl.delay=CurTime()+(parent.performanceRows *.1)
end
local function addPlayerRow(parent,ply)
	parent.playerRows = (parent.playerRows or -1)+1;

	if not parent.switchleft and (parent.playerRows+1)*42 > parent:GetTall() then
		parent.switchleft = true;
		parent.playerRows = 0;
	end

	local pnl = vgui.Create("bhopSBoard.PlayerRow",parent);
	pnl:SetSize(300,40);
	pnl.x=ScrW()
	pnl.xTarg=parent.switchleft and 0 or 320;
	pnl.y=parent.playerRows*42;
	pnl.text = ply:Nick();
	pnl.delay=CurTime()+.3+(parent.playerRows *.1)
	pnl.Paint = function(self,w,h)
		if not IsValid(ply) then if IsValid(self) then self:Remove() end return end


		draw.RoundedBox(2,0,0,w,h,ES.Color["#1E1E1EFF"]);
		draw.RoundedBox(2,1,1,w-2,h-2,ply:GetDifficulty().color);
		draw.RoundedBox(2,2,2,w-4,h-4,ES.Color["#000000aa"]);

		draw.SimpleText(self.text,"bhopInfo",43,2,ES.Color.White)
		draw.SimpleText(ply:GetTimeString(),"ESDefault-",43,23,Color(250,250,250));
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
  	txt:SetColor(ES.Color.White);

  	addPerformanceRow(sb,"Difficulty",LocalPlayer():GetDifficulty().name);
  	addPerformanceRow(sb,"Rank",LocalPlayer():GetRank().name)
  	addPerformanceRow(sb,"Total points",LocalPlayer():GetPoints());
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
