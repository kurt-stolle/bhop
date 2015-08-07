
if (SERVER) then
	AddCSLuaFile( "shared.lua" );
	SWEP.Weight				= 5;
	SWEP.AutoSwitchTo		= false;
	SWEP.AutoSwitchFrom		= false;
end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true;
	SWEP.DrawCrosshair		= false;
	SWEP.ViewModelFOV		= 70;
	SWEP.ViewModelFlip		= false;
	SWEP.CSMuzzleFlashes	= false;
	SWEP.DrawWeaponInfoBox  = false;

	SWEP.Slot				= 1;
	SWEP.SlotPos			= 1;
end

SWEP.Primary.Automatic		= false;

SWEP.Author			= "Excl";
SWEP.Contact		= "";
SWEP.Purpose		= "";
SWEP.Instructions	= "";
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.PrintName            = "Shotgun"
SWEP.Category		= "Excl";

SWEP.UseHands = true;

SWEP.ViewModel = "models/weapons/c_shotgun.mdl";
SWEP.WorldModel = "models/weapons/w_shotgun.mdl";

SWEP.Sound			= Sound( "Weapon_Shotgun.Single" );
SWEP.Recoil			= 1.2;
SWEP.Damage			= 100/8;
SWEP.NumShots		= 8;
SWEP.Cone			= 0.1;
SWEP.IronCone		= 0.05;
SWEP.MaxCone		= 0.09;
SWEP.ShootConeAdd	= 0.005;
SWEP.CrouchConeMul 	= 0.7;
SWEP.Primary.ClipSize		= 8;
SWEP.Delay			= 0.25;
SWEP.DefaultClip	=8;
SWEP.Primary.Ammo			= "buckshot";
SWEP.ReloadSequenceTime = 1.85;

SWEP.IronCycleSpeed = 20;

SWEP.Secondary.ClipSize		= -1;
SWEP.Secondary.DefaultClip	= -1;
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "none";

SWEP.AimPos = Vector (-9.0, -10, 4.3)
SWEP.AimAng = Vector (0,0,0)


function SWEP:SetupDataTables( )
	self:DTVar( "Int", 0, "Mode" );
	self:DTVar( "Float", 0, "LastShoot" );
end

function SWEP:Initialize()
	if IsValid(self) and self.SetWeaponHoldType then
		self:SetWeaponHoldType("shotgun");
		self:SetDTInt(0, 0);
		self:SetDTInt(0, 0);
	end
end

function SWEP:Deploy()
	if (self.Owner:Team() ~= TEAM_BUNNY ) then return false end

	self:SendWeaponAnim(ACT_VM_DRAW);
	self:SetNextPrimaryFire(CurTime() + 1);

	return true;
end

function SWEP:Holster()
	self:SetDTInt(0, 0);

	if SERVER then
		self.Owner:SetFOV(0,0.6)
	end

	return true;
end

function SWEP:Reload() end

SWEP.AddCone = 0;
SWEP.LastShoot = CurTime();
SWEP.oldMul = 1;
function SWEP:Think()
	if not SERVER then return end;

	local mul = 1;
	if self.Owner:Crouching() then
		mul = self.CrouchConeMul;
	elseif self.Owner:GetVelocity():Length() > 5 then
		mul = mul+.5
	end
	self.oldMul = Lerp(0.5,self.oldMul,mul);

	if self.LastShoot+0.2 < CurTime() then
		self.AddCone = self.AddCone-(self.ShootConeAdd/5);
		if self.AddCone < 0 then
			self.AddCone=0;
		end
	end

	if self:GetDTInt(0) == 1 then
		self:SetDTFloat(1, math.Clamp((self.IronCone+self.AddCone)*self.oldMul, 0.002, 0.12));
	else
		self:SetDTFloat(1, math.Clamp((self.Cone+self.AddCone)*self.oldMul, 0.002, 0.12));
	end

	if not self.Owner.FOVRate or not type(self.Owner.FOVRate) == "number" then
		self.Owner.FOVRate = 0;
	end

	local dt = self:GetDTInt(0);

	if dt == 1 then
		self.Owner.FOVRate = 0; --(GetConVarNumber("fov_desired")-20); garry broke FOV
	else
		self.Owner.FOVRate = 0;
	end
	self.Owner:SetFOV(self.Owner.FOVRate,0.5)

 	if self:GetDTInt(0) > 1 then
		self:SetDTInt(0,0);
		return;
	end
