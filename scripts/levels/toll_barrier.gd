class_name TollBarrier
extends Node3D

## One toll barrier across one side of the highway (persecucion-lugares.md, "En la autopista"): a vehicle that stops
## (under 10 km/h) by the booth gets the arm lifted; one that drives into the lowered arm breaks it, and the arm lies on
## the road until a new one goes up. The barrier never stops anyone. Its +X runs across the road, from the median
## to the guardrail; +Z along it. Every number here is (propuesta).

signal broken(by: Node3D)

const SLOW := 10.0 / 3.6
## The arm stays up this long after the last slow vehicle, and a broken one is replaced after this long.
const OPEN_SECONDS := 4.0
const REPLACE_SECONDS := 20.0
## The arm across the road and the stretch around it where stopping lifts it.
const SPAN := HighwayLayout.LANE * 2
const ZONE_LENGTH := 16.0
const ARM_HEIGHT := 1.1
const LIFT_RATE := 3.0

var is_open := false
var is_broken := false
var _open_for := 0.0
var _broken_for := 0.0
var _zone: Area3D
var _hit: Area3D
var _arm: Node3D
var _fallen: Node3D


func _ready() -> void:
	add_to_group("toll_barriers")
	var post := _box(Vector3(0.25, 0.7, 0.25), Color(0.95, 0.8, 0.2))
	post.position = Vector3(SPAN / 2 - 0.2, 0.35, 0)
	add_child(post)
	_arm = Node3D.new()
	_arm.position = Vector3(SPAN / 2 - 0.2, ARM_HEIGHT, 0)
	add_child(_arm)
	for k in 6:
		var stripe := _box(Vector3(SPAN / 6, 0.14, 0.1), Color(0.9, 0.15, 0.12) if k % 2 == 0 else Color.WHITE)
		stripe.position = Vector3(-(k + 0.5) * SPAN / 6, 0, 0)
		_arm.add_child(stripe)
	_fallen = _box(Vector3(SPAN * 0.9, 0.14, 0.1), Color(0.9, 0.15, 0.12))
	_fallen.position = Vector3(0, 0.07, 1.6)
	_fallen.rotation.y = 0.35
	_fallen.hide()
	add_child(_fallen)
	_zone = _area(Vector3(SPAN, 3, ZONE_LENGTH))
	_hit = _area(Vector3(SPAN, 3, 1.2))


func _physics_process(delta: float) -> void:
	if is_broken:
		_broken_for += delta
		if _broken_for >= REPLACE_SECONDS:
			_replace()
		return
	_open_for = maxf(0.0, _open_for - delta)
	for body in _zone.get_overlapping_bodies():
		if _is_vehicle(body) and speed_of(body) < SLOW:
			_open_for = OPEN_SECONDS
	is_open = _open_for > 0.0
	_arm.rotation.z = move_toward(_arm.rotation.z, -PI / 2 if is_open else 0.0, LIFT_RATE * delta)
	if absf(_arm.rotation.z) > PI / 4:
		return
	for body in _hit.get_overlapping_bodies():
		if _is_vehicle(body) and speed_of(body) >= SLOW:
			_break(body)
			return


static func speed_of(body: Node3D) -> float:
	if body is RigidBody3D:
		return (body as RigidBody3D).linear_velocity.length()
	if body is CharacterBody3D:
		return Vector2((body as CharacterBody3D).velocity.x, (body as CharacterBody3D).velocity.z).length()
	return 0.0


func _is_vehicle(body: Node3D) -> bool:
	return body is VehicleBody3D or body is SuspectCar


func _break(by: Node3D) -> void:
	is_broken = true
	_broken_for = 0.0
	_arm.hide()
	_fallen.show()
	broken.emit(by)


func _replace() -> void:
	is_broken = false
	_open_for = 0.0
	_arm.rotation.z = 0.0
	_arm.show()
	_fallen.hide()


func _area(size: Vector3) -> Area3D:
	var area := Area3D.new()
	area.monitorable = false
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = Vector3(0, size.y / 2, 0)
	area.add_child(shape)
	add_child(area)
	return area


static func _box(size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material = material
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	return instance
