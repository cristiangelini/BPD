class_name WindUpToy
extends StaticBody3D

## A wind-up toy let loose from a shelf of the toy store (allanamiento-jugueteria.md, "Lo que se dispara"): it walks
## in a straight line for WALK_SECONDS, turning off the walls it bumps, chirping, and a cop who runs over it trips.
## E turns it off. Every number here is (propuesta).

signal stopped(toy: WindUpToy)
signal tripped(cop: Cop)

const SIZE := Vector3(0.24, 0.3, 0.2)
const LAYER := 16
const SPEED := 0.8
const WALK_SECONDS := 20.0
## A cop moving faster than this within TRIP_RANGE trips over it, and can't trip again for TRIP_COOLDOWN.
const TRIP_SPEED := 2.5
const TRIP_RANGE := 0.5
const TRIP_SECONDS := 1.2
const TRIP_COOLDOWN := 1.5

var heading := Vector3.FORWARD
var walking := 0.0
var color := Color(0.91, 0.29, 0.23)
var _look: Node3D
var _trip_wait := 0.0


func _ready() -> void:
	# Its own layer: E finds it, but cops walk over it (and trip) instead of bumping into it.
	collision_layer = LAYER
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	_look = Node3D.new()
	add_child(_look)
	_part(Vector3(0, 0.1, 0), Vector3(SIZE.x, 0.2, SIZE.z), color)
	_part(Vector3(0, 0.25, 0), Vector3(0.16, 0.1, 0.14), color.lightened(0.3))
	_part(Vector3(SIZE.x / 2 + 0.03, 0.12, 0), Vector3(0.04, 0.08, 0.02), Color(0.75, 0.75, 0.8))


## Sets it walking toward `toward` (flattened) for WALK_SECONDS.
func start(toward: Vector3) -> void:
	heading = Vector3(toward.x, 0, toward.z).normalized()
	walking = WALK_SECONDS
	rotation.y = atan2(heading.x, heading.z)


func is_walking() -> bool:
	return walking > 0.0


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TOY_OFF" if is_walking() else ""


## E: turns it off where it stands.
func use(_cop: Cop) -> void:
	if not is_walking():
		return
	_stop()


func _physics_process(delta: float) -> void:
	_trip_wait = maxf(_trip_wait - delta, 0.0)
	if not is_walking():
		return
	walking -= delta
	var ahead := global_position + Vector3.UP * 0.15
	var query := PhysicsRayQueryParameters3D.create(ahead, ahead + heading * (SIZE.z / 2 + 0.12), 1, [get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var bounced := heading.bounce(hit.normal)
		bounced.y = 0.0
		heading = bounced.normalized() if bounced.length() > 0.1 else -heading
		rotation.y = atan2(heading.x, heading.z)
	global_position += heading * SPEED * delta
	_look.rotation.z = sin(walking * 14.0) * 0.12
	_check_trip()
	if walking <= 0.0:
		_stop()


func _check_trip() -> void:
	if _trip_wait > 0.0:
		return
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		var flat := Vector2(cop.velocity.x, cop.velocity.z).length()
		var d := Vector2(cop.global_position.x - global_position.x, cop.global_position.z - global_position.z).length()
		if flat > TRIP_SPEED and d < TRIP_RANGE and not cop.vehicle:
			trip(cop)
			return


## `cop` ran over it: a stumble like the cat's.
func trip(cop: Cop) -> void:
	_trip_wait = TRIP_COOLDOWN
	cop.stagger(TRIP_SECONDS)
	cop.show_hint("HINT_TRIPPED_TOY")
	tripped.emit(cop)


func _stop() -> void:
	walking = 0.0
	_look.rotation.z = 0.0
	stopped.emit(self)


func _part(at: Vector3, size: Vector3, part_color: Color) -> void:
	var look := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	look.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = part_color
	look.material_override = material
	look.position = at
	_look.add_child(look)
