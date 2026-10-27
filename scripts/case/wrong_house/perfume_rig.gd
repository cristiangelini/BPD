class_name WhPerfumeRig
extends WrongHouseRig

## The fake perfume (casa-equivocada.md, "El perfume trucho"): Madame Aroma bottles fake perfume. The jug (12 kg,
## fragile) is the main evidence; the fake labels and the sample bottle are the extras. The story's own clue: smell
## lines in her hallway, seen only in a flashlight's beam. Whoever cracks the jug or the sample bottle smells of it for
## SMELL seconds, and the DOGS street dogs follow them around. Every number here is (propuesta).

const DOG_MODELS: Array[PackedScene] = [preload("res://assets/models/dog_0.glb"),
	preload("res://assets/models/dog_2.glb"), preload("res://assets/models/dog_4.glb")]
const SMELL := 30.0
const DOGS := 3
const DOG_SPEED := 3.0
const DOG_KEEP := 1.2
const REPATH := 0.5
## Where the street dogs lie, on the sidewalk in front of the lot (place space).
const DOG_HOMES: Array[Vector3] = [Vector3(-8.0, 0.0, WrongHouse.LOT_Z + 2.2), Vector3(0.0, 0.0, WrongHouse.LOT_Z + 2.4),
	Vector3(8.0, 0.0, WrongHouse.LOT_Z + 2.2)]
## The smell lines down her hallway (house space).
const LINES: Array[Vector3] = [Vector3(-0.5, 1.0, -3.0), Vector3(-0.3, 1.1, -1.8), Vector3(-0.6, 0.9, -0.6),
	Vector3(-0.4, 1.0, 0.6)]

var jug: Evidence
var flask: Evidence
var lines: Array[MeshInstance3D] = []
var lines_seen := false
## Cop -> seconds of smell left.
var smelly := {}
var dogs: Array[Node3D] = []
var _paths: Array[PackedVector3Array] = []
var _repath := 0.0


func setup(wrong_house: WrongHouse) -> void:
	super.setup(wrong_house)
	jug = place.main
	flask = place.extras[1]
	for item: Evidence in [jug, flask]:
		item.damaged.connect(_cracked.bind(item).unbind(1))
	for at in LINES:
		var line := patch(place, WrongHouse.at(place.guilty, at), Vector3(0.03, 0.6, 0.03), Color(0.75, 0.95, 0.4))
		line.rotation.z = 0.3
		line.hide()
		lines.append(line)
	for i in DOGS:
		var dog: Node3D = DOG_MODELS[i].instantiate()
		dog.position = DOG_HOMES[i]
		place.add_child(dog)
		dogs.append(dog)
		_paths.append(PackedVector3Array())


## It cracked: whoever handled it (or the nearest cop) smells of it.
func _cracked(item: Evidence) -> void:
	var cops := item.handling_cops(2.0)
	if cops.is_empty():
		var nearest := _nearest_cop(item.global_position, 3.0)
		if nearest:
			cops.append(nearest)
	for cop in cops:
		if not smelly.has(cop):
			cop.show_hint("HINT_WH_SMELLY")
		smelly[cop] = SMELL


func _physics_process(delta: float) -> void:
	if not lines_seen and _lit():
		reveal_lines()
	for cop: Cop in smelly.keys():
		smelly[cop] -= delta
		if smelly[cop] <= 0.0 or not is_instance_valid(cop):
			smelly.erase(cop)
	_walk_dogs(delta)


## A cop's flashlight beam on one of the lines.
func _lit() -> bool:
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if not cop.belt or not cop.belt.flashlight:
			continue
		for line in lines:
			if cop.belt.flashlight.lights(line.global_position):
				return true
	return false


func reveal_lines() -> void:
	lines_seen = true
	for line in lines:
		line.show()
	place._on_clue(tr("CLUE_WH_SMELL"))


## Each dog goes after the nearest smelly cop and stays DOG_KEEP from them, each at its own side; with nobody
## smelly, back to its spot on the sidewalk.
func _walk_dogs(delta: float) -> void:
	_repath -= delta
	var map := place.get_world_3d().navigation_map
	for i in dogs.size():
		var dog := dogs[i]
		var goal := DOG_HOMES[i]
		var chased := _nearest_smelly(dog.global_position)
		if chased:
			# Each one at its own side of them, so they don't pile up.
			goal = chased.global_position + Vector3(DOG_KEEP, 0, 0).rotated(Vector3.UP, TAU * i / DOGS)
		if _repath <= 0.0:
			_paths[i] = NavigationServer3D.map_get_path(map, dog.global_position, goal, true)
		var path := _paths[i]
		while path.size() > 1 and Vector2(path[0].x - dog.global_position.x, path[0].z - dog.global_position.z).length() < 0.2:
			path.remove_at(0)
		_paths[i] = path
		# Off the navigation mesh (the sidewalk), the path stops short: then straight there.
		var next := goal
		if path.size() > 0 and Vector2(path[-1].x - goal.x, path[-1].z - goal.z).length() < 0.5:
			next = path[0]
		var flat := Vector3(goal.x - dog.global_position.x, 0, goal.z - dog.global_position.z)
		if flat.length() <= 0.1:
			continue
		var step := Vector3(next.x - dog.global_position.x, next.y - dog.global_position.y, next.z - dog.global_position.z)
		dog.global_position += step.limit_length(DOG_SPEED * delta)
		if Vector2(step.x, step.z).length() > 0.01:
			dog.rotation.y = atan2(step.x, step.z)
	if _repath <= 0.0:
		_repath = REPATH


func _nearest_smelly(from: Vector3) -> Cop:
	var best: Cop
	var best_distance := INF
	for cop: Cop in smelly:
		var d := from.distance_to(cop.global_position)
		if d < best_distance:
			best = cop
			best_distance = d
	return best


func _nearest_cop(from: Vector3, within: float) -> Cop:
	var best: Cop
	var best_distance := within
	for node in get_tree().get_nodes_in_group("cops"):
		var d := from.distance_to((node as Node3D).global_position)
		if d < best_distance:
			best = node
			best_distance = d
	return best
