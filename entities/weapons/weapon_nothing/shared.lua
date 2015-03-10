
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
	
	SWEP.Slot				= 3;
	SWEP.SlotPos			= 1;
end

SWEP.Primary.Automatic		= true

SWEP.Author			= "Excl";
SWEP.Contact		= "";
SWEP.Purpose		= "";
SWEP.Instructions	= "";
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.PrintName            = "Nothing"
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
	return true;
end

function SWEP:Holster()
	return true;
end

function SWEP:Reload()	
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:OnRestore()
end
