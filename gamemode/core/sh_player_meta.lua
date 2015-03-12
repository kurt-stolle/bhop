
local PLAYER=FindMetaTable("Player")
function PLAYER:GetRank()
	local rank;
	for _i=#BHOP.Ranks,1,-1 do
			rank=BHOP.Ranks[_i]
			if self:GetPoints() >= rank.points then
				break;
			end
	end
	return rank;
end
function PLAYER:GetPoints()
	return self:ESGetNetworkedVariable("bhop_points",0)
end


local function fixvalue(v)
	if string.len(tostring(v)) < 2 then
		return "0"..v;
	end
	return v;
end

local PLAYER = FindMetaTable("Player");
function PLAYER:GetTime()
	return CurTime() - self:ESGetNetworkedVariable("bhop_starttime",CurTime());
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
