-- banana dispenser.
AddCSLuaFile();

ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true
 
function ENT:SetAutomaticFrameAdvance( bUsingAnim )
	self.AutomaticFrameAdvance = bUsingAnim
end

if SERVER then
	local models = {"models/player/sam.mdl","models/player/venom.mdl","models/jessev92/player/ww2/hd_hitler_v3.mdl","models/Barney.mdl","models/breen.mdl","models/Eli.mdl","models/BHOPan_high.mdl","models/Kleiner.mdl",
"models/monk.mdl","models/odessa.mdl"}

	function ENT:Initialize()
			self:SetModel(table.Random(models))
			self:SetHullType( HULL_HUMAN )
			self:SetHullSizeNormal( )
			self:SetNPCState( NPC_STATE_SCRIPT )
			self:SetSolid(  SOLID_BBOX )
			self:CapabilitiesAdd( CAP_ANIMATEDFACE + CAP_TURN_HEAD ) 
			self:SetUseType( SIMPLE_USE )
			self:DropToFloor()
		 
			self:SetMaxYawSpeed( 45 )
			self.mul = 1.4;

			self.peopleReported = {};

	end

	util.AddNetworkString("SPawnChangeOnFinished")
	util.AddNetworkString("BHPlayerFinished")
	util.AddNetworkString("BHPlayerGiveBnns")
	function ENT:Claim(e)
		if e and IsValid(e) and e:IsPlayer() and e:GetObserverMode() == OBS_MODE_NONE and not table.HasValue(e.HasReceivedBananas,self) then
			table.insert(e.HasReceivedBananas,self);
			
			local bnns = 0;
			if !e:HasCompletedDifficulty(e:GetDifficulty()) and not (self.peopleReported and self.peopleReported[e:UniqueID()] and self.peopleReported[e:UniqueID()][e:GetDifficulty()]) then
				if e:GetDifficulty() == 1 then
					bnns = 5;
				elseif e:GetDifficulty() == 2 then
					bnns = 10;
				elseif e:GetDifficulty() == 3 then
					bnns = 15;
				elseif e:GetDifficulty() == 4 then
					bnns = 20;
				end
				e:ESGiveBananas(math.Round(bnns*self.mul));

				if self.mul ~= 1 then
					self.mul = 1;
				end
			end

			if not self.peopleReported then
				self.peopleReported = {};
			end

			if not self.peopleReported[e:UniqueID()] then
				self.peopleReported[e:UniqueID()] = {}
			end
			self.peopleReported[e:UniqueID()][e:GetDifficulty()] = true;

			
			local pts = 0;
			if e:GetDifficulty() == 1 then
				pts = 2;
			elseif e:GetDifficulty() == 2 then
				pts = 4;
			elseif e:GetDifficulty() == 3 then
				pts = 8;
			elseif e:GetDifficulty() == 4 then
				pts = 16;
			end
			e:AddPoints(pts)

			net.Start("BHPlayerGiveBnns");
			net.WriteString(tostring(pts));
			net.WriteString(tostring(math.Round(bnns*self.mul)));			
			net.Send(e);

			e.MailboxesClaimed = e.MailboxesClaimed + 1;
			if e.MailboxesClaimed >= #ents.FindByClass("bhop_dispenser") then

				e:CompleteDifficulty(e:GetDifficulty());
				if e:GetDifficulty() > 1 then
					e:HandleLeaderboards()
				end

				net.Start("SPawnChangeOnFinished");
				net.Send(e);

				net.Start("BHPlayerFinished");
				net.WriteEntity(e);
				net.WriteInt(e:GetDifficulty(),4);
				net.WriteString(e:GetTimeString());
				net.Broadcast();
			end
		end
	end

	function ENT:StartTouch(e)
		if SERVER and IsValid(e) and e.IsPlayer and e:IsPlayer() then
			self:Claim(e);
		end
	end

	function ENT:AcceptInput( name,_,e )	
		if SERVER and name == "Use" and e:IsPlayer() then
			self:Claim(e);
		end
	end
end

