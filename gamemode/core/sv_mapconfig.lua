-- sv_mapconfig

local mapconfig = {}
hook.Add("InitPostEntity","bhopLoadMapconfig",function()
	if not file.Find("bhop/npcs/"..game.GetMap()..".txt","DATA") then return end

	mapconfig = (file.Read("bhop/npcs/"..game.GetMap()..".txt","DATA") or util.TableToJSON({}));
	mapconfig = util.JSONToTable(mapconfig);

	for k,v in pairs(mapconfig)do
		local mailbox = ents.Create("bhop_dispenser");
		mailbox:SetPos(v.pos);
		mailbox:SetAngles(v.ang);
		mailbox:Spawn();
	end

	local tbl = (file.Read("bhop/blocks/"..game.GetMap()..".txt","DATA") or util.TableToJSON({{},{}}));
	tbl = util.JSONToTable(tbl);

	BHOP.blockGroups = tbl[1];
	for k,v in pairs(tbl[2])do
		BHOP.blocks[k+game.MaxPlayers()] = v;
	end

end)

concommand.Add("bhop_flushnpcs",function(p)
	if IsValid(p) and p:IsSuperAdmin() and p:GetEyeTrace().HitPos then
		mapconfig = {};
		file.Write( "bhop/npcs/"..game.GetMap()..".txt",util.TableToJSON({}) );

		for k,v in pairs(ents.FindByClass("bhop_dispenser"))do
			if IsValid(v) then
				v:Remove()
			end
		end

		p:ChatPrint("All NPCs removed!");
	end
end)
concommand.Add("bhop_addnpc",function(p)
	if IsValid(p) and p:IsSuperAdmin() and p:GetEyeTrace().HitPos then
		table.insert(mapconfig,{pos = p:GetEyeTrace().HitPos, ang = p:GetAngles() + Angle(0,180,0)})
		file.Write( "bhop/npcs/"..game.GetMap()..".txt",util.TableToJSON(mapconfig) );

		local mailbox = ents.Create("bhop_dispenser");
		mailbox:SetPos(p:GetEyeTrace().HitPos);
		mailbox:SetAngles(p:GetAngles() + Angle(0,180,0));
		mailbox:Spawn();

		p:ChatPrint("NPC added!");
	end
end)

util.AddNetworkString("bhopSynchBlocks")

local request = {};
local function synchBlocks()
	net.Start("bhopSynchBlocks");
	net.WriteTable(BHOP.blockGroups)
	net.WriteTable(BHOP.blocks);
	net.Send(request);
	local t = {};
	for k,v in pairs(BHOP.blocks)do
		t[k-game.MaxPlayers()] = v;
	end
	file.Write( "bhop/blocks/"..game.GetMap()..".txt" , util.TableToJSON({BHOP.blockGroups,t}) );
end
concommand.Add("bhop_requestsynch",function(p)
	if table.HasValue(request,p) then return end
	request[#request+1] = p;
	synchBlocks();
end);

concommand.Add("bhop_addblock",function(p,c,a)
	if a and a[1] and BHOP.blockGroups[tonumber(a[1])] and IsValid(p) and p:IsSuperAdmin()
	and p:GetEyeTrace().Entity and IsValid(p:GetEyeTrace().Entity) then
		BHOP.blocks[p:GetEyeTrace().Entity:EntIndex()] = tonumber(a[1]);
		synchBlocks()
	end
end)
concommand.Add("bhop_addblockgroup",function(p,c,a)
	if IsValid(p) and p:IsSuperAdmin() and p:GetEyeTrace().HitPos then
		BHOP.blockGroups[#BHOP.blockGroups+1] = p:GetEyeTrace().HitPos;
		synchBlocks()
	end
end)
