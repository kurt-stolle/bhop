

function BHOP:OnPlayerChat( player, strText, bTeamOnly, bPlayerIsDead )

 chat.AddText(player or "CONSOLE",ES.Color.White," ("..(player.GetRank and player:GetRank().name or "CONSOLE").."): ",strText)
 return true

end
