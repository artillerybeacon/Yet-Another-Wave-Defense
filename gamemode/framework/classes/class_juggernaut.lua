DEFINE_BASECLASS("player_yawd")

local PLAYER = {}
PLAYER.DisplayName = "Juggernaut"

PLAYER.Model = Model("models/player/swat.mdl")
PLAYER.Hands = {
	model = Model("models/weapons/c_arms_combine.mdl"),
	skin = 0,
	body = "00000000",
}

PLAYER.WalkSpeed = 230
PLAYER.RunSpeed = 230

PLAYER.JumpPower = 150

PLAYER.MaxHealth = 350
PLAYER.StartHealth = 350

PLAYER.Description = "The #yawd_juggernaut has a steady damage output and thrives on the frontlines."
PLAYER.BaseStats = {}

GM:RegisterClass("yawd_juggernaut", PLAYER)