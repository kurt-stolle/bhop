-- cl_scoreboard.lua
-- the scoreboard
surface.CreateFont("BHOP.SB.Header",{
	font="Roboto",
	size=52,
	weight=400
})

vgui.Register("bhopSBoard",{
	Init = function(self) self.TimeCreate = SysTime() end,
	Paint = function(self,w,h)

		Derma_DrawBackgroundBlur(self,self.TimeCreate);
		local c = ES.GetColorScheme();

		draw.SimpleText("BUNNY HOP","BHOP.SB.Header",20,h*0.1,ES.Color.White,0,0);
	end
},"Panel");

surface.CreateFont("BHSBFont",{
	font = "Roboto",
	size = 16,
	weight = 400,
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
		draw.RoundedBox(2,0,0,w,h,ES.Color["#1E1E1EFF"]);
		draw.RoundedBox(2,1,1,w-2,h-2,Color(255,255,255,10));

		draw.SimpleText(self.text,"ESDefault-",6,4,ES.Color.White);
			draw.SimpleText(self.value,"bhopInfo",5,15,ES.Color.White)
	end
	pnl.Think = function(self)
		self.x = Lerp(3*FrameTime(),self.x,20);
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
