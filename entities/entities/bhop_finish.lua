AddCSLuaFile()

ENT.Type             = "anim"
ENT.Base             = "base_anim"

if SERVER then

	function ENT:Initialize()
      self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )

      local min = self.min or Vector(-100,-50,-100)
      local max = self.max or Vector(100,100,100)

      self:SetMoveType(MOVETYPE_NONE)
			self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

			self:SetTrigger(true)

      self:PhysicsInitBox(min,max)
      self:SetCollisionBounds(min,max)

      local phys = self:GetPhysicsObject()
      if phys and phys:IsValid() then
				phys:Wake()
        phys:EnableMotion(false)
				phys:EnableGravity( false )
				phys:EnableDrag( false )
      end

      self.handle_min=ents.Create("bhop_finish_handle")
      self.handle_min:SetPos(self:GetPos()+min)
			self.handle_min:SetFinishEntity(self)
      self.handle_min:Spawn()

      self.handle_max=ents.Create("bhop_finish_handle")
      self.handle_max:SetPos(self:GetPos()+max)
			self.handle_max:SetFinishEntity(self)
      self.handle_max:Spawn()

			self.lastMin=self.handle_min:GetPos()
			self.lastMax=self.handle_max:GetPos()
  end

	local noReward={}
	function ENT:StartTouch( ply )
		if IsValid(ply) and ply:IsPlayer() and not ply.didFinish then
			ply.didFinish=true

			ply:HandleLeaderboards()
			for k,v in ipairs(player.GetAll())do
				v:ChatPrint("<hl>"..ply:Nick().."</hl> has finished the map on <hl>"..ply:GetDifficulty().name.."</hl> mode in <hl>"..ply:GetTimeString().."</hl>!")
			end

			ply:ESSendNotificationPopup("Finished","Congratsulations!\n\nYou completed the map in "..ply:GetTimeString().." on "..ply:GetDifficulty().name.." mode. \n\nPress F4 to reset or press F1 to pick another mode.")

			ply:AddPoints(50 * BHOP:GetMapPointsMultiplier() * ply:GetDifficulty().mul)

			if noReward[ply] then
				if table.HasValue(noReward[ply],ply:GetDifficulty()) then
					return
				end
			else
				noReward[ply]={}
			end

			table.insert(noReward[ply],ply:GetDifficulty())

			ply:ESAddBananas(10)

			BHOP.DebugPrint(ply:Nick().." has finished the map!")
		end
	end

	local a0=Angle(0,0,0)
	local p0=Vector(0,0,0)
	function ENT:Think()
		if self:GetAngles() ~= a0 or self:GetPos() ~= p0 then
			self:SetAngles(a0)
			self:SetPos(p0)

			local phys = self:GetPhysicsObject()
      if phys and phys:IsValid() then
				phys:Wake()
        phys:EnableMotion(false)
				phys:EnableGravity( false )
				phys:EnableDrag( false )
      end
		end

		if IsValid(self.handle_min) and IsValid(self.handle_max) and (self.lastMin ~= self.handle_min:GetPos() or self.lastMax ~= self.handle_max:GetPos()) then
			self:Resize(self.handle_min:GetPos(),self.handle_max:GetPos())
			self.lastMin=self.handle_min:GetPos()
			self.lastMax=self.handle_max:GetPos()
		end
	end

  function ENT:Resize(minWorld,maxWorld)
		local min = self:WorldToLocal( minWorld )
		local max = self:WorldToLocal( maxWorld )

    self:PhysicsInitBox(min,max)
    self:SetCollisionBounds(min,max)
  end

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

elseif CLIENT then
	function ENT:Think()
		local mins,maxs=self:OBBMins(),self:OBBMaxs();
		self:SetRenderBoundsWS( mins,maxs )
	end
	local tx=Material( "color" )
  function ENT:Draw()
		local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()

		local mins,maxs=self:OBBMins(),self:OBBMaxs();

		render.SetMaterial( tx )
		render.DrawBox( self:GetPos(),self:GetAngles(),mins,maxs,ES.Color["#FF4411AA"],true)
		render.DrawWireframeBox( self:GetPos(),self:GetAngles(),mins,maxs,ES.Color["#FFCCAAFF"],true)
	end

end
