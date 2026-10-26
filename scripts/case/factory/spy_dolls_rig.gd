class_name SpyDollsRig
extends FactoryRig

## The spy dolls (fabrica.md, "Los muñecos espías"): Fermín sells dolls with a microphone in the ear, and the tape
## recorder with what they heard is the main evidence, hidden with the box of microphones and the client list. MIC_DOLLS
## of the bin's finished dolls, drawn with the seed, carry a microphone: a cop's radio squeals by the closest one,
## and hearing it is the story's own clue. Every number here is (propuesta).

const MIC_DOLLS := 10
## A cop's radio squeals within this distance (m) of a doll with a microphone.
const SQUEAL_RANGE := 1.5
## How long a squeal shows, and how long a doll waits to squeal again.
const SQUEAL_TIME := 1.2
const SQUEAL_EVERY := 3.0

var mic_dolls: Array[Node3D] = []
## A cop heard a squeal already (the clue is given once).
var was_heard := false
var _wait := {}


func setup(place: DollFactory) -> void:
	super.setup(place)
	mic_dolls.assign(pick(place.case_seed, place.pile.size()).map(func(i: int) -> Node3D: return place.pile[i]))
	for doll: Node3D in mic_dolls:
		doll.set_meta("spy_mic", true)
		doll.add_child(_mic())
		var squeal := Label3D.new()
		squeal.name = "Squeal"
		squeal.text = "SPY_SQUEAL"
		squeal.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		squeal.pixel_size = 0.004
		squeal.outline_size = 8
		squeal.modulate = Color(1.0, 0.9, 0.3)
		squeal.position = Vector3(0, 0.35, 0)
		squeal.hide()
		doll.add_child(squeal)


## Which of `count` dolls carry a microphone, MIC_DOLLS of them drawn with the seed.
static func pick(case_seed: int, count: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed * 31 + 7
	var all: Array = range(count)
	var chosen := []
	for i in mini(MIC_DOLLS, count):
		chosen.append(all.pop_at(rng.randi_range(0, all.size() - 1)))
	return chosen


func _physics_process(delta: float) -> void:
	for doll in _wait.keys():
		_wait[doll] = maxf(_wait[doll] - delta, 0.0)
	# Each cop's radio squeals only by the closest doll with a microphone, so it points at one doll of the bin.
	for node in get_tree().get_nodes_in_group("cops"):
		var at := (node as Node3D).global_position
		var closest: Node3D
		for doll: Node3D in mic_dolls:
			if is_instance_valid(doll) and at.distance_to(doll.global_position) <= SQUEAL_RANGE and (closest == null
					or at.distance_to(doll.global_position) < at.distance_to(closest.global_position)):
				closest = doll
		if closest and _wait.get(closest, 0.0) <= 0.0:
			squeal(closest)


## The radio squeals next to `doll`: it shows over the doll, and the first one is the clue.
func squeal(doll: Node3D) -> void:
	_wait[doll] = SQUEAL_EVERY
	var label: Label3D = doll.get_node("Squeal")
	label.show()
	get_tree().create_timer(SQUEAL_TIME).timeout.connect(label.hide)
	if not was_heard:
		was_heard = true
		factory.raid.add_clue(tr("CLUE_SPY_FEEDBACK"))


## The microphone in the ear: a tiny black bead on the side of the head.
func _mic() -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 0.012
	mesh.height = 0.024
	mesh.radial_segments = 6
	mesh.rings = 3
	var bead := MeshInstance3D.new()
	bead.name = "SpyMic"
	bead.mesh = mesh
	bead.position = Vector3(0.05, 0.095, 0)
	var look := StandardMaterial3D.new()
	look.albedo_color = Color(0.08, 0.08, 0.1)
	bead.material_override = look
	return bead
