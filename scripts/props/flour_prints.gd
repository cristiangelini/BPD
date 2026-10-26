class_name FlourPrints
extends Node3D

## The flour on the cake lab's floor (docs/diseno/laboratorio.md, "Las bolsas de harina"): every burst sack leaves a
## white patch for PATCH_TIME seconds, a cop who walks into one is floured for FLOURED_TIME seconds, and a floured
## cop leaves a white footprint every STEP metres, each one lasting PRINT_LIFE seconds. Only a joke for now; a story
## turns it into a clue (the gold flour, step 5). Every PC prints its own cops. Every number here is (propuesta).

signal floured(cop: Cop)

const PATCH_RADIUS := 1.0
const PATCH_TIME := 40.0
const FLOURED_TIME := 15.0
const STEP := 0.6
const PRINT_LIFE := 20.0
const MAX_PRINTS := 150
const PRINT_SIZE := Vector3(0.12, 0.004, 0.26)
const FLOUR := Color(0.97, 0.96, 0.92)

## Each patch: [where on the floor, seconds left].
var patches: Array = []
## Cop -> seconds of flour left on their boots.
var floured_left := {}
## Each footprint: [the mesh, seconds left].
var prints: Array = []
var _last_print := {}
var _print_mesh: BoxMesh


func _ready() -> void:
	_print_mesh = BoxMesh.new()
	_print_mesh.size = PRINT_SIZE
	var material := StandardMaterial3D.new()
	material.albedo_color = FLOUR
	_print_mesh.material = material


## A sack burst: flour on the floor at `at`.
func spill(at: Vector3) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = PATCH_RADIUS
	mesh.bottom_radius = PATCH_RADIUS
	mesh.height = 0.01
	mesh.radial_segments = 16
	var material := StandardMaterial3D.new()
	material.albedo_color = FLOUR
	mesh.material = material
	var patch := MeshInstance3D.new()
	patch.mesh = mesh
	add_child(patch)
	patch.global_position = at + Vector3.UP * 0.008
	patches.append([at, PATCH_TIME, patch])


func is_floured(cop: Cop) -> bool:
	return floured_left.get(cop, 0.0) > 0.0


func on_flour(at: Vector3) -> bool:
	for patch: Array in patches:
		var center: Vector3 = patch[0]
		if Vector2(at.x - center.x, at.z - center.z).length() < PATCH_RADIUS and absf(at.y - center.y) < 0.5:
			return true
	return false


func _physics_process(delta: float) -> void:
	for i in range(patches.size() - 1, -1, -1):
		patches[i][1] -= delta
		if patches[i][1] <= 0.0:
			(patches[i][2] as Node).queue_free()
			patches.remove_at(i)
	for i in range(prints.size() - 1, -1, -1):
		prints[i][1] -= delta
		if prints[i][1] <= 0.0:
			(prints[i][0] as Node).queue_free()
			prints.remove_at(i)
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if not cop or cop.vehicle:
			continue
		_step(cop, delta)


func _step(cop: Cop, delta: float) -> void:
	var feet := cop.global_position
	if on_flour(feet):
		if not is_floured(cop):
			cop.show_hint("HINT_FLOURED")
			floured.emit(cop)
		floured_left[cop] = FLOURED_TIME
		_last_print[cop] = feet
		return
	if not is_floured(cop):
		return
	floured_left[cop] -= delta
	var last: Vector3 = _last_print.get(cop, feet)
	var walked := Vector2(feet.x - last.x, feet.z - last.z)
	if walked.length() >= STEP:
		_print(feet, walked.normalized())
		_last_print[cop] = feet


func _print(at: Vector3, ahead: Vector2) -> void:
	if prints.size() >= MAX_PRINTS:
		(prints[0][0] as Node).queue_free()
		prints.remove_at(0)
	var mark := MeshInstance3D.new()
	mark.mesh = _print_mesh
	add_child(mark)
	mark.global_position = at + Vector3.UP * 0.006
	mark.rotation.y = atan2(ahead.x, ahead.y)
	prints.append([mark, PRINT_LIFE])
