class_name PiggyBankRig
extends FarmRaidRig

## The piggy bank (allanamiento-granja.md, "El chancho alcancía"): Don Florencio buried a piggy bank full of stolen
## jewels in the pigsty's mud, and the pigs keep digging. It starts buried (out of sight and out of reach); every
## DIG_EVERY seconds a pig brings one buried thing up to the surface: an old boot, a tin can or the piggy bank, in an
## order drawn with the seed. One of the pigs wears a shiny ring on its snout: a close look at it (E on the pig) is the
## story's own clue. Every number here is (propuesta).

signal dug_up(thing: RigidBody3D)

const DIG_EVERY := 40.0
const JUNK := [preload("res://assets/models/mud_boot.glb"), preload("res://assets/models/mud_can.glb")]
const JUNK_KG := 0.5
const RING_GOLD := Color(1.0, 0.8, 0.2)

## What's still under the mud, the next one to come up first.
var buried: Array[RigidBody3D] = []
## How many things the pigs have dug up.
var dug := 0
var ringed: FarmPig
var _clue_given := false
var _dig_left := DIG_EVERY


func setup(place: FarmRaid) -> void:
	super.setup(place)
	for model: PackedScene in JUNK:
		var junk := Grabbable.new()
		junk.mass = JUNK_KG
		junk.collision_layer = 4
		junk.collision_mask = 15
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(0.3, 0.12, 0.2)
		shape.shape = box
		shape.position.y = 0.06
		junk.add_child(shape)
		junk.add_child(model.instantiate())
		junk.position = place.to_local(place.main.global_position)
		place.add_child(junk)
		buried.append(junk)
	buried.insert(place.case_seed % (JUNK.size() + 1), place.main)
	for thing in buried:
		_bury(thing)
	ringed = place.pigs[place.case_seed % place.pigs.size()]
	ringed.add_child(_ring())
	for pig in place.pigs:
		pig.looked.connect(_on_looked.bind(pig))


## A gold ring hanging from the snout (the pig faces +Z, its snout at 0.4 m up).
func _ring() -> MeshInstance3D:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.035
	torus.outer_radius = 0.05
	var material := StandardMaterial3D.new()
	material.albedo_color = RING_GOLD
	material.metallic = 0.8
	material.roughness = 0.2
	material.emission_enabled = true
	material.emission = RING_GOLD * 0.4
	torus.material = material
	ring.mesh = torus
	ring.name = "Ring"
	ring.position = Vector3(0, 0.32, 0.6)
	ring.rotation.x = PI / 2
	return ring


## Out of sight and out of reach under the mud.
func _bury(thing: RigidBody3D) -> void:
	thing.freeze = true
	thing.visible = false
	thing.set_meta("buried_layer", thing.collision_layer)
	thing.collision_layer = 0


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server() or buried.is_empty():
		return
	_dig_left -= delta
	if _dig_left <= 0.0:
		_dig_left = DIG_EVERY
		dig()


## A pig brings the next buried thing up, in front of its snout.
func dig() -> RigidBody3D:
	if buried.is_empty():
		return null
	var thing: RigidBody3D = buried.pop_front()
	var pig := farm.pigs[dug % farm.pigs.size()]
	dug += 1
	thing.global_position = pig.global_position + pig.global_basis.z * 0.7 + Vector3.UP * 0.3
	thing.collision_layer = thing.get_meta("buried_layer")
	thing.visible = true
	thing.freeze = false
	thing.linear_velocity = Vector3.UP * 2.0
	farm.raid.float_label(tr("FARM_PIG_DUG"), pig.global_position + Vector3.UP * 1.2, Color(0.75, 0.55, 0.35))
	dug_up.emit(thing)
	return thing


func _on_looked(_cop: Cop, pig: FarmPig) -> void:
	if pig != ringed or _clue_given:
		return
	_clue_given = true
	farm.raid.add_clue(tr("CLUE_PIG_RING"))


func net_state() -> Variant:
	return dug


func apply_net_state(state: Variant) -> void:
	while dug < int(state) and not buried.is_empty():
		dig()
