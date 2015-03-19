-- sh_init
BHOP={}
setmetatable(BHOP,{
	__index=function(self,key)
		return (GM or GAMEMODE)[key]
	end,
	__newindex=function(self,key,value)
		rawset(GM or GAMEMODE,key,value)
		return nil
	end
})

BHOP.Name = "Bunny Hop"
BHOP.Author = "Excl"
BHOP.Email = "kurt@exclstudios.com"
BHOP.Website = "www.casualbananas.com"

function BHOP.DebugPrint(...)
	MsgC(Color(220,2420,220),"[BHOP DEBUG] [")
	MsgC(SERVER and Color(90,150,255) or Color(255,255,90),SERVER and "SERVER" or "CLIENT");
	MsgC(Color(220,2420,220),"] ["..os.date().."]\t\t");
	MsgC(Color(255,255,255),...);
	Msg("\n");
end

BHOP.DebugPrint("Loading Bunny Hop by Casual Bananas...")
local loadFolder = function(folder,shared)
	local path = "bhop/gamemode/"..folder.."/";

	BHOP.DebugPrint("Accessing "..path)

	for _,name in pairs(file.Find(path.."*.lua","LUA")) do
		local runtype = shared or "sh";
		if not shared then
			runtype = string.Left(name, 2);
		end
		if not runtype or ( runtype ~= "sv" and runtype ~= "sh" and runtype ~= "cl" ) then return false end

		if SERVER then
			if runtype == "sv" then
				BHOP.DebugPrint("Loading file: "..name);
				include(folder.."/"..name);
			elseif runtype == "sh" then
				BHOP.DebugPrint("Loading file: "..name);
				include(folder.."/"..name);
				AddCSLuaFile(folder.."/"..name);
			elseif runtype == "cl" then
				AddCSLuaFile(folder.."/"..name);
			end
		elseif CLIENT then
			if (runtype == "sh" or runtype == "cl") then
				BHOP.DebugPrint("Loading file: "..name);
				include(folder.."/"..name);
			end
		end
	end

	return true
end

loadFolder("util")
loadFolder("core")
loadFolder("classes","sh")
BHOP.DebugPrint("Successfully loaded gamemode!")
