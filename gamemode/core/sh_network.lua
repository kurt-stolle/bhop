function BHOP:ESDefineNetworkedVariables()
  BHOP.DebugPrint("Defining networked variables")

  ES.DefineNetworkedVariable("bhop_points","UInt",32,nil)
  ES.DefineNetworkedVariable("bhop_starttime","UInt",32,nil)
end
