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
defineDifficulty("Easy",.8,false,ES.Color.White)
defineDifficulty("Normal",.6,false,ES.Color.White)
defineDifficulty("Hard",.4,false,ES.Color.White)
defineDifficulty("Nightmare",.4,true,ES.Color.White)

local PLAYER=FindMetaTable("Player")
function PLAYER:GetDifficulty()
  return BHOP.Difficulties[self:Team()] or BHOP.Difficulties[1]
end
