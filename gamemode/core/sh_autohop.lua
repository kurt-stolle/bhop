local bAnd=bit.band
local bNot=bit.bnot
hook.Add( "SetupMove", "BHOP.Cheat.AutoJump", function( ply, move )
    if not ply:IsOnGround() and ply:KeyDown(IN_JUMP) and (ply:GetDifficulty().key == 1 or ply:GetDifficulty().key == 2) then
      move:SetButtons( bAnd( move:GetButtons(), bNot( IN_JUMP ) ) )
    end
end )
