local function AddMaterial(path)
	return resource.AddFile(string.format("materials/yawd/%s", path))
end

AddMaterial("no_power.png")
AddMaterial("portal_spark.vmt")
AddMaterial("spike.png")
AddMaterial("trap_area.png")

AddMaterial("base_images/trap_bae.png")
AddMaterial("base_images/trap_side.png")
AddMaterial("base_images/trap_spike.png")
AddMaterial("base_images/trap_tar.png")

AddMaterial("hud/floor_turret.png")
AddMaterial("hud/lava.png")
AddMaterial("hud/spikes.png")
AddMaterial("hud/steam_trap.png")
AddMaterial("hud/tar.png")

AddMaterial("models/trap_base.vmt")
AddMaterial("models/trap_lava.vmt")
AddMaterial("models/trap_lava_empty.vmt")
AddMaterial("models/trap_lava_selfillum.vtf")
AddMaterial("models/trap_push.vmt")
AddMaterial("models/trap_side.vmt")
AddMaterial("models/trap_spike.vmt")
AddMaterial("models/trap_squre.vmt")
AddMaterial("models/trap_tar.vmt")

print("Added resources to download queue.")
