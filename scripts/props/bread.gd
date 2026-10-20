class_name Bread
extends Grabbable

## One of the bakery's 40 loaves (docs/diseno/panaderia.md, "El anillo en el pan"). There's no button to split it:
## it splits when it's pulled apart, by two cops pulling its ends or by one cop pulling it while it's stuck against
## something. A hard hit squashes it instead. Either way it's a broken loaf: a fine, like the grandpa's ornaments.
## A loaf can hide something inside (`filling`): it feels heavier when grabbed and drops it when it breaks.

signal broken(at: Vector3)

## A hand pulling this far from the loaf while the loaf barely moves splits it, after SPLIT_TIME (propuesta).
const SPLIT_STRETCH := 0.5
const STUCK_SPEED := 0.6
const SPLIT_TIME := 0.25
## A hit harder than this squashes it (propuesta: a throw at a wall does, a drop from the shelf doesn't).
const SQUASH_SPEED := 4.5
const FINE := 20
const HALF_MODEL := preload("res://assets/models/bread_half.glb")
const HALF_LIFE := 20.0

## What a half looks like and its box (a sweet bread splits into round halves).
@export var half_model: PackedScene = HALF_MODEL
@export var half_size := Vector3(0.17, 0.13, 0.15)

## What it hides, kept out of the tree until the loaf breaks; null for a plain loaf.
var filling: Node3D
## Whether the filling gives itself away by its weight (a slip of paper doesn't).
var feels_heavy := true
var is_broken := false
var _stretched := 0.0
var _impacts := ImpactTracker.new()


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4


## Puts `item` inside: the loaf weighs that much more, and with `heavy` it feels heavier when grabbed.
func stuff(item: Node3D, heavy := true) -> void:
	filling = item
	feels_heavy = heavy
	if item is RigidBody3D:
		mass += (item as RigidBody3D).mass * 4.0


func hold(holder_id: int, point: Vector3) -> void:
	var first := not holders.has(holder_id)
	super.hold(holder_id, point)
	if first and filling and feels_heavy:
		var grabber := instance_from_id(holder_id) as Node
		if grabber and grabber.get_parent() is Cop:
			(grabber.get_parent() as Cop).show_hint("HINT_HEAVY_BREAD")


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_broken or holders.is_empty():
		_stretched = 0.0
		return
	var pulled := false
	for point: Vector3 in holders.values():
		pulled = pulled or point.distance_to(global_position) > SPLIT_STRETCH
	_stretched = _stretched + delta if pulled and linear_velocity.length() < STUCK_SPEED else 0.0
	if _stretched >= SPLIT_TIME:
		split()


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var speed := _impacts.hardest(state)
	if speed > SQUASH_SPEED:
		squash.call_deferred()


## Pulled apart: two halves and, if it hid something, the thing drops out.
func split() -> void:
	if is_broken:
		return
	for side: float in [-1.0, 1.0]:
		_half(side)
	_break(Vector3.ZERO)


## Given to someone who eats it (the gossiping customer): no fine, but whatever it hid comes out.
func eaten() -> void:
	if is_broken:
		return
	is_broken = true
	for holder: int in holders.keys():
		var grabber := instance_from_id(holder) as Grabber
		if grabber:
			grabber.release()
	_drop_filling(Vector3.ZERO)
	queue_free()


## Hit too hard: flattened, and whatever it hid flies out with it.
func squash() -> void:
	if is_broken:
		return
	(_half(0.0).get_child(1) as Node3D).scale = Vector3(1.6, 0.35, 1.3)
	_break(linear_velocity)


func _break(push: Vector3) -> void:
	is_broken = true
	for holder: int in holders.keys():
		var grabber := instance_from_id(holder) as Grabber
		if grabber:
			grabber.release()
	_drop_filling(push)
	broken.emit(global_position)
	queue_free()


func _drop_filling(push: Vector3) -> void:
	if not filling:
		return
	get_parent().add_child(filling)
	filling.global_position = global_position + Vector3.UP * 0.1
	if filling is RigidBody3D:
		(filling as RigidBody3D).linear_velocity = push + Vector3.UP
	filling = null


## A half loaf left on the floor for a while (just to look at: it can be grabbed and thrown, nothing more).
func _half(side: float) -> Grabbable:
	var half := Grabbable.new()
	half.mass = 0.2
	half.collision_layer = collision_layer
	half.collision_mask = collision_mask
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = half_size
	shape.shape = box
	half.add_child(shape)
	var look: Node3D = half_model.instantiate()
	look.rotation.y = PI if side < 0.0 else 0.0
	half.add_child(look)
	get_parent().add_child(half)
	half.global_transform = global_transform.translated_local(Vector3(side * half_size.x * 0.6, 0, 0))
	half.linear_velocity = global_basis.x * side * 0.8 + Vector3.UP * 0.5
	half.get_tree().create_timer(HALF_LIFE).timeout.connect(half.queue_free)
	return half