end

function SWEP:PrimaryAttack()

	local ct = CurTime();

	if self:GetDTInt(0) > 1 then
		self:SetNextPrimaryFire(ct+self.Delay);
		return;
	elseif self:Clip1() <= 0 then
		self:SetNextPrimaryFire(ct+self.Delay);
		self:EmitSound( "Weapon_Pistol.Empty" )
		return;
	end

	self:SetNextPrimaryFire(ct+self.Delay);

	if self:GetDTInt(0) ~= 1 then
		self:CSShootBullet( self.Damage, self.Recoil * 1.5, self.NumShots, self:GetDTFloat(1))
	else
		self:CSShootBullet( self.Damage, self.Recoil * 0.75, self.NumShots, self:GetDTFloat(1))
	end

	self.AddCone = math.Clamp(self.AddCone+self.ShootConeAdd,0,self.MaxCone)
	self.LastShoot = ct;

	if SERVER then
		self.Owner:EmitSound(self.Sound, 100, math.random(95, 105))
	end
end

function SWEP:CSShootBullet( dmg, recoil, numbul, cone )
	numbul 	= numbul 	or 1;
	cone 	= cone 		or 0.01;

	local bullet = {}
	bullet.Num 		= numbul;
	bullet.Src 		= self.Owner:GetShootPos();
	bullet.Dir 		= ( self.Owner:EyeAngles() + self.Owner:GetPunchAngle() ):Forward();
	bullet.Spread 	= Vector( cone, cone, 0 );
	bullet.Tracer	= 4;
	bullet.Force	= self.Damage;
	bullet.Damage	= self.Damage;

	self.Owner:FireBullets(bullet);
	if self:GetDTInt(0,0) ~= 1 then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
	else

	end
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	self.Owner:MuzzleFlash();


	if ( CLIENT and IsFirstTimePredicted() ) then

		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - (recoil * 1 * 0.3)
		eyeang.yaw = eyeang.yaw - (recoil * math.random(-1, 1) * 0.3)
		self.Owner:SetEyeAngles( eyeang )
	elseif SERVER then
		local eyeang = self.Owner:EyeAngles()
		self.Owner:SetVelocity(eyeang:Forward() * -50)
	end
end

local CurMove = -2;
local AmntToMove = 0.4;
local MoveCycle = 0;
local Ironsights_Time = 0.1;
local CurShakeA = 0.03;
local CurShakeB = 0.03;
local randomdir = 0;
local randomdir2 = 0;
local timetorandom = 0;
local BlendPos = Vector(0, 0, 0);
local BlendAng = Vector(0, 0, 0);
local ApproachRate = 0.2;
local RollModSprint = 0;

function SWEP:GetViewModelPosition(pos, ang)
	local t = FrameTime();
	local dt = self:GetDTInt(0);
	if dt == 1 then
		TargetPos = self.AimPos
		TargetAng = self.AimAng
	else
		TargetPos = Vector(0,0,0);
		TargetAng = Vector(0,0,0);
	end

	if self:GetDTInt(0) == 1 then
		ApproachRate = t * 15
	else
		ApproachRate = t * 10
	end

	BlendPos = LerpVector(ApproachRate, BlendPos, TargetPos)
	BlendAng = LerpVector(ApproachRate, BlendAng, TargetAng)

	CurShakeA = math.Approach(CurShakeA, randomdir, 0.01)
	CurShakeB = math.Approach(CurShakeB, randomdir2, 0.01)

	if CurTime() > timetorandom then
		randomdir = math.Rand(-0.1, 0.1)
		randomdir2 = math.Rand(-0.1, 0.1)
		timetorandom = CurTime() + 0.2
	end

	if dt == 1 then -- stop the Sway when we are in ironsights
		self.SwayScale 	= 0.1
		self.BobScale 	= 0
	else
		self.SwayScale 	= 1.5
		self.BobScale 	= 0.4
	end

	if CurMove == -2 then
		MoveCycle = 1
	elseif CurMove == 2 then
		MoveCycle = 2
	end

	if MoveCycle == 1 then
		CurMove = math.Approach(CurMove, 2, 0.11 - CurMove * 0.05)
	end

	if self.AimAng then
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		BlendAng.x + CurShakeB * self.BobScale )
		ang:RotateAroundAxis( ang:Up(), 		BlendAng.y + CurShakeA * self.BobScale)
		ang:RotateAroundAxis( ang:Forward(), 	BlendAng.z + CurShakeA * self.BobScale)
	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

	pos = pos + BlendPos.x * Right
	pos = pos + BlendPos.y * Forward
	pos = pos + BlendPos.z * Up

	return pos, ang
