COLOR_WHITE = COLOR_WHITE or Color(255,255,255);

COLOR_BLACK = COLOR_BLACK or Color(0,0,0,255);
local colorKeyPressed = Color(20,20,20);
local colorKeyMain = Color(40,40,40);
local colorKeyOverlay = Color(255,255,255,10);
local colorKeyGloss = Color(255,255,255,2);
local function drawKey(x,y,w,h,text,pressed)
	if pressed then
		x = x+2;
		y = y+2;
	end

	local color = table.Copy(ES.GetColorScheme());
	color.a = 50;

	draw.RoundedBox(4,x,y,w,h,COLOR_BLACK)
	if !pressed then
		draw.RoundedBox(4,x+1,y+1,w,h,COLOR_BLACK)
		draw.RoundedBox(4,x+2,y+2,w,h,COLOR_BLACK)

		draw.RoundedBox(4,x+1,y+1,w-2,h-2,colorKeyMain)
		draw.RoundedBox(4,x+2,y+2,w-4,h-4,colorKeyOverlay)

		draw.RoundedBox(2,x+2,y+2,w-4,(h-4)/2,colorKeyGloss)
	else
		draw.RoundedBox(4,x+1,y+1,w-2,h-2,colorKeyPressed)
		draw.RoundedBox(2,x+2,y+2,w-4,h-4,colorKeyOverlay)
		draw.RoundedBox(2,x+2,y+2,w-4,h-4, color)
		draw.RoundedBox(2,x+2,y+2,w-4,(h-4)/2,colorKeyGloss)
	end


	draw.SimpleText(text,"bhopKeyFontShadow",x+w/2,y+h/2,COLOR_BLACK,1,1)
	draw.SimpleText(text,"bhopKeyFont",x+w/2,y+h/2,Color(220,220,220),1,1)
end
local vel = 0;
local function drawInfoBox(x,y,w,h,text,info,lightup)
	text = string.upper(text);

	draw.RoundedBox(2,x,y,w,h,colorKeyMain)
	draw.RoundedBox(2,x+1,y+1,w-2,h-2,colorKeyOverlay);
	if lightup then
		local color = table.Copy(ES.GetColorScheme());
		color.a = lightup*50;

		draw.RoundedBox(2,x+2,y+2,w-4,h-4,color);
	end
	draw.SimpleText(text,"ESDefault.Shadow",x+6,y+2,COLOR_BLACK)
	draw.SimpleText(text,"ESDefault",x+6,y+2,Color(220,220,220))
	draw.SimpleText(info,"bhopInfo",x+5,y+13,COLOR_WHITE)
end

local plKeys = {};

local margin = 10;

local function getNextRankPoints()
	local lastrank=#BHOP.Ranks
  for _i=lastrank,1,-1 do
    if LocalPlayer():GetPoints() >= BHOP.Ranks[_i].points then
      break
    end
    lastrank=_i
  end
  return BHOP.Ranks[lastrank].points
end
local function getDeltaRankPoints()
	return LocalPlayer():GetPoints() - LocalPlayer():GetRank().points
end
local function getDeltaNextRankPoints()
	return getNextRankPoints()-LocalPlayer():GetRank().points;
