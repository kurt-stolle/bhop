

function BHOP:OnPlayerChat( player, strText, bTeamOnly, bPlayerIsDead )

 chat.AddText(player,ES.Color.White," ("..(player:GetRank().name).."): ",strText)
 return true

end