end

if CLIENT then
	local matCrosshair = Material("deathrunexcl/crosshair.png");
	function SWEP:FireAnimationEvent(pos, ang, ev)
		if ev == 5001 then
			if not self.Owner:ShouldDrawLocalPlayer() then
				local vm = self.Owner:GetViewModel();
				local muz = vm:GetAttachment("1");

				if not self.Em then
					self.Em = ParticleEmitter(muz.Pos);
				end

				local par = self.Em:Add("particle/smokesprites_000" .. math.random(1, 9), muz.Pos);
				par:SetStartSize(math.random(1.5, 3));
				par:SetStartAlpha(120);
				par:SetEndAlpha(0);
				par:SetEndSize(math.random(5, 5.5));
				par:SetDieTime(1.5 + math.Rand(-0.3, 0.3));
				par:SetRoll(math.Rand(0.2, 1));
				par:SetRollDelta(0.8 + math.Rand(-0.3, 0.3));
				par:SetColor(120,120,120,255);
				par:SetGravity(Vector(0, 0, 5));
				local mup = (muz.Ang:Up()*-20);
				par:SetVelocity(Vector(0, 0,7)-Vector(mup.x,mup.y,0));

				local par = self.Em:Add("sprites/heatwave", muz.Pos);
				par:SetStartSize(8);
				par:SetEndSize(0);
				par:SetDieTime(0.3);
				par:SetGravity(Vector(0, 0, 2));
				par:SetVelocity(Vector(0, 0, 20));
			end
		end
	end

	function SWEP:AdjustMouseSensitivity()
		if self:GetDTInt(0) == 1 then
			return 0.6;
		else
			return 1
		end
	end

	local gap = 5
	local gap2 = 0
	local CurAlpha_Weapon = 255
	local x2 = (ScrW() - 1024) / 2
	local y2 = (ScrH() - 1024) / 2
	local x3 = ScrW() - x2
	local y3 = ScrH() - y2
	function SWEP:DrawHUD()
		local FT = FrameTime();

		x, y = ScrW() / 2, ScrH() / 2;

		local scale = (10 * self.Cone)* (2 - math.Clamp( (CurTime() - self:GetDTFloat(1)) * 5, 0.0, 1.0 ))

		if self:GetDTInt(0) > 0 then
			CurAlpha_Weapon = math.Approach(CurAlpha_Weapon, 0, FT / 0.0017)
		else
			CurAlpha_Weapon = math.Approach(CurAlpha_Weapon, 230, FT / 0.001)
		end

		gap = math.Approach(gap, 50 * ((10 / (self.Owner:GetFOV() / 90)) * self:GetDTFloat(1)), 1.5 + gap * 0.1)

		-- awesome cod-ish crosshair
		surface.SetDrawColor(255,255,255,CurAlpha_Weapon);
		draw.NoTexture()
		surface.DrawTexturedRectRotated(x - gap - 14/2,y,2,16,270+180);
		surface.DrawTexturedRectRotated(x + gap + 14/2,y,2,16,90+180);
		surface.DrawTexturedRectRotated(x, y + gap + 14/2,2,16,0+180);
		surface.DrawTexturedRectRotated(x, y - gap - 14/2,2,16,180+180);
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end

	local dt = self:GetDTInt(0);

	if dt == 2 then
		return;
	elseif dt == 1 then
		self:SetDTInt(0,0);
		self.Owner:SetFOV(0,0.6)
	else
		self:SetDTInt(0,1);
		self.Owner:SetFOV(GetConVarNumber("fov_desired")-15,0.3)
	end
end

function SWEP:OnRestore()
end
