DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.DisplayName			= "Spectator"

function PLAYER:Loadout()
	self.Player:StripWeapons();
	self.Player:SetAvoidPlayers(false);
end
function PLAYER:SelectModel()
	self.Player:SetNoDraw(true);
end
player_manager.RegisterClass( "player_spec", PLAYER, "player_default" )
