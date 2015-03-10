-- sv_player

hook.Add( "KeyPress", "exSprectatorPress", function(p,l)
	if l ~= IN_SCORE and l ~= IN_FORWARD and l ~= IN_BACK and l ~= IN_LEFT and l ~= IN_RIGHT and l ~= IN_MOVELEFT and l ~= IN_SPEED and l ~= IN_MOVERIGHT and p:Team() == TEAM_SPECTATOR then
		if not p.spec then p.spec = 1 end

		if l == IN_ATTACK2 and p:GetObserverMode() == OBS_MODE_CHASE then
			p:Spectate(OBS_MODE_IN_EYE);
			return;
		elseif l == IN_ATTACK2 and p:GetObserverMode() == OBS_MODE_IN_EYE then
			p:Spectate(OBS_MODE_ROAMING);
			return;
		elseif l == IN_ATTACK2 and p:GetObserverMode() == OBS_MODE_ROAMING then
			p:Spectate(OBS_MODE_CHASE);
			return;
		end

		if p:GetObserverMode() == OBS_MODE_CHASE or p:GetObserverMode() == OBS_MODE_IN_EYE then

			p.spec = p.spec+1;
			if not IsValid(team.GetPlayers(TEAM_BUNNY)[p.spec]) then
				p.spec = 1;
			end

			local targ = team.GetPlayers(TEAM_BUNNY)[p.spec];
			if IsValid(targ) then
				if IsValid(p:GetObserverTarget()) and p:GetObserverTarget().Observers then
					table.insert(p:GetObserverTarget().Observers,p);
					for k,v in pairs(p:GetObserverTarget().Observers)do
						if p == v then
							table.remove(p:GetObserverTarget().Observers,k);
							break;
						end
					end
				end
				p:SpectateEntity(targ);
				table.insert(targ.Observers,p);
			end

		end
	end
end)
function BHOP:OnPlayerHitGround(ply)
	local plt = ply:GetGroundEntity()

	if plt:IsWorld() then
		ply.last_plt = nil
	end

	if plt:GetClass() == "func_door" then
		if ply:GetGroundEntity():EntIndex() == ply.last_plt and ply:GetDifficulty().killOnBlock then
			ply:Kill()
			ply.last_plt = nil
			return
		end
			ply.last_plt = plt:EntIndex()

		local time = ply:GetDifficulty().timeOnBlock
		timer.Simple(time, function()
			plt:SetOwner(ply)
			if ply:GetDifficulty().killOnBlock and ply:GetGroundEntity():EntIndex() == ply.last_plt then
				ply:Kill()
			end
		end)

		timer.Simple(time+0.4, function()
			plt:SetOwner(nil)
		end)

		ply:AddPoints(1)

	end
end
function BHOP:PlayerShouldTakeDamage()
	return false
end
function BHOP:PlayerSetModel(p)
	player_manager.RunClass(p,"SelectModel")
end
util.AddNetworkString("bhPlayerStarted");
util.AddNetworkString("bhPlayerSynchActive");
function BHOP:ShowHelp(p)
end
function BHOP:ShowTeam(p)
end
function BHOP:ShowSpare1(p)
end
function BHOP:PlayerDeath(p)
end
function BHOP:PlayerSpawn(p)
	if p:Team() == TEAM_SPECTATOR then
		player_manager.SetPlayerClass(p,"player_spec")

		hook.Call("PlayerSpawnAsSpectator", BHOP, p)

		player_manager.OnPlayerSpawn(p)
		player_manager.RunClass(p,"Spawn")

		return;
	end

	p.HasReceivedBananas = {};
	p.MailboxesClaimed = 0;

	player_manager.SetPlayerClass(p,"player_bunny")

	p.StartTime = CurTime();

	p:SetDeaths(0);
	p:UnSpectate();

	p:SendBest()

	player_manager.OnPlayerSpawn(p)
	player_manager.RunClass(p,"Spawn")

	hook.Call("PlayerLoadout",BHOP,p)
	hook.Call("PlayerSetModel",BHOP,p)

	BHOP.DebugPrint("Player spawned: "..p:Nick())
end
util.AddNetworkString("bhKPrs")
hook.Add("KeyPress","bhopHandlePeopleKeys",function(p,key)
	if p.Observers and key == IN_FORWARD or key == IN_MOVELEFT or key == IN_BACK or key == IN_MOVERIGHT or key == IN_DUCK or key == IN_JUMP then
		net.Start("bhKPrs");
		net.WriteInt(key,16);
		net.WriteEntity(p);
		net.Send(p.Observers);
	end
end);
util.AddNetworkString("BHOP.TransmitKey")
hook.Add("KeyRelease","bhopHandlePeopleKeysRelease",function(p,key)
	if p.Observers and key == IN_FORWARD or key == IN_MOVELEFT or key == IN_BACK or key == IN_MOVERIGHT or key == IN_DUCK then
		net.Start("BHOP.TransmitKey");
		net.WriteInt(key,16);
		net.WriteEntity(p);
		net.Send(p.Observers);
	end
end);

local PLAYER = FindMetaTable("Player");

util.AddNetworkString("bhopHasAlreadyCompleted")
concommand.Add("bhop_requestspawn",function(p,c,a)
	local diff = tonumber(a[1] or 0);
	if not BHOP.Difficulties[diff] and diff~=0 then return end

	if diff == 0 then
		p:SetTeam(TEAM_SPECTATOR);
		p:Spawn();
	else
		p:SetTeam(diff);
		p:Spawn();
	end
end)
BHOP.blockGroups = {};
BHOP.blocks = {};

hook.Add("InitPostEntity","bhopStartMapTimer",function()
	SetGlobalFloat("timeStart",CurTime());
end)


function BHOP:IsSpawnpointSuitable(pl,spp,bms)
	return true;
end

function BHOP:AllowPlayerPickup( p, entity)
	return false;
end
function BHOP:PlayerCanHearPlayersVoice()
	return true
end

function BHOP:PlayerRequestTeam( ply, teamid )
	return;
end

function BHOP:PlayerInitialSpawn(p)
	p.Observers = {};
	p:SetTeam(TEAM_SPECTATOR)

	ES.DBQuery("SELECT points FROM bhop_player WHERE steamid = '"..p:SteamID().."';",function(dt)
		if not IsValid(p) then
			return
		elseif not dt or not dt[1] or not dt[1].points then
			ES.DBQuery("INSERT INTO bhop_player SET steamid = '"..p:SteamID().."', points = 0;");
			p:ESSetNetworkedVariable("bhop_points",0)
			return
		end
		p:ESSetNetworkedVariable("bhop_points",dt[1].points);
	end)
end

function BHOP:PlayerCanPickupWeapon(p,e)
	return true;
end


local undroppableWeapons = {"excl_crowbar", "bhop_mapconfig", "weapon_nothing"}
concommand.Add("bhop_dropweapon", function( ply, cmd, args )
	local weapon = ply:GetActiveWeapon()
	if IsValid(weapon) then
		for k, v in pairs(undroppableWeapons) do
			if v == weapon:GetClass() or (weapon.Base and v == weapon.Base) then
				return false
			end
		end

		ply:DropWeapon(weapon)
	end
end)

concommand.Remove("changeteam");
