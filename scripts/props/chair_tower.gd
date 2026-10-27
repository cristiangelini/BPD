class_name ChairTower
extends StaticBody3D

## The furniture store's tower of stacked chairs (docs/diseno/allanamiento-muebleria.md, step 1b): 12 dining chairs,
## each one nested 0.12 m over the one below. A cop walking into it or something thrown at it brings the whole tower
## down: the stack goes and the 12 chairs fly loose, away from whoever pushed, and stay as chairs anyone can carry.
## Every number here is (propuesta).

signal fell

const CHAIR_MODEL := preload("res://assets/models/dining_chair.glb")
const CHAIRS := 12
const NEST := 0.12
const CHAIR_SIZE := Vector3(0.45, 0.92, 0.45)
const CHAIR_KG := 4.0
## A thrown prop this fast knocks it down; a slower one just rests against it.
const KNOCK_SPEED := 1.5
## How hard the chairs fly out: forward from the push, more the higher they were.
const SPREAD_SPEED := 1.0
const LIFT_SPEED := 1.5

var has_fallen := false
## The loose chairs, once it fell.
var chairs: Array[Grabbable] = []


func _ready() -> void:
	var tall := CHAIR_SIZE.y + NEST * (CHAIRS - 1)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(CHAIR_SIZE.x, tall, CHAIR_SIZE.z)
	shape.shape = box
	shape.position = Vector3(0, tall / 2, 0)
	add_child(shape)
	for i in CHAIRS:
		var look: Node3D = CHAIR_MODEL.instantiate()
		look.name = "Stacked%d" % i
		look.position = Vector3(0, NEST * i, 0)
		look.rotation.y = (i % 3 - 1) * 0.05
		add_child(look)
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 6
	var around := CollisionShape3D.new()
	var bigger := BoxShape3D.new()
	bigger.size = box.size + Vector3(0.3, 0, 0.3)
	around.shape = bigger
	around.position = shape.position
	area.add_child(around)
	add_child(area)
	area.body_entered.connect(_on_touched)


func _on_touched(body: Node3D) -> void:
	if body is Cop:
		knock_over(global_position - body.global_position)
	elif body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > KNOCK_SPEED:
		knock_over((body as RigidBody3D).linear_velocity)


## Brings it down toward `away` (flat): the stack goes and the chairs fly loose.
func knock_over(away: Vector3) -> void:
	if has_fallen:
		return
	has_fallen = true
	away.y = 0.0
	away = away.normalized() if away.length() > 0.01 else Vector3.FORWARD
	var parent := get_parent()
	for i in CHAIRS:
		var chair := Grabbable.new()
		chair.name = "LooseChair%d" % i
		chair.collision_layer = 4
		chair.collision_mask = 15
		chair.mass = CHAIR_KG
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = CHAIR_SIZE
		shape.shape = box
		chair.add_child(shape)
		var look: Node3D = CHAIR_MODEL.instantiate()
		look.position = Vector3(0, -CHAIR_SIZE.y / 2, 0)
		chair.add_child(look)
		parent.add_child(chair)
		# Laid out along the fall in two rows, so they don't start inside each other: 3 m at most.
		var side := away.cross(Vector3.UP) * (0.5 if i % 2 == 0 else -0.5)
		chair.global_position = global_position + Vector3(0, CHAIR_SIZE.y / 2 + NEST * i, 0) + away * (0.3 + i * 0.25) + side
		chair.linear_velocity = away * SPREAD_SPEED * (1.0 + i * 0.05) + Vector3.UP * LIFT_SPEED
		chair.angular_velocity = Vector3(away.z, 0.5, -away.x) * 2.0
		chairs.append(chair)
	# The stack itself goes: no more box to bump into, nor chairs drawn on it.
	for child in get_children():
		if child is CollisionShape3D:
			(child as CollisionShape3D).set_deferred("disabled", true)
		elif child is Area3D:
			child.queue_free()
		elif child is Node3D:
			(child as Node3D).visible = false
	fell.emit()
