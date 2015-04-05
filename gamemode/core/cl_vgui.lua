-- cl_menus
surface.CreateFont("BHOPDifficultyHeader",{
	font="Roboto",
	weight=500,
	size=60
})
surface.CreateFont("BHOPDifficultyTeamInfo",{
	font="Roboto",
	weight=400,
	size=18
})

COLOR_BLACK = COLOR_BLACK or Color(0,0,0)
COLOR_WHITE = COLOR_WHITE or Color(255,255,255)

local frameAlready
local joinFrame
local openSpawnSelection = function() end
local function hasAlreadyCompleted(dif)
	if frameAlready and IsValid(frameAlready) then frameAlready:Remove() end

	frameAlready = vgui.Create("esFrame")
	frameAlready.Title = "Warning"
	frameAlready:SetSize(300,120)
	frameAlready:Center()
	frameAlready:MakePopup()

	local lbl = Label("You have already completed this difficulty!\nYou won't gain any more bananas.\nYou will gain bhop points.",frameAlready)
	lbl:SetPos(5,35)
	lbl:SetFont("BHOPDifficultyTeamInfo")
	lbl:SizeToContents()
	lbl:SetColor(COLOR_BLACK)

	local but = frameAlready:Add("esButton")
	but:SetText("Back")
	but:SetSize((300-15)/2,20)
	but:SetPos(5,frameAlready:GetTall()-5-20)
	but.OnMouseReleased = function(self)
		openSpawnSelection("Select a new team\n\n\n")

		if frameAlready and IsValid(frameAlready) then frameAlready:Remove() end
	end

	local but2 = frameAlready:Add("esButton")
	but2:SetText("Play Anyway")
	but2:SetSize((300-15)/2,20)
	but2:SetPos(5 + (300-15)/2 + 5,frameAlready:GetTall()-5-20)
	but2.OnMouseReleased = function(self)

		RunConsoleCommand("bhop_requestspawn",dif)

		if frameAlready and IsValid(frameAlready) then frameAlready:Remove() end
	end
end
net.Receive("bhopHasAlreadyCompleted",hasAlreadyCompleted)

local modeInfo={
	{},{},{},{}
}

modeInfo[1]["Autohop"]=true;
modeInfo[1]["5.0s jump time"]=true
modeInfo[1]["Ranked"]=false
modeInfo[1]["Reduced reward"]=true

modeInfo[2]["Autohop"]=true;
modeInfo[2]["0.2s jump time"]=true
modeInfo[2]["Ranked"]=true
modeInfo[2]["Normal reward"]=true

modeInfo[3]["Autohop"]=false;
modeInfo[3]["0.2s jump time"]=true
modeInfo[3]["Ranked"]=true
modeInfo[3]["Generous reward"]=true

modeInfo[4]["Autohop"]=false;
modeInfo[4]["0.0s jump time (kill)"]=true
modeInfo[4]["Ranked"]=true
modeInfo[4]["Big reward"]=true

local check=Material("icon16/tick.png")
local cross=Material("icon16/cross.png")

local btnWide = 240;
local marginX = (ScrW()-(btnWide*4))/5
local close=false;
local y; -- for later
openSpawnSelection = function()
	if IsValid(joinFrame) then return end

	local joinFrame = vgui.Create("Panel");
	joinFrame:SetSize(ScrW(),ScrH());
	joinFrame:SetPos(0,0);
	joinFrame.TimeCreate = SysTime();
	joinFrame.OnMouseReleased = function(self)
		if gui.MouseX() > self:GetWide()-marginX-300 and gui.MouseY() < (ScrH()/2 - 512/2 - 74 + 70) then
			self:Remove();
		end
	end
	joinFrame.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0,200));
		Derma_DrawBackgroundBlur(self,self.TimeCreate);

		draw.SimpleText("SELECT YOUR MODE","BHOPDifficultyHeader",marginX,marginX,COLOR_WHITE,0,0);
		if close then

			draw.SimpleText("×","BHOPDifficultyHeader",w-marginX,marginX, gui.MouseX() > self:GetWide()-marginX-300 and gui.MouseY() < (ScrH()/2 - 512/2 - 74 + 70) and COLOR_WHITE or Color(200,200,200),2,0);
		end
	end

	local info
	local pnl
	for i=1,(#BHOP.Difficulties) do
		pnl=vgui.Create("esPanel",joinFrame)
		pnl:SetColor(ES.Color["#1E1E1E"])
		pnl:SetSize(btnWide,40+300)
		pnl:SetPos(marginX*i + (i-1)*btnWide,ScrH()/2 -pnl:GetTall()/2);

		local title=vgui.Create("esLabel",pnl)
		title:SetText(BHOP.Difficulties[i].name.." mode")
		title:SetFont("ESDefault++")
		title:SizeToContents()
		title:DockMargin(15,15,15,15)
		title:Dock(TOP)

		local btn = vgui.Create("esButton",pnl);
		btn:SetTall(40)
		btn:Dock(BOTTOM)
		btn.OnMouseReleased = function(self)
			if i <= #BHOP.Difficulties and LocalPlayer():HasCompletedDifficulty(BHOP.Difficulties[i]) then
				hasAlreadyCompleted(i)
			else
				RunConsoleCommand("bhop_requestspawn",i)
				BHOP.DebugPrint("Requesting spawn on difficulty: "..BHOP.Difficulties[i].name)
			end

			joinFrame:Remove()
		end
		btn:SetText(math.random(1,1000) == 1 and "Gotta go fast!" or "Go!");

		for k,v in pairs(modeInfo[i])do
			local row=vgui.Create("Panel",pnl)
			row:SetTall(16)
			row:Dock(TOP)
			row:DockMargin(15,15,15,0)
			local mat=vgui.Create("DImage",row)
			mat:SetMaterial(v and check or cross)
			mat:SetSize(16,16)
			mat:SetPos(0,0)
			local lbl=vgui.Create("esLabel",row)
			lbl:SetText(k)
			lbl:SetFont("ESDefault")
			lbl:SizeToContents()
			lbl:SetPos(26,0)


		end

		y=pnl.y+pnl:GetTall()

	end

	local btnspec=vgui.Create("esButton",joinFrame)
	btnspec:SetSize(240,40)
	btnspec:SetPos(ScrW()/2 - btnspec:GetWide()/2,y+marginX)
	btnspec:SetText("Spawn as spectator")
	btnspec.OnMouseReleased=function(self)
		RunConsoleCommand("bhop_requestspawn",5)
	end


	joinFrame:MakePopup();

	close=true
end
concommand.Add("bhop_open_difficulty",openSpawnSelection)
hook.Add("Initialize","BHOP.OpenDifficultyOnJoin",openSpawnSelection)
