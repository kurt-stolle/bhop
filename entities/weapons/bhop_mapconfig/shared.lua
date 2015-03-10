-- map pos maker :<


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
	SWEP.ViewModelFlip		= true;
	SWEP.CSMuzzleFlashes	= true;
	SWEP.DrawWeaponInfoBox  = false;
	
	SWEP.Slot				= 2;
	SWEP.SlotPos			= 1;
end

SWEP.Primary.Automatic		= true

SWEP.Author			= "Excl";
SWEP.Contact		= "";
SWEP.Purpose		= "";
SWEP.Instructions	= "";
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.PrintName            = "map configurator"
SWEP.Category		= "_NewBee AKA Excl";



SWEP.ViewModel = "";
SWEP.WorldModel = ""; 

SWEP.Primary.ClipSize		= -1;
SWEP.Primary.DefaultClip	= -1;
SWEP.Primary.Automatic	= false;
SWEP.Primary.Ammo			= "none";

SWEP.Secondary.ClipSize		= -1;
SWEP.Secondary.DefaultClip	= -1;
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "none";

function SWEP:Initialize()
	if IsValid(self) and self.SetWeaponHoldType then 
		self:SetWeaponHoldType("normal");
	end
end

function SWEP:Deploy()
	if SERVER then
		self.Owner:ConCommand("bhop_showconfig")
	end
	return true;
end

function SWEP:Holster()
	if SERVER then
		self.Owner:ConCommand("bhop_noshowconfig")
	end
	return true;
end
function SWEP:OnRemove()
	if SERVER then
		self.Owner:ConCommand("bhop_noshowconfig")
	end
	return true;
end

SWEP.nextReload = CurTime();
function SWEP:Reload()	
	if self.nextReload > CurTime() then return end

	self.nextReload = CurTime() + 1;
	if SERVER then
		self.Owner:ConCommand("bhop_addblockgroup")
	end
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.1);
	if SERVER then
		self.Owner:ConCommand("bhop_addblock "..self:GetNWInt("block"));
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end

	self:SetNWInt("block",self:GetNWInt("block",1) + 1);
	if self:GetNWInt("block") > #BHOP.blockGroups then
		self:SetNWInt("block",1);
	end
	self:SetNextSecondaryFire(CurTime() + 0.1);
end

function SWEP:OnRestore()
end

function SWEP:DrawHUD()
	draw.SimpleTextOutlined(self:GetNWInt("block",0),"DermaDefaultBold",ScrW()/2,ScrH()/2,Color(255,255,255),1,1,1,Color(0,0,0))
end