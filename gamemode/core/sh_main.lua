BHOP.Ranks={}

local i=0
local function defineRank(name,icon)
	local pts;
	if i == 0 then
		pts=0
	else
		pts= (100 * math.pow(i,2) + 200 * math.pow(i,2) + 700 * i)
	end

	i=i+1

  BHOP.Ranks[i]={
    name=name,
    icon=Material(icon),
    points=pts
  }
end
defineRank( "Newbie","icon16/award_star_bronze_1.png")
defineRank( "Peasant","icon16/award_star_bronze_1.png")
defineRank( "Learning","icon16/award_star_bronze_2.png")
defineRank( "Beginner","icon16/award_star_bronze_2.png")
defineRank( "Rookie","icon16/award_star_bronze_2.png")
defineRank( "Novice","icon16/award_star_bronze_3.png")
defineRank( "Decent","icon16/award_star_bronze_3.png")
defineRank( "Adept","icon16/award_star_bronze_3.png")
defineRank( "Amazing","icon16/award_star_silver_1.png")
defineRank( "Addict","icon16/award_star_silver_1.png")
defineRank( "Insane","icon16/award_star_silver_2.png")
defineRank( "Crazy","icon16/award_star_silver_2.png")
defineRank( "Nasty","icon16/award_star_silver_3.png")
defineRank( "Ludicrous","icon16/award_star_silver_3.png")
defineRank( "Superb","icon16/award_star_gold_1.png")
defineRank( "Magnificent","icon16/award_star_gold_1.png")
defineRank( "Exalted","icon16/award_star_gold_2.png")
defineRank( "Majestic","icon16/award_star_gold_2.png")
defineRank( "Hacker","icon16/award_star_gold_3.png")
defineRank( "Wizard","icon16/award_star_gold_3.png")

hook.Add( "ShouldCollide", "exclNoPlayersCollide", function(ent1,ent2)
	if ( ent1:IsPlayer() and ent2:IsPlayer() ) then
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
