BHOP.Difficulties={}

function BHOP:CreateTeams()
  for i,tab in ipairs(BHOP.Difficulties)do
    team.SetUp(i, tab.name, tab.color);
  	team.SetSpawnPoint(i,{"info_player_start","info_player_terrorist","team_player_counterterrorist"})
  end
end

local i=0
local function defineDifficulty(name,timeOnBlock,killOnBlock,color)
  i=i+1

  BHOP.Difficulties[i]={
    name=name,
    color=color,
    timeOnBlock=timeOnBlock,
    killOnBlock=killOnBlock
  }
end
defineDifficulty("Easy",2,false,ES.Color.Yellow)
defineDifficulty("Normal",1,false,ES.Color.Green)
defineDifficulty("Hard",.5,false,ES.Color.Blue)
defineDifficulty("Nightmare",.5,true,ES.Color.Red)

local PLAYER=FindMetaTable("Player")
function PLAYER:GetDifficulty()
  return BHOP.Difficulties[self:Team()] or BHOP.Difficulties[1]
end
