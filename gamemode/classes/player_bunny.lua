DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.DisplayName			= "Bunny"
PLAYER.WalkSpeed 			= 250;
PLAYER.RunSpeed				= 250;
PLAYER.CrouchedWalkSpeed 	= (85/250)
PLAYER.JumpPower 			= 280
PLAYER.CanUseFlashlight 	= true;
PLAYER.TeammateNoCollide	= false;		-- Do we collide with teammates or run straight through them
PLAYER.AvoidPlayers			= false;

if SERVER then
	util.AddNetworkString("BHOP.SyncHullSize");

	function PLAYER:Loadout()
		if self.Player:ESIsRankOrHigher("operator") then
			self.Player:Give("bhop_mapconfig")
		end
		self.Player:Give(self.Player:ESGetMeleeWeaponClass());
		self.Player:Give( "weapon_nothing" );
		self.Player:SelectWeapon("weapon_nothing")
		self.Player:SetAvoidPlayers(false);

		self.Player:SetHull( Vector( -16, -16, 0 ), Vector( 16, 16, 60 ) )
		self.Player:SetViewOffset(Vector(0,0,60))
		self.Player:SetHullDuck(Vector(-16,-16,0), Vector( 16, 16, 44 ))
		self.Player:SetViewOffsetDucked(Vector(0,0,44))

		net.Start("BHOP.SyncHullSize");
		net.Send(self.Player);
	end
else
	net.Receive("BHOP.SyncHullSize",function()
		timer.Simple(0,function()
			ply=LocalPlayer()
			ply:SetHull( Vector( -16, -16, 0 ), Vector( 16, 16, 60 ) )
			ply:SetViewOffset(Vector(0,0,60))
			ply:SetHullDuck(Vector(-16,-16,0), Vector( 16, 16, 44 ))
			ply:SetViewOffsetDucked(Vector(0,0,44))
		end)
	end)
end
function PLAYER:SelectModel()
	self.Player:ESSetModelToActive();

	local c = self.Player:GetDifficulty().color;
	c = Vector(c.a/255,c.g/255,c.b/255);
	self.Player:SetWeaponColor(c);
	self.Player:SetPlayerColor(c)
	self.Player:SetNoDraw(false);
end
player_manager.RegisterClass( "player_bunny", PLAYER, "player_default" )
