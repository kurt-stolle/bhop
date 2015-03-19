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

local helpText = {}
helpText[1] = [[This mode is for absolute beginners, you are allowed to cheat in this mode (using autohop, etc).
Press and hold ]].. ( string.upper(input.LookupBinding("+menu_context") or "NOT BOUND (+menu_context)") ) ..[[ to auto bhop.
- 0.5 seconds per block
- Checkpoint teleportation on fail
- 5 bananas on finishing the map
- Does not show up in leaderboards]]
helpText[2] = [[Original bunnyhop, how it has always been in other games.
- 0.2 seconds per block
- Checkpoint teleportation on fail
- 10 bananas on finishing the map
- Ranked]]
helpText[3] = [[Hard mode, you will have a hard time finishing this.
- 0.05 seconds per block
- Checkpoint teleportation on fail
- 15 bananas on finishing the map
- Ranked]]
helpText[4] = [[Nightmare mode. You will not complete this.
- 0.05 seconds per block
- You fail You die.
- 20 bananas on finishing the map
- Ranked]]
helpText[5] = [[Spectate mode, While spectating other players you can see their keystrokes.
This is useful when learning how to bunnyhop, for you can watch others who are better than you.]]

surface.CreateFont("bhopJoinInfoFont",{
	font = "Roboto",
	size = 22,
	weight = 500,
})

local models = {"models/Humans/Group01/Male_05.mdl","models/Humans/Group02/male_02.mdl","models/Humans/Group03/male_07.mdl"
,"models/Humans/Charple01.mdl",
 "models/Combine_Scanner.mdl"}
local logoMat = Material("excl/vgui/bananaLogo.png");
local btnWide = 180;
local marginX = (ScrW()-(btnWide*5))/6
local close=false;
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

		draw.SimpleText("SELECT YOUR DIFFICULTY","BHOPDifficultyHeader",marginX,marginX,COLOR_WHITE,0,0);
		if close then

			draw.SimpleText("//CLOSE","BHOPDifficultyHeader",w-marginX,marginX, gui.MouseX() > self:GetWide()-marginX-300 and gui.MouseY() < (ScrH()/2 - 512/2 - 74 + 70) and COLOR_WHITE or Color(200,200,200),2,0);
		end
	end

	local info
	local pnl
	for i=1,(#BHOP.Difficulties)+1 do
		pnl=vgui.Create("Panel",joinFrame)
		pnl:SetSize(btnWide,40+btnWide)
		pnl:SetPos(marginX*i + (i-1)*btnWide,ScrH()/2 -pnl:GetTall()/2);

		local btn = vgui.Create("esButton",pnl);
		btn:SetPos(0,pnl:GetTall()-40);
		btn:SetSize(btnWide,40);
		btn.OnMouseReleased = function(self)
			if i <= #BHOP.Difficulties and LocalPlayer():HasCompletedDifficulty(BHOP.Difficulties[i]) then
				hasAlreadyCompleted(i)
			else
				RunConsoleCommand("bhop_requestspawn",i)
				BHOP.DebugPrint("Requesting spawn on difficulty: "..((BHOP.Difficulties[i] and BHOP.Difficulties[i].name) or "Spectator"))
			end

			joinFrame:Remove()
		end
		btn.OnCursorEntered = function(self)
			self.Hover = true
			info:SetText(helpText[i])
			info:SizeToContents()
			timer.Simple(0,function()
				if not IsValid(info) then return end
				info:SetPos(marginX,pnl.y + pnl:GetTall() + marginX);
			end)
		end
		btn.OnCursorExited = function(self)
			self.Hover = false
			info:SetText("Hover over one of the difficulties to view more information.")
			info:SizeToContents()
			timer.Simple(0,function()
				if not IsValid(info) then return end
				info:SetPos(marginX,pnl.y + pnl:GetTall() + marginX);
			end)
		end
		btn:SetText(i == 1 and "Easy" or i == 2 and "Normal" or i == 3 and "Hard" or i == 4 and "Nightmare" or i == 5 and "Spectator mode");

		local mdl = vgui.Create("DModelPanel",pnl);
		mdl:SetSize(btnWide,btnWide);
		mdl:SetPos(0,0);
		mdl:SetModel(models[i]);
		mdl.LayoutEntity = function() end
		if i <= #BHOP.Difficulties then
			mdl:SetLookAt(Vector(0,0,60));
			mdl:SetCamPos(Vector(20,0,58));
		else
			mdl:SetLookAt(Vector(0,0,0));
			mdl:SetCamPos(Vector(30,0,0));
		end
	end

	info = Label("Hover over one of the difficulties to view more information.",joinFrame);
	info:SetFont("BHOPDifficultyTeamInfo");
	info:SetColor(COLOR_WHITE);
	info:SizeToContents()
	timer.Simple(0,function()
		if not IsValid(info) then return end
		info:SetPos(marginX,pnl.y + pnl:GetTall() + marginX);
	end)

	joinFrame:MakePopup();

	close=true
end
concommand.Add("bhop_open_difficulty",openSpawnSelection)
hook.Add("Initialize","BHOP.OpenDifficultyOnJoin",openSpawnSelection)
local canRemove = false
