
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
