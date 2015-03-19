--[[hook.Add("InitPostEntity","BHOP.OptimizeFPS",function()
  if GetConVar("fps_max"):GetFloat() == 300 then
    BHOP.DebugPrint("Your fps_max convar is not optimal. Reconnecting with proper value. If you are intentionally not limiting your fps, use a value other than the default 300.")
    LocalPlayer():ConCommand("disconnect; fps_max 34.8; retry;")
  end
end)]]
