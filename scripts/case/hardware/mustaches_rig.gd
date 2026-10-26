class_name MustachesRig
extends HardwareRig

## The deputy's mustaches (ferreteria.md, "Los bigotes del diputado"): at night Tobías sprays a big black mustache on
## every campaign poster of deputy Lustre in the neighborhood, with a stencil he cut himself, the main evidence. The
## store's own posters wear one too. In the workshop there's a puddle of black paint; a trail of black footprints goes
## from it out of the workshop, and the first pair is the story's own clue. A cop who steps in the puddle gets black
## soles: the next PAINT_STEPS steps leave footprints too. Every number here is (propuesta).

const POSTER := preload("res://assets/models/deputy_poster_mustache.glb")
const FOOTPRINTS_SCENE := preload("res://scenes/props/paint_footprints.tscn")
## The store's posters, sprayed: where they hang (their middle) and which way they face.
const POSTERS: Array[Array] = [
	[Vector3(2.0, 1.7, HardwareStore.SPLIT_Z + 0.08), 0.0], [Vector3(6.5, 1.7, HardwareStore.SPLIT_Z + 0.08), 0.0],
	[Vector3(-2.0, 1.6, HardwareStore.BACK_Z - 0.08), PI],
]
## The paint puddle in the workshop, and the trail of prints from it out the workshop door into the storeroom.
const PUDDLE_AT := Vector3(2.6, HardwareStore.FLOOR_TOP, -0.9)
const PUDDLE_RADIUS := 0.35
const TRAIL: Array[Vector3] = [
	Vector3(2.2, 0, -0.75), Vector3(1.85, 0, -0.5), Vector3(1.45, 0, -0.35), Vector3(1.05, 0, -0.25),
	Vector3(0.65, 0, -0.2), Vector3(0.25, 0, -0.05), Vector3(-0.15, 0, 0.1), Vector3(-0.55, 0, 0.25),
]
## The pair of prints you can look at, just inside the workshop door.
const CLUE_AT := Vector3(1.55, HardwareStore.FLOOR_TOP + 0.006, -0.4)
## Steps of black prints a cop leaves after stepping in the puddle, how far apart, and how many prints at most.
const PAINT_STEPS := 12
const STEP := 0.55
const MAX_PRINTS := 200
const PAINT := Color(0.04, 0.04, 0.04)

var footprints: ClueNote
var prints := 0
## Cop -> steps of paint left on their soles.
var soles := {}
var _last_print := {}
var _print_mesh: BoxMesh
var _print_look: StandardMaterial3D


func setup(place: HardwareStore) -> void:
	super.setup(place)
	_print_mesh = BoxMesh.new()
	_print_mesh.size = Vector3(0.09, 0.004, 0.24)
	_print_look = StandardMaterial3D.new()
	_print_look.albedo_color = PAINT
	for poster: Array in POSTERS:
		var look: Node3D = POSTER.instantiate()
		look.position = poster[0]
		look.rotation.y = poster[1]
		place.add_child(look)
	var puddle := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = PUDDLE_RADIUS
	disc.bottom_radius = PUDDLE_RADIUS
	disc.height = 0.006
	puddle.mesh = disc
	var gloss := StandardMaterial3D.new()
	gloss.albedo_color = PAINT
	gloss.roughness = 0.1
	puddle.material_override = gloss
	puddle.position = PUDDLE_AT + Vector3(0, 0.003, 0)
	place.add_child(puddle)
	for i in TRAIL.size():
		var ahead := (TRAIL[i + 1] if i + 1 < TRAIL.size() else TRAIL[i] * 2 - TRAIL[i - 1]) - TRAIL[i]
		_print(TRAIL[i] + Vector3(0, HardwareStore.FLOOR_TOP, 0), ahead, i % 2 == 0)
	footprints = FOOTPRINTS_SCENE.instantiate()
	footprints.text = tr("CLUE_PAINT_FOOTPRINTS")
	footprints.position = CLUE_AT
	footprints.rotation.y = Vector2(-1.0, 0.4).angle_to(Vector2.DOWN)
	place.add_child(footprints)
	footprints.read.connect(place.raid.add_clue)


## Whether `at` (on the floor) is in the puddle.
static func in_puddle(at: Vector3) -> bool:
	return Vector2(at.x - PUDDLE_AT.x, at.z - PUDDLE_AT.z).length() < PUDDLE_RADIUS and absf(at.y - PUDDLE_AT.y) < 0.5


func _physics_process(_delta: float) -> void:
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if not cop or cop.vehicle:
			continue
		var feet := cop.global_position
		if in_puddle(feet):
			if not soles.has(cop):
				cop.show_hint("HINT_PAINT_SOLES")
			soles[cop] = PAINT_STEPS
			_last_print[cop] = feet
			continue
		if soles.get(cop, 0) <= 0:
			continue
		var moved: Vector3 = feet - _last_print[cop]
		moved.y = 0
		if moved.length() >= STEP:
			step(cop, moved)


## One painted step of `cop`, heading `ahead`: a print where they stand, on alternating feet.
func step(cop: Cop, ahead: Vector3) -> void:
	soles[cop] -= 1
	_last_print[cop] = cop.global_position
	if prints < MAX_PRINTS:
		_print(cop.global_position + Vector3(0, 0.003, 0), ahead, soles[cop] % 2 == 0)


func _print(at: Vector3, ahead: Vector3, left: bool) -> void:
	prints += 1
	var mark := MeshInstance3D.new()
	mark.mesh = _print_mesh
	mark.material_override = _print_look
	var side := Vector3(ahead.z, 0, -ahead.x).normalized() * (0.07 if left else -0.07)
	mark.position = at + side + Vector3(0, 0.003, 0)
	mark.rotation.y = atan2(ahead.x, ahead.z)
	store.add_child(mark)
