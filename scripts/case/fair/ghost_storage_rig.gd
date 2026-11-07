class_name GhostStorageRig
extends FairRig

## The ghost train storeroom (allanamiento-parque.md, "El tren fantasma depósito"): Don Tómbola keeps stolen phones in
## the dark tunnel, where nobody looks. The box of phones is hidden in a spot for heavy things, with the price list and
## the ghost's sheet with pockets. Every RING_EVERY seconds a phone rings inside the tunnel and its screen lights up on
## one of the skeletons (drawn with the seed); hearing it from close by is the story's own clue (on the checklist).
## Every number here is (propuesta).

const RING_EVERY := 15.0
const SCREEN_ON := 3.0
## A cop this close to the skeleton hears where the ringing comes from.
const HEAR := 5.0
const SCREEN_COLOR := Color(0.42, 0.72, 0.94)

## The skeleton with the phone, its lit screen and how many times it rang.
var ringer := -1
var screen: MeshInstance3D
var rings := 0
var heard := false
var _since_ring := 0.0


func setup(place: Fair) -> void:
	super.setup(place)
	ringer = hash(["ghost storage", place.case_seed]) % Fair.SKELETONS.size()
	screen = MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.07, 0.12, 0.07)
	screen.mesh = mesh
	var glow := StandardMaterial3D.new()
	glow.albedo_color = SCREEN_COLOR
	glow.emission_enabled = true
	glow.emission = SCREEN_COLOR
	glow.emission_energy_multiplier = 3.0
	screen.material_override = glow
	screen.position = Vector3(0.12, 1.2, 0.12)
	screen.visible = false
	place.skeletons[ringer].add_child(screen)


func _physics_process(delta: float) -> void:
	_since_ring += delta
	if _since_ring >= RING_EVERY:
		ring()


## The phone rings in the tunnel and its screen lights up for a while; a cop close by is the clue, once.
func ring() -> void:
	_since_ring = 0.0
	rings += 1
	var at := screen.global_position
	fair.raid.float_label(tr("FAIR_PHONE_RING"), at + Vector3.UP * 0.5, SCREEN_COLOR)
	screen.visible = true
	get_tree().create_timer(SCREEN_ON).timeout.connect(func() -> void: screen.visible = false)
	if heard:
		return
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(at) <= HEAR:
			heard = true
			fair.raid.add_clue(tr("CLUE_SKELETON_RINGS"))
			return
