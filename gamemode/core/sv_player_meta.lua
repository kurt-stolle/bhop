local PLAYER=FindMetaTable("Player")
function PLAYER:SetPoints(amt)
	if IsValid(self) then
		self:ESSetNetworkedVariable("bhop_points",amt);
		ES.DBQuery("UPDATE bhop_player SET points = "..amt.." WHERE steamid = '"..self:SteamID().."';")
	end
end
function PLAYER:AddPoints(amt)
	self:SetPoints(self:GetPoints() + amt)
end