if CLIENT then
	local mat = Material("exclserver/bananas.png");

	--[[hook.Add( "PreDrawHalos", "bhopMailboxHalo", function()
		for _, ent in pairs( ents.FindByClass("bhop_dispenser") ) do
			if ent:GetPos():Distance(LocalPlayer():EyePos()) < 1000 then
				halo.Add( {ent}, Color(255,204,0), 0.5, 0.5, 0.5,true,false)
			end
		end
	end )]]
	local rotations = {}
	local posx = {}
	local posy = {}
	local function drawRotatingBanana(id,xBase,yBase,r,speed,rotatespeed,scale)
		scale = scale or 1;
		rotations[id] = (rotations[id] or 0) + rotatespeed;
		posx[id] = math.sin(CurTime() * speed) * r;
		posy[id] = math.cos(CurTime() * speed) * r;
		surface.DrawTexturedRectRotated(xBase + posx[id],yBase + posy[id],16*scale,16*scale,rotations[id])
	end

	surface.CreateFont("bhopMailboxHelper",{
		font = "Roboto";
		size = 80;
	})

	surface.CreateFont("bhopMailboxHelperSmall",{
		font = "Roboto";
		size = 28;
		italic = true;
	})
	surface.CreateFont("bhopMailboxHelperShadow",{
		font = "Roboto";
		size = 80;
		blursize = 4;
	})

	surface.CreateFont("bhopMailboxHelperSmallShadow",{
		font = "Roboto";
		size = 28;
		blursize = 2;
		italic = true;
	})

	hook.Add("PostDrawTranslucentRenderables", "bhopMailboxTexts", function()
		for _, ent in pairs( ents.FindByClass("bhop_dispenser") ) do
			local ang = LocalPlayer():EyeAngles();
			ang:RotateAroundAxis(ang:Up(),270)
			ang:RotateAroundAxis(ang:Forward(),90)

			ang:RotateAroundAxis(ang:Up(),math.cos(CurTime()*0.5) * 5)
			cam.Start3D2D( ent:GetPos() + Vector(0,0,60), ang, 0.15 + math.sin(RealTime()) * 0.05 )
				surface.SetDrawColor(COLOR_WHITE);
				surface.SetMaterial(mat);
				drawRotatingBanana(1,0,0,90,1,0.8,2)
				drawRotatingBanana(2,-10 + (math.sin(CurTime() * .3) * 150),-20,50,2,2)
				drawRotatingBanana(5,-20 + (math.sin(CurTime() * .4) * 20),-20,150,2,9)
				drawRotatingBanana(3,120,20,100,3,6)
				drawRotatingBanana(6,-120,20,130,4,2,2)
				drawRotatingBanana(4,-40 + (math.sin(CurTime() * .6) * 50),20 + (math.cos(CurTime() * .4) * 60),120,1,3,3)
			cam.End3D2D();
			ang:RotateAroundAxis(ang:Up(), - math.cos(CurTime()*0.5) * 5)

			local dist = LocalPlayer():GetPos():Distance(ent:GetPos());

			if dist > 400 then continue end

			local alpha = 255;
			if dist > 200 then
				alpha = 255 - (dist-200)/200 * 255
			end
			cam.Start3D2D( ent:GetPos() + Vector(0,0,86), ang, 0.1)
				surface.SetFont("bhopMailboxHelper")
				local w,h = surface.GetTextSize("Claim bananas");
				w=w+20;
				h=h+30;
				draw.RoundedBox(8,-8,80,16,16,COLOR_WHITE);

				--draw.RoundedBox(2,-(w-20)/2,18,w-20,30,Color(255,152,0,alpha));
				for i=0,1 do
					draw.SimpleText("Claim bananas","bhopMailboxHelperShadow",0,-20,Color(0,0,0,alpha),1,1)

					draw.SimpleText("Press "..string.upper(input.LookupBinding("+use") or "UNBOUND").." on or tag this NPC","bhopMailboxHelperSmallShadow",0,32,Color(0,0,0,alpha),1,1)
				end
			
				draw.SimpleText("Claim bananas","bhopMailboxHelper",0,-20,Color(255,255,255,alpha),1,1)

				draw.SimpleText("Press "..string.upper(input.LookupBinding("+use") or "UNBOUND").." on or tag this NPC","bhopMailboxHelperSmall",0,32,Color(255,255,255,alpha),1,1)


			cam.End3D2D();
			


		end
	end  )

	

	COLOR_WHITE = COLOR_WHITE or Color(255,255,255);
	COLOR_BLACK = COLOR_BLACK or Color(0,0,0);
	function ENT:Draw()
		self:DrawModel();
	end

	net.Receive("BHPlayerGiveBnns",function()
		local pts= net.ReadString();
		local bnns = net.ReadString();

		if pts and bnns then
			ES.ChatAddText("global",Color(255,255,255),"You have claimed ",Color(102,255,51),pts,Color(255,255,255)," points and ",Color(102,255,51),bnns,Color(255,255,255)," bananas.");
		end
	end)
	net.Receive("BHPlayerFinished",function()
		local ply = net.ReadEntity();
		local diff = net.ReadInt(4);
		local time = net.ReadString();
		if ply == LocalPlayer() then
			ply:CompleteDifficulty(diff)
		end

		if IsValid(ply) and diff and time then
			if diff == 1 then
				diff = "easy";
			elseif diff == 2 then
				diff = "normal";
			elseif diff == 3 then
				diff = "hard";
			elseif diff == 4 then
				diff = "nightmare";
			end

			ES.ChatAddText("global",Color(102,255,51),ply:Nick(),Color(255,255,255)," has finished the map on ",Color(102,255,51),diff,Color(255,255,255)," mode in ",Color(102,255,51),time,Color(255,255,255)," minutes!");
		end
	end)

end