concommand.Add("bhop_admin_configmode",function(ply)
	if not ply:IsSuperAdmin() then return end

	ply:Give("weapon_physgun")
	ply:SelectWeapon("weapon_physgun")
	ply:ESChatPrint("You have entered map configuration mode.")
end)

local mapMul=1;
concommand.Add("bhop_admin_setmultiplier",function(ply,_,args)
	if not ply:IsSuperAdmin() then return end

	mapMul=math.Clamp(tonumber(args[1]),.1,4);
	ply:ESChatPrint("Multiplier set: "..mapMul)

	ES.DBQuery("SELECT id FROM `bhop_mapconfig_mul` WHERE map='"..game.GetMap().."' LIMIT 1;",function(res)
		if res and res[1] and res[1].id then
			ES.DBQuery("UPDATE `bhop_mapconfig_mul` SET mul="..mapMul.." WHERE id="..res[1].id..";")
		else
			ES.DBQuery("INSERT INTO `bhop_mapconfig_mul` SET map='"..game.GetMap().."', mul="..mapMul..";")
		end
	end)
end)

hook.Add("ESDatabaseReady","BHOP.SetupData",function()
	ES.DBQuery("CREATE TABLE IF NOT EXISTS `bhop_mapconfig_mul` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, map varchar(255), mul float, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;CREATE TABLE IF NOT EXISTS `bhop_mapconfig_start` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, map varchar(255), mins varchar(255), maxs varchar(255), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;")

	ES.DBQuery("SELECT mul FROM `bhop_mapconfig_mul` WHERE map='"..game.GetMap().."' LIMIT 1;",function(res)
		if res and res[1] and res[1].mul then
			mapMul=tonumber(res[1].mul)
			BHOP.DebugPrint("Map multiplier set: "..mapMul)
		end
	end)

	ES.DBQuery("SELECT id, mins, maxs FROM `bhop_mapconfig_finish` WHERE map='"..game.GetMap().."';",function(res)
		if res and res[1] then
			for k,v in ipairs(res)do
				local ent=ents.Create("bhop_finish")
				ent:Spawn()
				ent.handle_min:SetPos(Vector(v.mins))
				ent.handle_max:SetPos(Vector(v.maxs))
				ent.dbId=v.id

				ent:Think()

				BHOP.DebugPrint("Spawned Finish entity!")
			end
		end
	end)

end)

local waitSave=false;
function BHOP:OnPhysgunFreeze(weapon, physobj, ent, ply)
	if not ply:IsSuperAdmin() or waitSave then return false end

	if not IsValid(ent) or ent:GetClass() ~= "bhop_finish_handle" then return false end

	ent.isPositioned=true;

	local finishEnt=ent:GetFinishEntity()

	if IsValid(finishEnt.handle_min) and IsValid(finishEnt.handle_max) and finishEnt.handle_min.isPositioned and finishEnt.handle_max.isPositioned then
		local mins,maxs=tostring(finishEnt.handle_min:GetPos()),tostring(finishEnt.handle_max:GetPos())
		if not finishEnt.dbId then
			waitSave=true
			ES.DBQuery("INSERT INTO `bhop_mapconfig_finish` SET map='"..game.GetMap().."', mins='"..mins.."', maxs='"..maxs.."';",function()
				ES.DBQuery("SELECT id,mins,maxs FROM `bhop_mapconfig_finish` WHERE map='"..game.GetMap().."';",function(res)
					if res and res[1] then
						for k,v in ipairs(res)do
							if v.mins == mins and v.maxs == maxs then
								finishEnt.dbId=v.id
								waitSave=false

								ES.DebugPrint("Insertion of finish area successful. ID Found!")
							end
						end
					end
				end)
			end)
		else
			ES.DBQuery("UPDATE `bhop_mapconfig_finish` SET mins='"..mins.."', maxs='"..maxs.."' WHERE id="..finishEnt.dbId..";")
		end

		ply:ESChatPrint("Finish area saved to database. This area will now automatically designated when the map loads.")

	end

	return true
end

function BHOP:OnPhysgunReload(physgun, ply)
	if not ply:IsSuperAdmin() then return false end

	local ent=ents.Create("bhop_finish")
	ent:Spawn()

	local ps=ply:GetEyeTrace().HitPos
	ent.handle_min:SetPos(ps+Vector(-.1,-.1,-.1))
	ent.handle_max:SetPos(ps+Vector(.1,.1,.1))

	ent:Think()

	ply:ESChatPrint("Finish area designator spawned. Freeze both handles (green circles) to save finish area.")

	return true
end

function BHOP:PhysgunPickup(ply,ent)
		return ply:IsSuperAdmin() and ent:GetClass() == "bhop_finish_handle"
end

function BHOP:GetMapPointsMultiplier()
		return mapMul
end
