class_name SpilledScrews
extends Node3D

## A drawerful of screws spilled on the floor (ferreteria.md, "Tornillos de oro"): a cop who runs over them slips like
## on the bank's marbles (BankMarbles): falls forward and stays down SLIP_TIME seconds; walking or crouched, nothing
## happens. They stay there for the rest of the case. Every number here is (propuesta).

signal slipped(cop: Cop)

const RADIUS := 0.5
const COUNT := 24
const SLIP_TIME := 2.0
const RUN_OVER := GameScale.WALK_SPEED + 0.5
const SLIP_PUSH := 3.0
const SLIP_AGAIN := 3.0

## Cop -> seconds until they can slip again.
var _again := {}


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["spilled screws", COUNT])
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.006
	mesh.bottom_radius = 0.006
	mesh.height = 0.05
	mesh.radial_segments = 4
	mesh.rings = 1
	var steel := StandardMaterial3D.new()
	steel.albedo_color = Color(0.6, 0.63, 0.68)
	steel.metallic = 0.6
	for i in COUNT:
		var screw := MeshInstance3D.new()
		screw.mesh = mesh
		screw.material_override = steel
		var at := Vector2.from_angle(rng.randf() * TAU) * sqrt(rng.randf()) * RADIUS
		screw.position = Vector3(at.x, 0.006, at.y)
		screw.rotation = Vector3(PI / 2, rng.randf() * TAU, 0)
		add_child(screw)


## Whether `cop` is on them.
func under(cop: Node3D) -> bool:
	return Vector2(cop.global_position.x - global_position.x, cop.global_position.z - global_position.z).length() < RADIUS \
		and absf(cop.global_position.y - global_position.y) < 1.0


func _physics_process(delta: float) -> void:
	for seen: Variant in _again.keys():
		_again[seen] -= delta
		if not is_instance_valid(seen) or _again[seen] <= 0.0:
			_again.erase(seen)
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if not cop or cop.vehicle or _again.has(cop) or cop.is_crouching or not under(cop):
			continue
		var flat := Vector3(cop.velocity.x, 0, cop.velocity.z)
		if flat.length() > RUN_OVER:
			slip(cop, flat.normalized())


## `cop` slips heading `ahead`: pushed forward and down for SLIP_TIME.
func slip(cop: Cop, ahead: Vector3) -> void:
	_again[cop] = SLIP_AGAIN
	cop.knock_back(ahead * SLIP_PUSH, SLIP_TIME)
	cop.show_hint("HINT_SCREWS_SLIP")
	slipped.emit(cop)
