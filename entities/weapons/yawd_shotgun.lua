SWEP.Base = "yawd_weapon_base"
SWEP.PrintName = "Shotgun"
SWEP.Author = "YAWD Team"
SWEP.Category = "YAWD"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.m_WeaponDeploySpeed = 1

SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.Weight = 5

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/v_shot_xm1014.mdl"
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"
SWEP.HoldType = "shotgun"
SWEP.ViewModelFlip = true

SWEP.Primary = {
	Ammo = "BuckshotHL1",
	ClipSize = 8,
	DefaultClip = 32,
	Automatic = false,
}

SWEP.PrimaryDelay = 0.32
SWEP.PrimarySpread = Vector(0.1, 0.1, 0)
SWEP.PrimaryBulletsPerFire = 8
SWEP.PrimaryBulletsTakenPerShot = 1
SWEP.PrimaryForce = 1
SWEP.PrimaryMaxDistance = 8092
SWEP.PrimarySound = "weapons/xm1014/xm1014-1.wav"
SWEP.PrimaryDamage = {
	min = 14,
	max = 32,
}
SWEP.PrimaryViewPunch = {
	p = {
		min = -3,
		max = -8,
	},
	y = {
		min = 2,
		max = 2,
	},
}

SWEP.ReloadDelay = 1
SWEP.ReloadSound = "weapons/xm1014/xm1014_insertshell.wav"
