function GM:Initialize()
  RunConsoleCommand("sv_airaccelerate", 1000)
	RunConsoleCommand("sv_gravity", 800)
	RunConsoleCommand("sv_sticktoground", 0)
	RunConsoleCommand("sv_alltalk", 1)
  RunConsoleCommand("sv_kickerrornum", 0)
end

function GM:InitPostEntity()
	for k,v in ipairs(ents.FindByClass("func_door")) do
		v:Fire("lock", "", 0)
  end
end
