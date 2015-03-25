hook.Add( "CreateMove", "BHOP.Auto.CreateMove", function( input )
	if not LocalPlayer():Alive() or not LocalPlayer().NextBunnyHop or LocalPlayer().NextBunnyHop < CurTime()  then return end

	if input:KeyDown( IN_JUMP ) and (LocalPlayer():GetDifficulty().name == "Easy" or LocalPlayer():GetDifficulty().name == "Normal") then
		input:SetButtons( input:GetButtons( ) - IN_JUMP )
	end
end);

hook.Add( "OnPlayerHitGround", "BHOP.Auto.HitGround", function( p, inWater, onFloater, speed )
	p.NextBunnyHop = CurTime( );
end);
