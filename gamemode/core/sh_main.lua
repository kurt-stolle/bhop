BHOP.Ranks={}

local i=0
local function defineRank(name,icon)
	local pts;
	if i == 0 then
		pts=0
	else
		pts=(40 * math.pow(i,2) + 360 * i)
	end

	i=i+1

  BHOP.Ranks[i]={
    name=name,
    icon=Material(icon),
    points=pts
  }
end
defineRank( "Beginner","icon16/award_star_bronze_1.png")
defineRank( "Learning","icon16/award_star_bronze_2.png")
defineRank( "Rookie","icon16/award_star_bronze_3.png")
defineRank( "Casual","icon16/award_star_silver_1.png")
defineRank( "Decent","icon16/award_star_silver_2.png")
defineRank( "Good","icon16/award_star_silver_3.png")
defineRank( "Addict","icon16/award_star_gold_1.png")
defineRank( "Wizard","icon16/award_star_gold_2.png")
defineRank( "Hacker","icon16/award_star_gold_3.png")

local function fixvalue(v)
	if string.len(tostring(v)) < 2 then
		return "0"..v;
	end
	return v;
end

function BHOP:GetTimeLeft()
	local str = tostring((40*60) - (CurTime() - (GetGlobalString("timeStart") or 0)))

	local build = "";
	if string.find(str,"%.") then
		local parts = string.Explode(".",str);
		build = fixvalue(math.floor(tonumber(parts[1])/60))..":"..fixvalue(tonumber(parts[1]) - math.floor(tonumber(parts[1])/60)*60)
		build = build..":"..fixvalue(string.Left(parts[2],2));
	else
		build = fixvalue(math.floor(tonumber(str)/60))..":".. fixvalue(tonumber(str) - math.floor(tonumber(str)/60)*60)..":00"
	end
	return build
end

local PLAYER = FindMetaTable("Player");
function PLAYER:GetTime()
	return CurTime() - (self.StartTime or CurTime());
end

function PLAYER:GetTimeString()
	local str = tostring(self:GetTime())

	local build = "";
	if string.find(str,"%.") then
		local parts = string.Explode(".",str);
		build = fixvalue(math.floor(tonumber(parts[1])/60))..":"..fixvalue(tonumber(parts[1]) - math.floor(tonumber(parts[1])/60)*60)
		build = build..":"..fixvalue(string.Left(parts[2],2));
	else
		build = fixvalue(math.floor(tonumber(str)/60))..":".. fixvalue(tonumber(str) - math.floor(tonumber(str)/60)*60)..":00"
	end
	return build
end

function PLAYER:GetPoints()
	return self:GetNWInt("points",0);
end

hook.Add( "ShouldCollide", "exclNoPlayersCollide", function(ent1,ent2)
	if ( ent1:IsPlayer() and ent2:IsPlayer() and (ent1:Team() == ent2:Team()) ) then
		return false;
	end
end)

local CSSWeps = {"weapon_ak47",
"weapon_aug",
"weapon_awp",
"weapon_c4",
"weapon_deagle",
"weapon_elite",
"weapon_famas",
"weapon_fiveseven",
"weapon_g3sg1",
"weapon_galil",
"weapon_glock",
"weapon_m249",
"weapon_m3",
"weapon_m4a1",
"weapon_mac10",
"weapon_mp5navy",
"weapon_p228",
"weapon_p90",
"weapon_scout",
"weapon_sg550",
"weapon_sg552",
"weapon_tmp",
"weapon_ump45",
"weapon_usp",
"weapon_xm1014",
};
hook.Add("Initialize","bhopCSSWeps",function()
	for _,v in pairs(CSSWeps)do
		weapons.Register( {Base = "bhop_gun"}, string.lower(v), false);
	end
end);

function BHOP:PlayerNoClip(p)
	return p:ESIsRankOrHigher("operator");
end

local playersCompleted = {}; -- so people can't rejoin and avoid their 'difficulty ban'
function PLAYER:HasCompletedDifficulty(diff)
	if not playersCompleted[tonumber(self:UniqueID())] or not playersCompleted[tonumber(self:UniqueID())][diff] then
		return false;
	end

	return true;
end

function PLAYER:CompleteDifficulty(diff)
	if not playersCompleted[tonumber(self:UniqueID())] then
		playersCompleted[tonumber(self:UniqueID())] = {};
	end
	playersCompleted[tonumber(self:UniqueID())][diff] = true;
end
