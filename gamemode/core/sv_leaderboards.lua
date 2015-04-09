-- leaderboards sv


local PLAYER = FindMetaTable("Player");
local nextUpdate = 0;
function PLAYER:HandleLeaderboards()
	if  self.notAllowedLeaderboards or self:GetDifficulty().key <= 1 then return end

	local time = CurTime() - (self.StartTime or 0);

	ES.DBQuery("INSERT INTO bhop_leaderboards SET steamid = '"..self:SteamID().."', time = "..tonumber(time)..", map = '"..game.GetMap().."', difficulty = "..self:GetDifficulty().key..", name = '"..ES.DBEscape(self:Nick()).."';")

	if not self.BestTime or self.BestTime > tonumber(time) then
		self:SendBest(tonumber(time));
		nextUpdate = 0;
	end
end

util.AddNetworkString("bhopSendBest");
function PLAYER:SendBest(best)
	if not best and not self.alreadySent then

	ES.DBQuery("SELECT MIN(time) AS best FROM bhop_leaderboards WHERE steamid = '"..self:SteamID().."' AND map = '"..game.GetMap().."' LIMIT 1;",function(dt)
		if IsValid(self) and dt and dt[1] and dt[1].best then
			net.Start("bhopSendBest");
			net.WriteString(tostring(dt[1].best));
			net.Send(self);
			self.BestTime = tonumber(dt[1].best)
			self.alreadySent = true;
		end
	end);
	elseif best then
		net.Start("bhopSendBest");
		net.WriteString(tostring(best or self.BestTime or 0));
		net.Send(self);

		self.BestTime = best;
	end
end

local maps = {};
util.AddNetworkString("bhopSendMaps");
concommand.Add("bhop_requestmaps",function(p)
	if not IsValid(p) then return end

	net.Start("bhopSendMaps");
	net.WriteTable(maps);
	net.Send(p);
end)
hook.Add("ESDatabaseReady","bhopLoadMapsList",function()
	print("Loading maps list...")

	ES.DBQuery("SELECT DISTINCT map FROM bhop_leaderboards;",function(res)
		if res and res[1] then
			maps = {};
			for k,v in pairs(res)do
				maps[#maps+1] = v.map;
			end
		end
	end);
end);

local peopleStats = {};
util.AddNetworkString("bhopSendStats");
concommand.Add("bhop_requeststats",function(p,c,a)
	if not IsValid(p) then return end

	local map = ES.DBEscape(a[1] or game.GetMap());
	if peopleStats and peopleStats[p:UniqueID()] and peopleStats[p:UniqueID()][map] and nextUpdate > CurTime() then
		ES.DebugPrint("Sending cached stats");
		net.Start("bhopSendStats");
		net.WriteTable(peopleStats[p:UniqueID()][map]);
		net.Send(p);

		return;
	end

	if nextUpdate < CurTime() then
		nextUpdate = CurTime() + 300;
	end

	if !peopleStats[p:UniqueID()] then peopleStats[p:UniqueID()] = {} end
	peopleStats[p:UniqueID()][map] = {};
	ES.DBQuery("SELECT time,fails,difficulty FROM bhop_leaderboards WHERE steamid = '"..p:SteamID().."' AND map = '"..map.."' ORDER BY time ASC LIMIT 15;",function(res)
		if res and res[1] and IsValid(p) then
			peopleStats[p:UniqueID()][map] = res;
		end
		if IsValid(p) then
			net.Start("bhopSendStats");
			net.WriteTable(peopleStats[p:UniqueID()][map]);
			net.Send(p);
		end
	end);
end)

local boards = {};
local requesters = {};
util.AddNetworkString("bhopSendBoards");
concommand.Add("bhop_requestboards",function(p,c,a)
	if not IsValid(p) then return end

	local map = ES.DBEscape(a[1] or game.GetMap());

	if not requesters[map] then requesters[map] = {} end
	requesters[map][#requesters[map] + 1] = p;

	if boards and boards[map] and nextUpdate > CurTime() then
		ES.DebugPrint("Sending cached boards");
		net.Start("bhopSendBoards");
		net.WriteString(map);
		net.WriteTable(boards[map]);
		net.Send(p);

		return;
	end

	if nextUpdate < CurTime() then
		nextUpdate = CurTime() + 300;
	end

	if !boards[map] then
		boards[map] = {}
		boards[map][2] = {};
		boards[map][3] = {};
		boards[map][4] = {};
	end

	ES.DBQuery("SELECT steamid, name, MIN(time) AS time FROM bhop_leaderboards WHERE difficulty = 2 AND map = '"..map.."' GROUP BY steamid ORDER BY time ASC LIMIT 10;",function(res)
		if res and res[1] then
			boards[map][2] = res;
		end

		ES.DBQuery("SELECT steamid, name, MIN(time) AS time FROM bhop_leaderboards WHERE difficulty = 3 AND map = '"..map.."' GROUP BY steamid ORDER BY time ASC LIMIT 10;",function(res)
			if res and res[1] then
				boards[map][3] = res;
			end

			ES.DBQuery("SELECT steamid, name, MIN(time) AS time FROM bhop_leaderboards WHERE difficulty = 4 AND map = '"..map.."' GROUP BY steamid ORDER BY time ASC LIMIT 10;",function(res)
				if res and res[1] then
					boards[map][4] = res;
				end

				net.Start("bhopSendBoards");
				net.WriteString(map);
				net.WriteTable(boards[map]);
				net.Send(requesters[map]);
			end);
		end);


	end);
end)
