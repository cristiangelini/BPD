class_name CasinoRig
extends HotelRig

## The casino of the 13 (hotel-allanamiento.md, "El casino de la 13"): don Bostezo runs a casino at night in the room
## that isn't on any list, behind the old wardrobe. The roulette is the main evidence and waits in the 13; the box of
## chips and the debt book hide like any extra. The story's own clues: casino chips in the lobby's plant and by the
## stairs upstairs, and a trail of footprints on the corridor's carpet that ends at the wardrobe. Near the wardrobe a
## cop hears the roulette ("tic tic tic") and sees cigar smoke coming out from under it. Every number here is
## (propuesta).

const ROULETTE_SCENE := preload("res://scenes/props/roulette.tscn")
const CHIPS_SCENE := preload("res://scenes/props/casino_chips.tscn")
const ROULETTE_AT := Vector3(3.5, Hotel.UP + 0.16, -6.0)
const CHIPS_AT: Array[Vector3] = [
	Hotel.PLANT_AT + Vector3(0.12, 0.52, 0.1), Vector3(9.0, Hotel.UP + 0.03, 0.6),
]
## The footprints run from the top of the stairs west along the corridor to the wardrobe.
const STEPS_FROM := 9.4
const STEPS_TO := 4.4
const STEP := 0.45
const STEP_Z := -0.25
## A cop this close to a footprint notices the trail; this close to the wardrobe, hears the roulette.
const SEES_STEPS := 1.5
const HEARS := 4.0
const TICK_AT := Vector3(3.5, Hotel.UP + 0.5, -0.35)
const SMOKE_AT := Vector3(3.5, Hotel.UP + 0.05, -0.3)
const SOLE := Color(0.25, 0.16, 0.1)

var roulette: Evidence
var chips: Array[ClueNote] = []
var steps: Array[Vector3] = []
var steps_seen := false
var tick_heard := false
var _tick: Label3D


func setup(place: HotelRaid) -> void:
	super.setup(place)
	roulette = ROULETTE_SCENE.instantiate()
	roulette.position = ROULETTE_AT
	place.add_child(roulette)
	place.main = roulette
	for at in CHIPS_AT:
		var chip: ClueNote = CHIPS_SCENE.instantiate()
		chip.text = tr("CLUE_CASINO_CHIPS")
		chip.position = at
		chip.read.connect(place.raid.add_clue)
		place.add_child(chip)
		chips.append(chip)
	_footprints()
	_tick = Label3D.new()
	_tick.name = "Tick"
	_tick.text = "CASINO_TICK"
	_tick.position = TICK_AT
	_tick.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_tick.pixel_size = 0.004
	_tick.outline_size = 8
	_tick.font_size = 36
	_tick.visible = false
	place.add_child(_tick)
	place.add_child(_smoke())


func _physics_process(_delta: float) -> void:
	var near_tick := false
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if cop.global_position.distance_to(TICK_AT) < HEARS:
			near_tick = true
		if not steps_seen and _near_steps(cop.global_position):
			steps_seen = true
			hotel_raid.raid.add_clue(tr("CLUE_CASINO_STEPS"))
	_tick.visible = near_tick and not roulette.is_held()
	if near_tick and not tick_heard:
		tick_heard = true
		hotel_raid.raid.add_clue(tr("CLUE_CASINO_TICK"))


func _near_steps(at: Vector3) -> bool:
	for step in steps:
		if step.distance_to(at) < SEES_STEPS:
			return true
	return false


## Muddy shoe prints on the red carpet, left and right, from the stairs to the wardrobe.
func _footprints() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = SOLE
	var x := STEPS_FROM
	var side := 1.0
	while x >= STEPS_TO:
		var at := Vector3(x, Hotel.UP + 0.012, STEP_Z + side * 0.12)
		var print_mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.28, 0.004, 0.11)
		print_mesh.mesh = box
		print_mesh.material_override = material
		print_mesh.position = at
		hotel_raid.add_child(print_mesh)
		steps.append(at)
		x -= STEP
		side = -side


## Thin grey cigar smoke curling out from under the wardrobe.
func _smoke() -> CPUParticles3D:
	var smoke := CPUParticles3D.new()
	smoke.name = "Smoke"
	smoke.position = SMOKE_AT
	smoke.amount = 24
	smoke.lifetime = 2.5
	smoke.direction = Vector3(0, 1, 0.3)
	smoke.spread = 25.0
	smoke.gravity = Vector3(0, 0.15, 0)
	smoke.initial_velocity_min = 0.1
	smoke.initial_velocity_max = 0.25
	smoke.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	smoke.emission_box_extents = Vector3(0.6, 0.01, 0.05)
	smoke.scale_amount_min = 0.6
	smoke.scale_amount_max = 1.4
	var puff := SphereMesh.new()
	puff.radius = 0.06
	puff.height = 0.12
	puff.radial_segments = 6
	puff.rings = 3
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.7, 0.7, 0.7, 0.4)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	puff.material = material
	smoke.mesh = puff
	return smoke
