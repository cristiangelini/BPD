class_name WeighScale
extends StaticBody3D

## The doll factory's quality control scale (fabrica.md, "El muñeco del diamante"): a steel platform on a base, with a
## display that shows what lies on it, in kg. A doll from the belt weighs 0.5; the one with the diamond, 2.

const SIZE := Vector3(0.6, 0.8, 0.5)
const PLATE := Vector3(0.5, 0.04, 0.4)

## What it shows now, in kg.
var reading := 0.0
var _on := Area3D.new()
var _display: Label3D


func _ready() -> void:
	var build := PlaceBuilder.new(self)
	build.box(Vector3(0, SIZE.y / 2, 0), SIZE, Color(0.55, 0.58, 0.62))
	build.box(Vector3(0, SIZE.y + PLATE.y / 2, 0), PLATE, Color(0.8, 0.82, 0.85))
	build.mesh_box(Vector3(0, SIZE.y - 0.2, SIZE.z / 2 + 0.01), Vector3(0.3, 0.14, 0.02), Color(0.1, 0.12, 0.1))
	_display = Label3D.new()
	_display.position = Vector3(0, SIZE.y - 0.2, SIZE.z / 2 + 0.025)
	_display.pixel_size = 0.002
	_display.font_size = 48
	_display.modulate = Color(0.4, 1.0, 0.45)
	add_child(_display)
	_on.collision_layer = 0
	_on.collision_mask = 4
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(PLATE.x, 0.4, PLATE.z)
	shape.shape = box
	shape.position = Vector3(0, SIZE.y + PLATE.y + 0.2, 0)
	_on.add_child(shape)
	add_child(_on)
	_show(0.0)


func _physics_process(_delta: float) -> void:
	var kg := 0.0
	for body: Node3D in _on.get_overlapping_bodies():
		if body is RigidBody3D and not (body as RigidBody3D).freeze:
			kg += (body as RigidBody3D).mass
	if not is_equal_approx(kg, reading):
		_show(kg)


func _show(kg: float) -> void:
	reading = kg
	_display.text = "%.1f kg" % kg
