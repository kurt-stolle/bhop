util.AddNetworkString("BHOP.ACDetect")
net.Receive("BHOP.ACDetect",function(len,ply)
  if not ply:Alive() then return end
  
  BHOP.DebugPrint("Detected autohop cheat @ "..ply:Nick())
  ply:Kill()
end)
