class_name GnomesRig
extends HardwareRig

## The gnomes with watches (ferreteria.md, "Los gnomos con relojes"): twelve ceramic garden gnomes for sale in the
## yard, in two rows. One of them, drawn with the seed, is the boss: hollow and full of stolen watches, 8 kg, the main
## evidence. The rest are fragile goods, a fine each if they break. Only the boss ticks, close up, and hearing it is the
## story's own clue. The list of watches and the glue are hidden in the store's usual spots. Every number here is
## (propuesta).

const GNOME_SCENE := preload("res://scenes/props/garden_gnome.tscn")
const BOSS_SCENE := preload("res://scenes/props/gnome_boss.tscn")
const GNOME_MODELS: Array[PackedScene] = [
	preload("res://assets/models/garden_gnome_0.glb"), preload("res://assets/models/garden_gnome_1.glb"),
	preload("res://assets/models/garden_gnome_2.glb"),
]
## Where the gnomes stand in the yard: a row along the back wall and one along the back fence, clear of the
## wheelbarrow, the sand and the bricks.
const GNOME_SPOTS: Array[Vector3] = [
	Vector3(-7.0, HardwareStore.GRASS_TOP, -2.7), Vector3(-5.8, HardwareStore.GRASS_TOP, -2.7),
	Vector3(-3.4, HardwareStore.GRASS_TOP, -2.7), Vector3(-2.2, HardwareStore.GRASS_TOP, -2.7),
	Vector3(-1.0, HardwareStore.GRASS_TOP, -2.7), Vector3(0.2, HardwareStore.GRASS_TOP, -2.7),
	Vector3(-7.0, HardwareStore.GRASS_TOP, -6.6), Vector3(-5.8, HardwareStore.GRASS_TOP, -6.6),
	Vector3(-2.2, HardwareStore.GRASS_TOP, -6.6), Vector3(-1.0, HardwareStore.GRASS_TOP, -6.6),
	Vector3(1.4, HardwareStore.GRASS_TOP, -6.6), Vector3(2.6, HardwareStore.GRASS_TOP, -6.6),
]

var boss: GnomeBoss
var gnomes: Array[Ornament] = []


func setup(place: HardwareStore) -> void:
	super.setup(place)
	var boss_at := boss_spot(place.case_seed)
	for i in GNOME_SPOTS.size():
		var gnome: RigidBody3D
		if i == boss_at:
			boss = BOSS_SCENE.instantiate()
			gnome = boss
		else:
			gnome = GNOME_SCENE.instantiate()
			gnome.get_node("Model").free()
			var look: Node3D = GNOME_MODELS[i % GNOME_MODELS.size()].instantiate()
			look.name = "Model"
			gnome.add_child(look)
		gnome.position = GNOME_SPOTS[i] + Vector3.UP * 0.01
		# Rows face each other across the yard: the back wall's toward the fence, the fence's toward the wall.
		gnome.rotation.y = PI if GNOME_SPOTS[i].z > -4.5 else 0.0
		place.add_child(gnome)
		if gnome is Ornament:
			(gnome as Ornament).broken.connect(place._on_fragile_broken)
			gnomes.append(gnome)
	place.main = boss
	boss.heard.connect(func() -> void: place.raid.add_clue(tr("CLUE_GNOME_TICK")))


## Which of the twelve gnomes is the boss, from the seed.
static func boss_spot(case_seed: int) -> int:
	return case_seed % GNOME_SPOTS.size()
