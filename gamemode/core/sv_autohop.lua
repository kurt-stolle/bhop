hook.Add( 'SetupMove', 'auto hop', function( ply, move )
    if not ply:IsOnGround() and ply:KeyDown(IN_JUMP) and (ply:GetDifficulty().name == "Easy" or ply:GetDifficulty().name == "Normal") then
    	move:SetButtons( bit.band( move:GetButtons(), bit.bnot( IN_JUMP ) ) )
    end
end )