end
function BHOP:HUDPaint()
	local watch = LocalPlayer();
	if LocalPlayer():Team() == TEAM_SPECTATOR then
		watch = (LocalPlayer():GetObserverTarget() or LocalPlayer())
	end
	if !IsValid(watch) then return end

	local xKeyboard = 20;

	drawKey(xKeyboard,ScrH()-20-40,80,40,"crouch",											(watch == LocalPlayer() and watch:KeyDown(IN_DUCK)) 		or (plKeys[watch:UniqueID()] and plKeys[watch:UniqueID()][IN_DUCK]) 		)
	drawKey(xKeyboard+80+margin,ScrH()-20-40,40,40,"A",										(watch == LocalPlayer() and watch:KeyDown(IN_MOVELEFT)) 	or (plKeys[watch:UniqueID()] and plKeys[watch:UniqueID()][IN_MOVELEFT]) 	)
	drawKey(xKeyboard+80+margin+40+margin,ScrH()-20-40-margin-40,40,40,"W",					(watch == LocalPlayer() and watch:KeyDown(IN_FORWARD)) 		or (plKeys[watch:UniqueID()] and plKeys[watch:UniqueID()][IN_FORWARD]) 		)
	drawKey(xKeyboard+80+margin+40+margin,ScrH()-20-40,40,40,"S",							(watch == LocalPlayer() and watch:KeyDown(IN_BACK)) 		or (plKeys[watch:UniqueID()] and plKeys[watch:UniqueID()][IN_BACK]) 		)
	drawKey(xKeyboard+80+margin+40+margin+40+margin,ScrH()-20-40,40,40,"D",					(watch == LocalPlayer() and watch:KeyDown(IN_MOVERIGHT)) 	or (plKeys[watch:UniqueID()] and plKeys[watch:UniqueID()][IN_MOVERIGHT]) 	)
	drawKey(xKeyboard+80+margin+40+margin+40+margin+40+margin,ScrH()-20-40,220,40,"jump",	(watch == LocalPlayer() and watch:KeyDown(IN_JUMP))			or (plKeys[watch:UniqueID()] and plKeys[watch:UniqueID()][IN_JUMP]) 		)

	local p = LocalPlayer();
	for k,v in pairs(team.GetPlayers(TEAM_BUNNY))do
		if IsValid(v) and (v:GetPos()+Vector(0,0,40)):Distance(p:EyePos()) < 1000 then
			local ps = (v:GetPos() + Vector(0,0,70)):ToScreen();

			draw.SimpleTextOutlined(v:Nick(),"DermaDefaultBold",ps.x,ps.y,Color(255,255,255,255 - 255 * (v:GetPos():Distance(p:EyePos())/1000)),1,1,1,Color(0,0,0,255 - 255 * (v:GetPos():Distance(p:EyePos())/500)));
		end
	end

	vel = Lerp(0.2,vel,watch:GetVelocity():Length())
	drawInfoBox(ScrW()-20-80,ScrH()-20-40,80,40,"Velocity",math.floor(vel),math.floor(vel)/700);
	drawInfoBox(ScrW()-20-80-20-120,ScrH()-20-40,120,40,"Time",watch:GetTimeString());

	if watch == LocalPlayer() then
		local progress = math.Clamp((getDeltaRankPoints()/getDeltaNextRankPoints())*(200-2),0,(200-2));
		local x,y = ScrW()-20-80-20-120-20-200,ScrH()-20-40;
		drawInfoBox(x,y,200,40,"","");

		if progress > 8 then
			local color = table.Copy(ES.GetColorScheme());
		color.a = 50;

			draw.RoundedBox(0,x+1,y+40-3,progress,2,color);
		end
		draw.SimpleText("CURRENT RANK: "..string.upper(watch:GetRank().name),"ESDefault.Shadow",x+6,y+2,COLOR_BLACK)
		draw.SimpleText("CURRENT RANK: "..string.upper(watch:GetRank().name),"ESDefault",x+6,y+2,Color(220,220,220));
		draw.SimpleText(getDeltaRankPoints().."/"..getDeltaNextRankPoints().." Points","bhopInfo",x+5,y+13,COLOR_WHITE)
	end
end
net.Receive("bhKPrs",function()
	local key = net.ReadInt(16);
	local pl = net.ReadEntity();

	if not IsValid(pl) then return end
	if not plKeys[pl:UniqueID()] then plKeys[pl:UniqueID()] = {} end

	plKeys[pl:UniqueID()][key] = true;

	if key == IN_JUMP then
		timer.Simple(0.3,function()
			if plKeys and IsValid(pl) and pl:UniqueID() and key and plKeys[pl:UniqueID()] then
				plKeys[pl:UniqueID()][key] = false;
			end
		end)
	end
end)
local hud = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"}
function BHOP:HUDShouldDraw(name)
   for k, v in ipairs(hud) do
      if name == v then return false end
   end

   return true
end
net.Receive("BHOP.TransmitKey",function()
	local key = net.ReadInt(16);
	local pl = net.ReadEntity();

	if not IsValid(pl) then return end
	if not plKeys[pl:UniqueID()] then plKeys[pl:UniqueID()] = {} end
	plKeys[pl:UniqueID()][key] = false;
end)
