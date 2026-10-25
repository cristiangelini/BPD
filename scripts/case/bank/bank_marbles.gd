class_name BankMarbles
extends Node3D

## The duck grandma's marbles (robo-banco-abuelos.md, step 3, decision 122): a handful spilled on the hall's floor in
## front of the entrance. A cop who runs over them slips: falls forward and stays down SLIP_TIME seconds (like after
## missing with the ram); walking or crouched, nothing happens. They stay on the floor for the rest of the case. Every
## number here is (propuesta).

signal slipped(cop: Cop)

const RADIUS := 1.1
const COUNT := 36
const SLIP_TIME := 2.0
## Faster than walking is running; the push forward of the fall (m/s) and how long until the same cop slips again.
const RUN_OVER := GameScale.WALK_SPEED + 0.5
const SLIP_PUSH := 3.0
const SLIP_AGAIN := 3.0
const COLORS: Array[Color] = [Color(0.2, 0.45, 0.95), Color(0.95, 0.3, 0.3), Color(0.3, 0.85, 0.4), Color(0.98, 0.8, 0.2),
	Color(0.85, 0.85, 0.95)]

## Cop -> seconds until they can slip again.
var _again := {}


func _ready() -> void:
	add_to_group("bank_marbles")
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["bank marbles", COUNT])
	var mesh := SphereMesh.new()
	mesh.radius = 0.035
	mesh.height = 0.07
	mesh.radial_segments = 6
	mesh.rings = 3
	for i in COUNT:
		var marble := MeshInstance3D.new()
		marble.mesh = mesh
		var glass := StandardMaterial3D.new()
		glass.albedo_color = COLORS[i % COLORS.size()]
		glass.metallic = 0.3
		glass.roughness = 0.1
		marble.material_override = glass
		var at := Vector2.from_angle(rng.randf() * TAU) * sqrt(rng.randf()) * RADIUS
		marble.position = Vector3(at.x, 0.035, at.y)
		add_child(marble)
		# They roll out from where the handful landed.
		var from := marble.position * 0.15
		marble.position = from
		create_tween().tween_property(marble, "position", Vector3(at.x, 0.035, at.y), 0.6 + rng.randf() * 0.6) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


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
	cop.show_hint("HINT_BANK_MARBLES")
	slipped.emit(cop)
