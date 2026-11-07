class_name GiantPizzaDoor
extends Node3D

## The giant pizza "Récord del barrio" hanging on the pizzeria's dining room wall (allanamiento-pizzeria.md, "La pizza
## gigante"), hinged on its left edge over the safe's window. When it can swing (the giant pizza story), a cop running
## into it, or something thrown at it, faster than PUSH_SPEED turns it like a door and shows the safe. Every number
## here is (propuesta).

signal swung

const MODEL := preload("res://assets/models/giant_pizza_door.glb")
const DIAMETER := 1.5
const THICKNESS := 0.08
## Walking (4 m/s) is not enough: it needs a run or a throw.
const PUSH_SPEED := 5.0
const SWING := deg_to_rad(100.0)
const SWING_TIME := 0.6

## Only in the giant pizza story; otherwise it's just a pizza on the wall.
var can_swing := false
var is_open := false
var panel: AnimatableBody3D
var _front: Area3D


func _ready() -> void:
	panel = AnimatableBody3D.new()
	panel.sync_to_physics = false
	add_child(panel)
	var shape := CollisionShape3D.new()
	var disc := CylinderShape3D.new()
	disc.radius = DIAMETER / 2
	disc.height = THICKNESS
	shape.shape = disc
	shape.position = Vector3(DIAMETER / 2, 0, THICKNESS / 2)
	shape.rotation.x = PI / 2
	panel.add_child(shape)
	panel.add_child(MODEL.instantiate())
	var sign_label := Label3D.new()
	sign_label.text = "GIANT_PIZZA_SIGN"
	sign_label.pixel_size = 0.004
	sign_label.outline_size = 10
	sign_label.modulate = Color(1.0, 0.9, 0.4)
	# On the wall above it, so it stays when the pizza swings.
	sign_label.position = Vector3(DIAMETER / 2, DIAMETER / 2 + 0.15, 0.03)
	sign_label.double_sided = false
	add_child(sign_label)
	# What runs into it: a box just in front of the pizza.
	_front = Area3D.new()
	_front.collision_layer = 0
	_front.collision_mask = 2 | 4
	var reach := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(DIAMETER, DIAMETER, 0.5)
	reach.shape = box
	reach.position = Vector3(DIAMETER / 2, 0, THICKNESS + 0.25)
	_front.add_child(reach)
	add_child(_front)
	_front.body_entered.connect(_on_hit)


## Only what comes at the wall counts, not what runs along it.
func _on_hit(body: Node3D) -> void:
	var velocity := Vector3.ZERO
	if body is Cop:
		velocity = (body as Cop).velocity
	elif body is RigidBody3D:
		velocity = (body as RigidBody3D).linear_velocity
	var toward := -velocity.dot(global_basis.z)
	if toward >= PUSH_SPEED and multiplayer.is_server():
		swing_open()


## Turns on its hinge into the dining room, once, showing the safe behind it.
func swing_open() -> void:
	if is_open or not can_swing:
		return
	is_open = true
	_front.set_deferred("monitoring", false)
	var tween := create_tween()
	tween.tween_property(panel, "rotation:y", -SWING, SWING_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	swung.emit()
